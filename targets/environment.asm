; Fulfils EXTERN labels required by the asm library modules.
;
; Port and control register assignments for BeanBoard/BeanBoardSPI hardware.
; Other targets must provide their own definitions of these labels.

; --- Console (console.asm) ---

    PUBLIC RA8875_RAMSTART

RA8875_RAMSTART equ 0xe000         ; base address for RA8875 console variables

; --- BeanBoard: GPIO bit-bang SPI transport (beanboard.asm) ---

    PUBLIC RA8875_GPIO

RA8875_GPIO equ 6

; --- BeanBoardSPI: hardware SPI transport (beanboardspi.asm) ---

    PUBLIC RA8875_SPI_CTRL
    PUBLIC RA8875_SPI_DATA
    PUBLIC RA8875_SPI_IDLE
    PUBLIC RA8875_SPI_RESET
    PUBLIC RA8875_SPI_SELECT_0

RA8875_SPI_CTRL equ 8              ; control register (74HCT373 latch)
RA8875_SPI_DATA equ 10             ; data register (74HCT299 shift register)

; Control register values (active low bits)
; Bit 0: RESET, Bit 1: SPI0 CS, Bits 2-7: SPI1-SPI6 CS (all need to be set high)
RA8875_SPI_IDLE     equ 0xFF       ; all deselected, reset released
RA8875_SPI_RESET    equ 0xFE       ; bit 0 low = reset asserted
RA8875_SPI_SELECT_0 equ 0xFD       ; bit 1 low = SPI0 selected
