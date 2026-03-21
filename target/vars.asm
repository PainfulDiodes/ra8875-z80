; Fulfils EXTERN labels required by the asm library modules.
;
; Port and control register assignments for BeanBoard/BeanBoardSPI hardware.
; Other targets must provide their own definitions of these labels.

; RA8875 console RAM base address (console.asm) - base address that the RA8875 console can use for vars
    PUBLIC RA8875_RAM

RA8875_RAM equ 0xe000               ; 4 bytes: col, row, scroll_top, cursor_visible

; GPIO bit-bang SPI transport (transport_gpio.asm)
    PUBLIC GPIO_OUT
    PUBLIC GPIO_IN

GPIO_OUT equ 6
GPIO_IN  equ 7

; Hardware SPI transport (transport_spi.asm)
; SPI ports (BeanBoardSPI hardware)
    PUBLIC SPI_CTRL
    PUBLIC SPI_DATA

SPI_CTRL equ 8              ; control register (74HCT373 latch)
SPI_DATA equ 10             ; data register (74HCT299 shift register)

; Control register values (active low bits)
; Bit 0: RESET, Bit 1: SPI0 CS, Bits 2-7: SPI1-SPI6 CS
    PUBLIC SPI_IDLE
    PUBLIC SPI_RESET
    PUBLIC SPI_SELECT_0

SPI_IDLE     equ 0xFF       ; all deselected, reset released
SPI_RESET    equ 0xFE       ; bit 0 low = reset asserted
SPI_SELECT_0 equ 0xFD       ; bit 1 low = SPI0 selected
