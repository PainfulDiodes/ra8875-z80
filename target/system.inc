IFNDEF _SYSTEM_INC
DEFINE _SYSTEM_INC

; Stub system.inc for standalone ra8875 repo builds.
; Defines only the symbols required by transport_gpio.asm and console_beandeck.asm.
; In a host project (e.g. Marvin) these are provided by the host's system.inc
; via the host include root; this stub is only used when assembling in isolation.

; RA8875 console state (RAM addresses - must be provided by the host project)


; GPIO bit-bang SPI ports (used by transport_gpio.asm)
GPIO_OUT equ 6
GPIO_IN  equ 7

ENDIF

; TODO - rethink RAM locations for this - because this is a RAM build, this could be done more simply through labels?
; however, this is only an example - it will be swapped with a proper system.inc