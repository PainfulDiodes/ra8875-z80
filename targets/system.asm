; RAM and port assignments for BeanBoard/BeanBoardSPI hardware.
; Other targets provide their own definitions of these labels
; to Fulfil EXTERN labels in the asm modules.

; --- Console (console.asm) ---

    PUBLIC RA8875_RAMSTART
    PUBLIC CAPS_LOCK_STATE
    EXTERN RA8875_RAMSIZE

RA8875_RAMSTART equ 0xe000                              ; base address for RA8875 console variables
CAPS_LOCK_STATE equ RA8875_RAMSTART + RA8875_RAMSIZE    ; 1 byte: caps lock state (0=off, 1=on)

; --- BeanBoard: GPIO bit-bang SPI transport (beanboard.asm) ---

    PUBLIC RA8875_GPIO

RA8875_GPIO equ 6

; --- BeanBoardSPI: hardware SPI transport (beanboardspi.asm) ---

    PUBLIC RA8875_SPI_CTRL
    PUBLIC RA8875_SPI_DATA

RA8875_SPI_CTRL equ 8              ; control register (74HCT373 latch)
RA8875_SPI_DATA equ 10             ; data register (74HCT299 shift register)
