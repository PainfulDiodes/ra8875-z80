;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; RA8875 bit-bang SPI transport layer
;
; EXPERIMENTAL
;
; Provides the low-level SPI transport interface to be used by ra8875.asm.
; Bit-bangs the SPI protocol over the BeanBoard GPIO port, with manual
; control of SCK, MOSI, MISO, CS, and RESET signals.
;
; Interface (PUBLIC):
;   ra8875_reset_assert  - Assert RESET via GPIO
;   ra8875_reset_deassert - Deassert RESET via GPIO
;   ra8875_cs_start      - Assert CS
;   ra8875_cs_end        - Deassert CS
;   ra8875_write         - Write byte via bit-bang SPI
;   ra8875_read          - Read byte via bit-bang SPI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    PUBLIC ra8875_reset_assert
    PUBLIC ra8875_reset_deassert
    PUBLIC ra8875_cs_start
    PUBLIC ra8875_cs_end
    PUBLIC ra8875_write
    PUBLIC ra8875_read

    ; port number provided in environment.asm
    EXTERN RA8875_GPIO


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Pin definitions for RA8875 SPI on GPIO port
; GPO
; Serial Clock
RA8875_GPO_BIT_SCK  equ 0
; Master Out Slave In
RA8875_GPO_BIT_MOSI equ 1
; RA8875 RESET - active LOW
RA8875_GPO_BIT_RESET equ 2
; Chip Select - active LOW
RA8875_GPO_BIT_CS   equ 3
; GPI
RA8875_GPI_BIT_MISO equ 0

; RESET low (active), CS high (inactive)
RA8875_GPO_RESET_STATE      equ 1 << RA8875_GPO_BIT_CS
; RESET high (inactive), CS high (inactive)
RA8875_GPO_INACTIVE_STATE   equ 1 << RA8875_GPO_BIT_CS | 1 << RA8875_GPO_BIT_RESET
; RESET high (inactive), CS low (active)
RA8875_GPO_ACTIVE_STATE     equ 1 << RA8875_GPO_BIT_RESET
; RESET high (inactive), CS low (active), MOSI low
RA8875_GPO_LOW_STATE        equ 1 << RA8875_GPO_BIT_RESET
; RESET high (inactive), CS low (active), MOSI high
RA8875_GPO_HIGH_STATE       equ 1 << RA8875_GPO_BIT_MOSI | 1 << RA8875_GPO_BIT_RESET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; transport interface
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Assert RA8875 RESET (active low via GPIO)
; Destroys: AF
ra8875_reset_assert:
    push af
    ld a,RA8875_GPO_RESET_STATE
    out (RA8875_GPIO),a
    pop af
    ret


; Deassert RA8875 RESET (release)
; Destroys: AF
ra8875_reset_deassert:
    push af
    ld a,RA8875_GPO_INACTIVE_STATE
    out (RA8875_GPIO),a
    pop af
    ret


; Assert chip select (CS active/low)
; No setup delay required - bit-bang timing is sufficient
; Destroys: AF
ra8875_cs_start:
    push af
    ld a,RA8875_GPO_ACTIVE_STATE
    out (RA8875_GPIO),a
    pop af
    ret


; Deassert chip select (CS inactive/high)
; Destroys: AF
ra8875_cs_end:
    push af
    ld a,RA8875_GPO_INACTIVE_STATE
    out (RA8875_GPIO),a
    pop af
    ret


; Write a byte over SPI without readback
; Input: A = byte to send
; Destroys: AF, B, D
ra8875_write:
    ; bit counter
    ld b,8
_ra8875_write_loop:
    ; rotate msb into carry flag
    rlca
    ; stash a
    ld d,a
    ; default to MOSI low
    ld a,RA8875_GPO_LOW_STATE
    jr nc,_ra8875_write_bit
    ld a,RA8875_GPO_HIGH_STATE
_ra8875_write_bit:
    out (RA8875_GPIO),a
    ; clock high
    or 1 << RA8875_GPO_BIT_SCK
    out (RA8875_GPIO),a
    ; clock low
    and ~(1 << RA8875_GPO_BIT_SCK)
    out (RA8875_GPIO),a
    ; restore A
    ld a,d
    djnz _ra8875_write_loop
    ret


; Read a byte over SPI (receive from MISO)
; Sends a dummy byte (0x00) during the read
; Output: A = byte received
; Destroys: AF, B, D
ra8875_read:
    ; bit counter
    ld b,8
    ; Initialize received byte
    ld a,0
_ra8875_read_loop:
    ; Shift received bits left
    sla a
    ; stash a
    ld d,a
    ; Set initial low state
    ld a,RA8875_GPO_LOW_STATE
    out (RA8875_GPIO),a
    ; Set clock high
    or 1 << RA8875_GPO_BIT_SCK
    out (RA8875_GPIO),a
    ; Read MISO bit
    in a,(RA8875_GPIO)
    bit RA8875_GPI_BIT_MISO,a
    jr z,_ra8875_read_low
    ; MISO high - set LSB
    ld a,d
    or 1
    jr _ra8875_read_bit_done
_ra8875_read_low:
    ; MISO low - keep LSB clear
    ld a,d
_ra8875_read_bit_done:
    ; Set clock low
    ld d,a
    ld a,RA8875_GPO_LOW_STATE
    out (RA8875_GPIO),a
    ; Restore received byte
    ld a,d
    djnz _ra8875_read_loop
    ret
