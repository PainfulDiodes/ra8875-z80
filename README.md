# ra8875

Z80 assembly driver library for the RA8875 TFT display controller.

## Overview

Transport-agnostic RA8875 driver for Z80 homebrew systems, extracted from the
[Marvin](https://github.com/PainfulDiodes/Marvin) firmware.

Supports two hardware transports:

- **ra8875_spi.asm** — Hardware SPI (BeanBoardSPI / BeanDeck)
- **ra8875_gpio.asm** — GPIO bit-bang SPI (BeanBoard)

## Files

| File | Description |
|---|---|
| `asm/drivers/ra8875.asm` | Core RA8875 chip driver |
| `asm/drivers/ra8875.inc` | Register definitions and constants |
| `asm/drivers/ra8875_spi.asm` | Hardware SPI transport |
| `asm/drivers/ra8875_gpio.asm` | GPIO bit-bang SPI transport |
| `asm/console_beandeck.asm` | Reference console implementation (may diverge from Marvin) |
| `asm/system.inc` | Stub defining required symbols for standalone builds |

## Integration

Include paths resolve from the assembler include root (`-I`). Pass two roots
when building a host project:

```bash
z88dk-z80asm -I"$HOST_DIR" -I"$RA8875_DIR" ...
```

The host's `system.inc` provides the RAM addresses and port constants.
The stub `asm/system.inc` in this repo is used only for standalone builds.

## Building standalone

```bash
./build.sh
```

Requires [z88dk](https://github.com/z88dk/z88dk). Assembles all modules to
`output/` to verify they assemble cleanly.
