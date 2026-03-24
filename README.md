# RA8875 Z80 v0.1

Z80 assembly driver library for the RA8875 TFT display controller.

This is a basic initial version.

The core library is functional for text output, but there is no support for colour or graphics. Although the architecture is pluggable for different environments, the core library has been built and tested with only one specific hardware setup, and needs some work to make it more flexible. For example, it has only been used with a 800x480 TFT display and driven by a 10MHz Z80 (so software delays may be inadequate for slower clocks).

The console is minimal - work could be done to support escape sequences to standardise it. It also does not support backspace (yet).

## Overview

Transport-agnostic RA8875 driver for Z80 homebrew systems, originally extracted from the
[Marvin](https://github.com/PainfulDiodes/Marvin) firmware.

Two hardware transports are provided:

- **targets/beanboardspi.asm** — Hardware SPI ([BeanBoardSPI](https://github.com/PainfulDiodes/BeanBoardSPI) / BeanDeck)
- **targets/beanboard.asm** — GPIO bit-bang SPI ([BeanBoard](https://github.com/PainfulDiodes/BeanBoard))

Other transports / environments may be added.

## Files

| File                       | Description                                            |
|----------------------------|--------------------------------------------------------|
| `asm/ra8875.asm`           | Core RA8875 chip driver                                |
| `asm/ra8875.inc`           | RA8875 Register definitions and constants              |
| `asm/console.asm`          | Optional console layer (scrolling and software cursor) |
| `targets/beanboardspi.asm` | Parallel transport (hardware SPI) for BeanBoardSPI     |
| `targets/beanboard.asm`    | Bit-bang SPI transport for BeanBoard GPIO              |
| `targets/environment.asm`  | RAM and port assignments                               |
| `tests/main.asm`           | Example test harness                                   |

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
