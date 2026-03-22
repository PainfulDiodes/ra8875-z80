; RA8875 display test
;
; Standalone RAM-loaded program.  Assemble with -DRAM_START=<addr> to
; override the load address (default 0x8000).
;
; Sequence:
;   1. Set CONSOLE_STATUS to BEANBOARD so putchar routes to the RA8875.
;   2. Initialise the RA8875 hardware (ra8875_initialise).
;   3. Initialise the console layer (ra8875_console_init).
;   4. Print a message via puts.
;   5. Loop forever.
;
; Error path: if ra8875_initialise returns NZ the program halts at
; _test_error for inspection.

    INCLUDE "asm/ra8875.inc"

    EXTERN ra8875_initialise
    EXTERN ra8875_console_init
    EXTERN ra8875_console_puts
    EXTERN ra8875_console_putchar

IFNDEF RAM_START
RAM_START equ 0x8000
ENDIF

    ORG RAM_START

test_ra8875:

    ; bring up the RA8875 hardware
    call ra8875_initialise
    jp nz,_test_error

    ; short settling delay
    call _delay

    ; initialise the console layer (cursor state, software cursor)
    call ra8875_console_init

    ; print the test message
    ld hl,_msg
    call ra8875_console_puts

    ; SI - cursor off
    ld a,0x0f
    call ra8875_console_putchar

    ; print all printable characters
    ld b,0                      ; B=0: no inter-character delay
    call _print_all_chars
    call _print_all_chars
    call _print_all_chars
    call _print_all_chars
    call _print_all_chars
    call _print_all_chars

    ; SO - cursor on
    ld a,0x0e
    call ra8875_console_putchar

    ld b,1                      ; B=1: one delay per character
    
_test_loop:
    call _print_all_chars
    jr _test_loop           ; loop forever

_test_error:
    jr _test_error          ; stall here if init failed

; print all 256 characters (0x00-0xff) to the console
; skips console special characters: 0x0a LF, 0x0d CR, 0x0e SO, 0x0f SI
; B: number of _delay calls after each character (0 = no delay)
; preserves all registers
_print_all_chars:
    push bc
    push de
    ld d,b                      ; save delay count
    ld a,0
_print_all_loop:
    cp 0x0a                     ; LF - newline
    jr z,_print_all_skip
    cp 0x0d                     ; CR - carriage return
    jr z,_print_all_skip
    cp 0x0e                     ; SO - cursor on
    jr z,_print_all_skip
    cp 0x0f                     ; SI - cursor off
    jr z,_print_all_skip
    call ra8875_console_putchar
    ld b,d                      ; B = delay count (doesn't touch A)
    inc b
    dec b                       ; sets Z if delay count is zero
    jr z,_print_all_skip
_print_all_delay:
    call _delay
    djnz _print_all_delay
_print_all_skip:
    inc a
    jr nz,_print_all_loop       ; stops after wrapping 255->0
    ld a,0x0a                   ; LF
    call ra8875_console_putchar
    call ra8875_console_putchar
    pop de
    pop bc
    ret

; 256x256 nop delay; preserves all registers
_delay:
    push bc
    ld c,0
_delay_outer:
    ld b,0
_delay_inner:
    nop
    djnz _delay_inner
    dec c
    jr nz,_delay_outer
    pop bc
    ret

_msg:
    defm "RA8875 test\n\n",0x00
