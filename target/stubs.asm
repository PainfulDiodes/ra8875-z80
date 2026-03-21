; Stubs for console input functions.
;
; console_beandeck.asm declares usb_readchar, usb_putchar and key_readchar
; as EXTERNs.  The test sets CONSOLE_STATUS_BEANBOARD so these are never
; called at runtime, but they must be resolved at link time.

    PUBLIC usb_readchar
    PUBLIC usb_putchar
    PUBLIC key_readchar

; Return A=0 (no character available)
usb_readchar:
    xor a
    ret

; Discard the character (A = char to send)
usb_putchar:
    ret

; Return A=0 (no character available)
key_readchar:
    xor a
    ret
