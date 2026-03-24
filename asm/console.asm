;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RA8875 console layer
;
; Implements a scrolling text console on top of the RA8875 text rendering
; hardware. Tracks cursor position and scroll state in RAM, draws a software
; block cursor, and handles scrolling via the RA8875 vertical offset register.
;
; Public interface:
;   ra8875_console_init     - initialise state; call after ra8875_initialise
;   ra8875_console_putchar  - write character in A to console
;   ra8875_console_puts     - write zero-terminated string pointed to by HL
;   ra8875_console_cursor_x - set cursor column to A (0..RA8875_COLS-1)
;   ra8875_console_cursor_y - set cursor row to A (0..RA8875_ROWS-1, logical)
;
; Special characters recognised by ra8875_console_putchar:
;   0x0a  LF  - newline: erase cursor, advance to next row (scrolls if needed)
;   0x0d  CR  - same as LF
;   0x0e  SO  - cursor on:  make software cursor visible
;   0x0f  SI  - cursor off: hide software cursor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    INCLUDE "ra8875.inc"

    PUBLIC ra8875_console_putchar
    PUBLIC ra8875_console_init
    PUBLIC ra8875_console_cursor_x
    PUBLIC ra8875_console_cursor_y

    EXTERN ra8875_putchar
    EXTERN ra8875_cursor_x
    EXTERN ra8875_cursor_y
    EXTERN ra8875_write_reg
    EXTERN ra8875_read_reg

    EXTERN RA8875_RAMSTART

    ; RAM variables 4 bytes: col, row, scroll_top, cursor_visible
    RA8875_CURSOR_COL     equ RA8875_RAMSTART + 0  ; 1-byte column (0..RA8875_COLS-1)
    RA8875_CURSOR_ROW     equ RA8875_RAMSTART + 1  ; 1-byte physical row (0..RA8875_ROWS-1)
    RA8875_SCROLL_TOP     equ RA8875_RAMSTART + 2  ; 1-byte physical row at top of display
    RA8875_CURSOR_VISIBLE equ RA8875_RAMSTART + 3  ; 1-byte non-zero = cursor visible, zero = cursor hidden

; Initialise RA8875 console state.
; Hides hardware cursor, zeroes tracking variables, draws initial software cursor.
; VOFS is reset by ra8875_initialise; call that first.
ra8875_console_init:
    ; hide hardware cursor - software cursor used instead
    ld a,RA8875_MWCR0
    call ra8875_read_reg
    and ~RA8875_MWCR0_CURSOR
    ld b,a
    ld a,RA8875_MWCR0
    call ra8875_write_reg
    ; zero-init cursor and scroll state
    xor a
    ld (RA8875_CURSOR_COL),a
    ld (RA8875_CURSOR_ROW),a
    ld (RA8875_SCROLL_TOP),a
    ld a,1
    ld (RA8875_CURSOR_VISIBLE),a
    ; draw initial software cursor at (0,0)
    call _draw_cursor
    ret


; send character in A to console
ra8875_console_putchar:
    push af
    push bc
    push de
    push hl
    cp 0x0f                     ; SI - cursor off?
    jr z,_putchar_cursor_off
    cp 0x0e                     ; SO - cursor on?
    jr z,_putchar_cursor_on
    cp 0x0a                     ; newline?
    jr z,_putchar_newline
    cp 0x0d                     ; carriage return? TODO - validate - do we need this?
    jr z,_putchar_newline
    ; character overwrites software cursor at current position; RA8875 auto-advances
    call ra8875_putchar
    ld hl,RA8875_CURSOR_COL
    inc (hl)
    ld a,(RA8875_CURSOR_COL)
    cp RA8875_COLS              ; reached end of line?
    jr z,_putchar_line_wrap
    call _draw_cursor
    jr _putchar_done
_putchar_line_wrap:
    ; implicit wrap: typed character already overwrote cursor, no erase needed
    xor a
    ld (RA8875_CURSOR_COL),a
    call _advance_line
    jr _putchar_done
_putchar_cursor_off:
    xor a
    ld (RA8875_CURSOR_VISIBLE),a
    call _erase_cursor
    jr _putchar_done
_putchar_cursor_on:
    ld a,1
    ld (RA8875_CURSOR_VISIBLE),a
    call _draw_cursor
    jr _putchar_done
_putchar_newline:
    ; erase software cursor with a space before moving to next line
    ld a,' '
    call ra8875_putchar
    xor a
    ld (RA8875_CURSOR_COL),a
    call _advance_line
    jr _putchar_done
_putchar_done:
    ld a,b
    pop hl
    pop de
    pop bc
    pop af
    ret


; Set console cursor column. A = column (0..RA8875_COLS-1).
; Erases the cursor at the current position, updates the column, redraws.
; Preserves all registers.
ra8875_console_cursor_x:
    call _erase_cursor
    ld (RA8875_CURSOR_COL),a
    call _draw_cursor
    ret


; Set console cursor row. A = logical row (0 = top of visible area, 0..RA8875_ROWS-1).
; Converts logical row to physical row accounting for scroll_top.
; Erases the cursor at the current position, updates the row, redraws.
; Preserves all registers.
ra8875_console_cursor_y:
    push af
    push bc
    call _erase_cursor
    ; convert logical row in A to physical: (scroll_top + A) % RA8875_ROWS
    ld b,a
    ld a,(RA8875_SCROLL_TOP)
    add a,b
    cp RA8875_ROWS
    jr c,_cursor_y_no_wrap
    sub RA8875_ROWS
