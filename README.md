# RA8875 Z80

Z80 assembly driver library for the RA8875 TFT display controller.

## Overview

Transport-agnostic RA8875 driver for Z80 homebrew systems, originally extracted from the
[Marvin](https://github.com/PainfulDiodes/Marvin) firmware.

Two hardware transports are provided:

- **targets/beanboardspi.asm** — Hardware SPI ([BeanBoardSPI](https://github.com/PainfulDiodes/BeanBoardSPI) / BeanDeck)
- **targets/beanboard.asm** — GPIO bit-bang SPI ([BeanBoard](https://github.com/PainfulDiodes/BeanBoard))

Other transports / environments could easily be added.

## Files

| File                       | Description                                        |
|----------------------------|----------------------------------------------------|
| `asm/ra8875.asm`           | Core RA8875 chip driver                            |
| `asm/ra8875.inc`           | Register definitions and constants                 |
| `asm/console.asm`          | Console layer (scrolling and software cursor)      |
| `targets/beanboardspi.asm` | Parallel transport (hardware SPI) for BeanBoardSPI |
| `targets/beanboard.asm`    | Bit-bang SPI transport for BeanBoard GPIO          |
| `targets/environment.asm`  | RAM and port assignments                           |
| `tests/main.asm`           | Example test program                               |

## Building

```bash
./build.sh
```

Requires [z88dk](https://github.com/z88dk/z88dk). Assembles both targets
(`beanboard` and `beanboardspi`) into `output/`, linking the test program,
driver, console, and environment modules.

An optional RAM start address can be passed:

```bash
./build.sh 0x9000
```
