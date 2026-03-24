; ra8875-z80 test program

    INCLUDE "asm/ra8875.inc"

    EXTERN ra8875_initialise
    EXTERN ra8875_console_init
    EXTERN ra8875_console_putchar
    EXTERN ra8875_console_cursor_x
    EXTERN ra8875_console_cursor_y
    EXTERN ra8875_putchar
    EXTERN ra8875_write_data
    EXTERN RA8875_CONSOLE_CURSOR_OFF
    EXTERN RA8875_CONSOLE_CURSOR_ON

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
    ; and hide the cursor
    ld a,RA8875_CONSOLE_CURSOR_OFF
    call ra8875_console_putchar

    ; fast-print splash screen - skip the console layer and bulk send data
    ld hl,_splash
    call _ra8875_puts_fast

    ; reposition console cursor
    ld a,22
    call ra8875_console_cursor_y
    ; show the cursor
    ld a,RA8875_CONSOLE_CURSOR_ON
    call ra8875_console_putchar

    ; print the test message
    ld hl,_msg0
    call _ra8875_console_puts

    ; print all printable characters
    ld hl,ALL_CHARS
    call _ra8875_console_puts

    ld hl,_msg1
    call _ra8875_console_puts

    ld b,1                      ; B=1: one delay per character
    
_test_loop:
    call print_all_chars
    jr _test_loop           ; loop forever

_test_error:
    jr _test_error          ; stall here if init failed

; print all characters in ALL_CHARS to the console
; B: number of _delay calls after each character (0 = no delay)
; preserves all registers
print_all_chars:
    push af
    push bc
    push de
    push hl
    ld d,b                      ; save delay count
    ld hl,ALL_CHARS
_print_all_loop:
    ld a,(hl)
    or a                        ; zero = end of array
    jr z,_print_all_done
    call ra8875_console_putchar
    ld b,d
    inc b
    dec b                       ; sets Z if delay count is zero
    jr z,_print_all_next
_print_all_delay:
    call _delay
    djnz _print_all_delay
_print_all_next:
    inc hl
    jr _print_all_loop
_print_all_done:
    ld a,0x0a                   ; LF
    call ra8875_console_putchar
    call ra8875_console_putchar
    pop hl
    pop de
    pop bc
    pop af
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

; print a zero-terminated string pointed to by hl directly to the RA8875.
; first char via ra8875_putchar (writes MRWC command), subsequent chars via
; ra8875_write_data (MRWC register stays selected). preserves all registers.
_ra8875_puts_fast:
    push af
    push hl
    ld a,(hl)
    or a
    jr z,_ra8875_puts_fast_end  ; empty string
    call ra8875_putchar
    inc hl
_ra8875_puts_fast_loop:
    ld a,(hl)
    or a
    jr z,_ra8875_puts_fast_end
    call ra8875_write_data
    inc hl
    jr _ra8875_puts_fast_loop
_ra8875_puts_fast_end:
    pop hl
    pop af
    ret

; print a zero-terminated string pointed to by hl to the console
_ra8875_console_puts:
    push hl
_puts_loop:
    ld a,(hl)
    cp 0
    jr z,_puts_end
    call ra8875_console_putchar
    inc hl
    jp _puts_loop
_puts_end:
    pop hl
    ret

_msg0:
    defm "ra8875-z80 test program\n\nconsole print: ",0x00
_msg1:
    defm "\n\nconsole wrap and scroll: ",0x00

; all characters 0x01-0xff excluding console special characters:
;   0x0a LF, 0x0d CR, 0x0e SO (cursor on), 0x0f SI (cursor off)
; zero-terminated so ra8875_console_puts or _print_all_chars can use it directly
ALL_CHARS:
    defb 0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09
    defb 0x0b,0x0c                              ; skip 0x0a LF
                                                ; skip 0x0d CR, 0x0e SO, 0x0f SI
    defb 0x10,0x11,0x12,0x13,0x14,0x15,0x16,0x17,0x18,0x19,0x1a,0x1b,0x1c,0x1d,0x1e,0x1f
    defb 0x20,0x21,0x22,0x23,0x24,0x25,0x26,0x27,0x28,0x29,0x2a,0x2b,0x2c,0x2d,0x2e,0x2f
    defb 0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x3a,0x3b,0x3c,0x3d,0x3e,0x3f
    defb 0x40,0x41,0x42,0x43,0x44,0x45,0x46,0x47,0x48,0x49,0x4a,0x4b,0x4c,0x4d,0x4e,0x4f
    defb 0x50,0x51,0x52,0x53,0x54,0x55,0x56,0x57,0x58,0x59,0x5a,0x5b,0x5c,0x5d,0x5e,0x5f
    defb 0x60,0x61,0x62,0x63,0x64,0x65,0x66,0x67,0x68,0x69,0x6a,0x6b,0x6c,0x6d,0x6e,0x6f
    defb 0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x7a,0x7b,0x7c,0x7d,0x7e,0x7f
    defb 0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f
    defb 0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,0x9d,0x9e,0x9f
    defb 0xa0,0xa1,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xab,0xac,0xad,0xae,0xaf
    defb 0xb0,0xb1,0xb2,0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xb9,0xba,0xbb,0xbc,0xbd,0xbe,0xbf
    defb 0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,0xce,0xcf
    defb 0xd0,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xdf
    defb 0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,0xe9,0xea,0xeb,0xec,0xed,0xee,0xef
    defb 0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0xff
    defb 0x00                                   ; zero terminator

_splash:
    defm "####################################################################################################"
    defm "####################################################################################################"
    defm "####################################################################################################"
    defm "######                                                                                        ######"
    defm "######   ZZZZZZZZZZZZZZZZZZZZZZZ            888888888888888               0000000000000       ######"
    defm "######   ZZZZZZZZZZZZZZZZZZZZZZZ          8888888888888888888           00000000000000000     ######"
    defm "######   ZZZZZZZZZZZZZZZZZZZZZZZ         88888888     88888888         0000000     0000000    ######"
    defm "######                ZZZZZZZZZ          8888888       8888888        0000000       0000000   ######"
    defm "######              ZZZZZZZZZ            8888888       8888888        0000000       0000000   ######"
    defm "######            ZZZZZZZZZ               8888888888888888888         0000000       0000000   ######"
    defm "######          ZZZZZZZZZ                   888888888888888           0000000       0000000   ######"
    defm "######        ZZZZZZZZZ                   8888888888888888888         0000000       0000000   ######"
    defm "######      ZZZZZZZZZ                    8888888       8888888        0000000       0000000   ######"
    defm "######    ZZZZZZZZZ                      8888888       8888888        0000000       0000000   ######"
    defm "######   ZZZZZZZZZZZZZZZZZZZZZZZ         88888888     88888888         0000000     0000000    ######"
    defm "######   ZZZZZZZZZZZZZZZZZZZZZZZ          8888888888888888888           00000000000000000     ######"
    defm "######   ZZZZZZZZZZZZZZZZZZZZZZZ            888888888888888               0000000000000       ######"
    defm "######                                                                                        ######"
    defm "####################################################################################################"
    defm "####################################################################################################"
    defm "####################################################################################################"
    defb 0x00                                   ; zero terminator