_cursor_y_no_wrap:
    ld (RA8875_CURSOR_ROW),a
    call _draw_cursor
    pop bc
    pop af
    ret


; Advance cursor to the next row, scrolling if on the last visible row.
; Assumes RA8875_CURSOR_COL has already been reset to 0 by the caller.
; Draws the software cursor at the new position.
; Preserves all registers.
_advance_line:
    push af
    push bc
    push hl

    ; last_visible = (scroll_top + RA8875_ROWS - 1) % RA8875_ROWS
    ; This calculates which physical row is currently at the bottom of the display — 
    ; the last visible row.
    ; For example, with 30 rows and scroll_top = 5, the last visible row is physical row 4
    ; (wrapping around the circular buffer: rows 5, 6, … 29, 0, 1, 2, 3, 4).
    ; The % ROWS is done with a conditional subtract rather than a true modulo — 
    ; this works because scroll_top is always in range [0, ROWS-1], 
    ; so scroll_top + (ROWS-1) can overshoot by at most ROWS-1, 
    ; meaning a single subtract is sufficient to bring it back in range.
    ; After this block, A holds the physical row number of the last visible (bottom) line, 
    ; which is then compared against the current cursor row to decide whether a scroll is needed.
    ld a,(RA8875_SCROLL_TOP)
    add a,RA8875_ROWS-1
    cp RA8875_ROWS
    jr c,_al_no_wrap
    sub RA8875_ROWS
_al_no_wrap:
    ; A = last_visible physical row
    ld b,a
    ld a,(RA8875_CURSOR_ROW)
    cp b
    jr nz,_al_advance           ; not on last visible row: simple advance

    ; on last visible row: hardware scroll up one row
    ld a,(RA8875_SCROLL_TOP)
    ld c,a                      ; C = old scroll_top (becomes new cursor row)
    inc a
    cp RA8875_ROWS
    jr nz,_al_scroll_ok
    xor a
_al_scroll_ok:
    ld (RA8875_SCROLL_TOP),a    ; scroll_top = (old + 1) % RA8875_ROWS

    ; VOFS = scroll_top * 16 (fits in 9 bits, max 29*16=464)
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl                   ; HL = scroll_top * 16
    ld a,RA8875_VOFS0
    ld b,l
    call ra8875_write_reg
    ld a,RA8875_VOFS1
    ld b,h
    call ra8875_write_reg

    ; cursor goes to old scroll_top (now the new bottom row)
    ld a,c
    ld (RA8875_CURSOR_ROW),a
    call _cursor_xy_position    ; position RA8875 to col 0 of new bottom row

    ; clear the new bottom row
    ld b,RA8875_COLS
_al_clear_loop:
    ld a,' '
    call ra8875_putchar
    djnz _al_clear_loop

    call _draw_cursor
    jr _al_done

_al_advance:
    ; advance cursor_row by one (wraps mod RA8875_ROWS)
    ld a,(RA8875_CURSOR_ROW)
    inc a
    cp RA8875_ROWS
    jr nz,_al_set_row
    xor a
_al_set_row:
    ld (RA8875_CURSOR_ROW),a
    call _draw_cursor

_al_done:
    pop hl
    pop bc
    pop af
    ret


; Position RA8875 text cursor at (RA8875_CURSOR_COL * 8, RA8875_CURSOR_ROW * 16) pixels.
; Preserves all registers.
_cursor_xy_position:
    push af
    push hl
    ld a,(RA8875_CURSOR_COL)
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl                   ; HL = cursor_col * 8 (RA8875_CHAR_W)
    call ra8875_cursor_x
    ld a,(RA8875_CURSOR_ROW)
    ld h,0
    ld l,a
    add hl,hl
    add hl,hl
    add hl,hl
    add hl,hl                   ; HL = cursor_row * 16 (RA8875_CHAR_H)
    call ra8875_cursor_y
    pop hl
    pop af
    ret


; Erase software cursor at current (RA8875_CURSOR_ROW, RA8875_CURSOR_COL).
; Writes a space with the default black background.
; Preserves all registers.
_erase_cursor:
    push af
    push bc
    call _cursor_xy_position
    ld a,' '
    call ra8875_putchar
    call _cursor_xy_position    ; reposition: putchar advanced the RA8875 cursor
    pop bc
    pop af
    ret


; Draw software cursor at current (RA8875_CURSOR_ROW, RA8875_CURSOR_COL).
; Solid block: writes space with white background, reversing the normal colours.
; Positions RA8875 cursor, writes space, then repositions (putchar advances cursor).
; Preserves all registers.
_draw_cursor:
    push af
    push bc
    call _cursor_xy_position    ; always reposition RA8875 cursor for subsequent writes
    ld a,(RA8875_CURSOR_VISIBLE)
    or a
    jr z,_draw_cursor_done      ; cursor hidden: skip visual rendering
    ; set background to white for solid block cursor
    ld a,RA8875_BGCR0
    ld b,0x1f
    call ra8875_write_reg
    ld a,RA8875_BGCR1
    ld b,0x3f
    call ra8875_write_reg
    ld a,RA8875_BGCR2
    ld b,0x1f
    call ra8875_write_reg
    ld a,' '
    call ra8875_putchar
    ; restore background to black
    ld a,RA8875_BGCR0
    ld b,0x00
    call ra8875_write_reg
    ld a,RA8875_BGCR1
    ld b,0x00
    call ra8875_write_reg
    ld a,RA8875_BGCR2
    ld b,0x00
    call ra8875_write_reg
    call _cursor_xy_position    ; reposition: putchar advanced the RA8875 cursor
_draw_cursor_done:
    pop bc
    pop af
    ret
