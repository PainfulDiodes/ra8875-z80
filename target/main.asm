; RA8875 display initialisation test
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

    INCLUDE "asm/system.inc"
    INCLUDE "asm/ra8875.inc"

    EXTERN ra8875_initialise
    EXTERN ra8875_console_init
    EXTERN puts

IFNDEF RAM_START
RAM_START equ 0x8000
ENDIF

    ORG RAM_START

test_ra8875:
    ; route console output to the RA8875
    ld a,CONSOLE_STATUS_BEANBOARD
    ld (CONSOLE_STATUS),a

    ; bring up the RA8875 hardware
    call ra8875_initialise
    jp nz,_test_error

    ; short settling delay - 256x256 nops
    ld c,0
_delay_outer:
    ld b,0
_delay_inner:
    nop
    djnz _delay_inner
    dec c
    jr nz,_delay_outer

    ; initialise the console layer (cursor state, software cursor)
    call ra8875_console_init

    ; print the test message
    ld hl,_msg
    call puts

_test_loop:
    jr _test_loop           ; loop forever

_test_error:
    jr _test_error          ; stall here if init failed

_msg:
    defm "RA8875 init OK",0x0a,0x00
