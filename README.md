# RA8875 Z80 v0.5

THIS IS A WORK IN PROGRESS

Z80 library driver for the RA8875 TFT display controller (builds with [z88dk](https://github.com/z88dk/z88dk)).

## Overview

This is an initial version with limited capability and was built and tested for a specific hardware configuration ([BeanBoard](https://github.com/PainfulDiodes/BeanBoard) and [BeanBoardSPI](https://github.com/PainfulDiodes/BeanBoardSPI) - "BeanDeck") and [Marvin](https://github.com/PainfulDiodes/Marvin) firmware. That said, it is delivered as an independent library, and was designed with adaptability in mind, so could be repurposed for other systems.

The RA8875 has a large number of registers for controlling the device. The core library here provides primitives for a subset of RA8875 commands and is functional for text output. Basic foreground and background colour control is supported. Graphics support is not yet implemented.

A "console" implementation is provided which receives and prints characters, wraps lines and scrolls the display. It supports a handful of control characters - newline, carriage return, backspace (backspace to the beginning of the current line of text). Functions are also provided for controlling the colour of the cursor and cursor visibility and positioning. Although the RA8875 implements its own cursor, I have found that this doesn't play well with hardware scrolling, so a software cursor has been implemented in the console. I have not yet implemented console escape sequences.

## Hardware Compatibility

The driver has been written around the [Adafruit RA8875 Driver Board (Rev E) for 40-pin TFT Touch Displays - 800x480 Max](https://www.adafruit.com/product/1590)

It has been configured for and tested with the [Adafruit 7.0" 40-pin TFT Display - 800x480 without Touchscreen](https://www.adafruit.com/product/2353)

The RA8875 board has an SPI interface. The library does not include an SPI transport - this will need to be provided by the consumer, based on their hardware. A stub is provided as a guide: spi_stub.asm

Any software delays used in the driver assume a 10MHz Z80 CPU and may need adjusting for other clock speeds.

## References

* [sumotoy RA8875](https://github.com/sumotoy/RA8875) - "A library for RAiO RA8875 display driver for Teensy3.x or LC/Arduino's/Energia/Spark"
* [Adafruit RA8875](https://github.com/adafruit/Adafruit_RA8875) - "Adafruit Arduino library driver for the RA8875 TFT driver"
* [RAiO RA8875](https://www.raio.com.tw/en/RA8875.html) - "RA8875 Character / Graphic TFT LCD Controller"
