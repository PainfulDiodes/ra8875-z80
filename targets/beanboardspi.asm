;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RA8875 SPI transport layer (BeanBoardSPI hardware)
;
; Provides the low-level SPI transport interface for ra8875_core.asm.
; Uses the BeanBoardSPI expansion board: 74HCT299 shift register for
; serialisation and 74HCT373 latch for chip select and reset control.
;
; Interface (PUBLIC):
;   ra8875_reset_assert  - Assert RESET via control register
;   ra8875_reset_deassert - Deassert RESET via control register
;   ra8875_cs_start      - Assert CS with setup delay
;   ra8875_cs_end        - Deassert CS with hold delay
;   ra8875_write         - Write byte via hardware SPI
;   ra8875_read          - Read byte via hardware SPI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    PUBLIC ra8875_reset_assert
    PUBLIC ra8875_reset_deassert
    PUBLIC ra8875_cs_start
    PUBLIC ra8875_cs_end
    PUBLIC ra8875_write
    PUBLIC ra8875_read

    EXTERN RA8875_SPI_CTRL
    EXTERN RA8875_SPI_DATA


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Control register values (active low bits)
; Bit 0: RESET, Bit 1: SPI0 CS, Bits 2-7: SPI1-SPI6 CS (all need to be set high)
RA8875_SPI_IDLE     equ 0xFF       ; all deselected, reset released
RA8875_SPI_RESET    equ 0xFE       ; bit 0 low = reset asserted
RA8875_SPI_SELECT_0 equ 0xFD       ; bit 1 low = SPI0 selected


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; transport interface
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Assert RA8875 RESET (active low via SPI control register)
; Destroys: AF
ra8875_reset_assert:
    push af
    ld a,RA8875_SPI_RESET
    out (RA8875_SPI_CTRL),a
    pop af
    ret


; Deassert RA8875 RESET (release)
; Destroys: AF
ra8875_reset_deassert:
    push af
    ld a,RA8875_SPI_IDLE
    out (RA8875_SPI_CTRL),a
    pop af
    ret


; Assert SPI0 chip select with setup delay
; Destroys: AF
ra8875_cs_start:
    push af
    ld a,RA8875_SPI_SELECT_0
    out (RA8875_SPI_CTRL),a
    pop af
    ret


; Deassert SPI0 chip select with hold delay
; Destroys: AF
ra8875_cs_end:
    push af
    ld a,RA8875_SPI_IDLE
    out (RA8875_SPI_CTRL),a
    pop af
    ret


; Write a byte over hardware SPI
; Input: A = byte to send
; Destroys: AF
ra8875_write:
    out (RA8875_SPI_DATA),a
    nop ; short delay to allow for serialisation
    nop
    nop
    ret


; Read a byte over hardware SPI
; Sends a dummy byte (0x00) to clock in the response
; Output: A = byte received
; Destroys: AF
ra8875_read:
    ld a,0x00
    out (RA8875_SPI_DATA),a
    nop ; short delay to allow for serialisation
    nop
    nop
    in a,(RA8875_SPI_DATA)
    ret
