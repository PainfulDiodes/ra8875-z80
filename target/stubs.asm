; Stubs for console output functions.
;
; console.asm declares usb_putchar as EXTERN.
; The test sets CONSOLE_STATUS_BEANBOARD so this is never called at runtime,
; but it must be resolved at link time.

    PUBLIC usb_putchar

; Discard the character (A = char to send)
usb_putchar:
    ret
