IFNDEF _SYSTEM_INC
DEFINE _SYSTEM_INC

; Stub system.inc for standalone ra8875 repo builds.
; Defines only the symbols required by ra8875_gpio.asm and console_beandeck.asm.
; In a host project (e.g. Marvin) these are provided by the host's system.inc
; via the host include root; this stub is only used when assembling in isolation.

; RA8875 console state (RAM addresses - must be provided by the host project)
RA8875_CURSOR_COL     equ 0xf001  ; 1-byte column (0..RA8875_COLS-1)
RA8875_CURSOR_ROW     equ 0xf002  ; 1-byte physical row (0..RA8875_ROWS-1)
RA8875_SCROLL_TOP     equ 0xf003  ; 1-byte physical row at top of display
RA8875_CURSOR_VISIBLE equ 0xf004  ; non-zero = cursor visible, zero = cursor hidden

; Console status (used by console_beandeck.asm)
CONSOLE_STATUS          equ 0xf000
CONSOLE_STATUS_USB      equ 1
CONSOLE_STATUS_BEANBOARD equ 2

; GPIO bit-bang SPI ports (used by ra8875_gpio.asm)
GPIO_OUT equ 6
GPIO_IN  equ 7

ENDIF
