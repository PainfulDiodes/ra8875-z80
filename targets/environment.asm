; Fulfils EXTERN labels required by the asm library modules.
;
; Port and control register assignments for BeanBoard/BeanBoardSPI hardware.
; Other targets must provide their own definitions of these labels.

; RA8875 console RAM base address (console.asm) - base address that the RA8875 console can use for vars

    PUBLIC RA8875_RAMSTART
    PUBLIC RA8875_GPIO
    PUBLIC RA8875_SPI_CTRL
    PUBLIC RA8875_SPI_DATA
    PUBLIC RA8875_SPI_IDLE
    PUBLIC RA8875_SPI_RESET
    PUBLIC RA8875_SPI_SELECT_0

; Where we can store variables in RAM
RA8875_RAMSTART equ 0xe000

; GPIO bit-bang SPI transport (beanboard.asm)
RA8875_GPIO equ 6

; Hardware SPI transport (beanboardspi.asm)
; SPI ports (BeanBoardSPI hardware)
RA8875_SPI_CTRL equ 8              ; control register (74HCT373 latch)
RA8875_SPI_DATA equ 10             ; data register (74HCT299 shift register)

; Control register values (active low bits)
; Bit 0: RESET, Bit 1: SPI0 CS, Bits 2-7: SPI1-SPI6 CS (all need to be set high)

RA8875_SPI_IDLE     equ 0xFF       ; all deselected, reset released
RA8875_SPI_RESET    equ 0xFE       ; bit 0 low = reset asserted
RA8875_SPI_SELECT_0 equ 0xFD       ; bit 1 low = SPI0 selected
