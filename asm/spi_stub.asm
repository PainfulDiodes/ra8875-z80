;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; spi_stub.asm - RA8875 SPI transport stub
;
; STUB — no implementation. Provided as an example of what needs to be 
; implemented as an interface for particular hardware
;
; A concrete implementation must provide these six PUBLIC functions:
;
;   ra8875_reset_assert   : assert the RA8875 /RESET line (active low)
;   ra8875_reset_deassert : release /RESET
;   ra8875_cs_start       : assert the RA8875 SPI chip select (active low)
;   ra8875_cs_end         : deassert chip select
;   ra8875_write          : write the byte in A over SPI; this will typically 
;                           wait for serialisation to complete before returning
;   ra8875_read           : clock in one byte (send 0x00 dummy), wait for
;                           completion, return received byte in A
;
; All six functions must be PUBLIC with these exact names so that ra8875.asm
; can resolve them as EXTERNs.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    PUBLIC ra8875_reset_assert
    PUBLIC ra8875_reset_deassert
    PUBLIC ra8875_cs_start
    PUBLIC ra8875_cs_end
    PUBLIC ra8875_write
    PUBLIC ra8875_read

ra8875_reset_assert:
ra8875_reset_deassert:
ra8875_cs_start:
ra8875_cs_end:
ra8875_write:
ra8875_read:
    ret
