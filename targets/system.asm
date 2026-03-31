; Stub RAM and port assignments 
; Targets would provide their own definitions of these labels
; to Fulfil EXTERN labels in the asm modules.

; --- Console (console.asm) ---

    PUBLIC RA8875_RAMSTART
    PUBLIC CAPS_LOCK_STATE

CAPS_LOCK_STATE equ 0xe000 ; 1 byte: caps lock state (0=off, 1=on) - would normally be set externally (by console input / keyboard)
RA8875_RAMSTART equ 0xe001 ; base address for RA8875 console variables

; --- BeanBoard: GPIO bit-bang SPI transport (beanboard.asm) ---

    PUBLIC RA8875_GPIO

RA8875_GPIO equ 6

; --- BeanBoardSPI: hardware SPI transport (beanboardspi.asm) ---

    PUBLIC RA8875_SPI_CTRL
    PUBLIC RA8875_SPI_DATA

RA8875_SPI_CTRL equ 8              ; control register (74HCT373 latch)
RA8875_SPI_DATA equ 10             ; data register (74HCT299 shift register)
