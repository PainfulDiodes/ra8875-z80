# v0.3.0 WIP

* Rename environment.asm to system.asm for consistency with marvin
* Export `RA8875_RAMSIZE` as PUBLIC from `console.asm`; host system can EXTERN this to cascade its own RAM allocation immediately after the RA8875 variables block; size increased from 4 to 5 bytes to accommodate `RA8875_CURSOR_COLOUR`
* Colour support:
  * Two new public functions in `ra8875.asm`: `ra8875_set_foreground_colour`, `ra8875_set_background_colour` — pass colour constant in A, both preserve all registers
  * Eight colour constants added to `ra8875.inc`: `RA8875_COL_BLACK` through `RA8875_COL_WHITE` (0–7)
  * RGB565 component constants added to `ra8875.inc`: `RA8875_COL_*_R/G/B` for all eight colours
  * `ra8875_console_init` sets foreground colour to green on startup
* Cursor colour:
  * New public function `ra8875_console_set_cursor_colour` — stores colour in `RA8875_CURSOR_COLOUR` RAM byte and redraws cursor at current position if visible; replaces `ra8875_console_refresh_cursor`
  * `RA8875_CURSOR_COLOUR` RAM byte added; `_draw_cursor` uses it for the cursor background colour, decoupling cursor appearance from the host's `CAPS_LOCK_STATE`
  * `ra8875_console_init` sets cursor colour to green
* Fixed intermittent RA8875 initialisation bugs: restructured init sequence, added a more substantial RESET delay, reduced and tuned post-init settle delays
* Fixed cursor-off: cursor is now erased while the visible flag is still set, preventing stale cursor remnants on screen
* Minor optimisation to console putchar

# v0.2.0

* Console backspace: `ra8875_console_putchar`
  * Handles 0x08 (BS) and 0x7f (DEL, sent by most terminal emulators) identically
  * Moves cursor back one column erasing the character
  * Silently ignored at column 0

# v0.1.0

* RA8875 TFT display driver library extracted from Marvin firmware
* Modules: `ra8875.asm`, `ra8875.inc`, `ra8875_gpio.asm` (GPIO bit-bang SPI), `ra8875_spi.asm` (hardware SPI), `console.asm` (teletype-style console layer)
* Console supports: printable characters, LF/CR (newline with scroll), SO/SI (cursor on/off)
* Simple test program added with post-init delay fix; hex output checked in
* Build targets: beanboard (GPIO bit-bang), beanboardspi (hardware SPI)

* Repo clean-up and decoupling following extraction from Marvin:
  * `asm/drivers/*` flattened into `asm/`; `asm/console_beandeck.asm` renamed to `asm/console.asm`
  * `target/system.inc` removed; target-specific stub folded into `tests/main.asm`
  * `vars.asm` renamed to `environment.asm`
* Console made output-agnostic: USB `putchar`/`puts` references removed; input functions (`getchar`/`readchar`) removed from console module
* Configuration externalised: GPIO definitions, SPI port/value definitions, and RAM variable base address no longer hard-coded in library source
* External PUBLIC labels renamed with `RA8875_` prefixes to reduce symbol collision risk when linked into a larger project
* GPIO port specification simplified

* Transport files renamed and moved to `targets/` as target-specific assembly files:
  * `transport_gpio.asm` → `targets/beanboard.asm` (BeanBoard GPIO bit-bang SPI)
  * `transport_spi.asm` → `targets/beanboardspi.asm` (BeanBoardSPI hardware SPI)
* `target/` directory renamed to `targets/`; test entry point moved from `targets/` to `tests/`
* Bit-level GPIO pin and GPO state constants, and SPI control register values, moved from `environment.asm` into the transport files that own them; `environment.asm` now exports only RAM base address and port numbers
* `build.sh` updated to build both targets (`beanboard`, `beanboardspi`) in a single invocation; output hex named per target
* `ra8875_console_puts` removed from the library (caller responsibility)

* Console cursor positioning functions added:
  * `ra8875_console_cursor_x` — set cursor column from A (0..RA8875_COLS-1)
  * `ra8875_console_cursor_y` — set cursor row from A as a logical row (0 = top of visible area), accounting for scroll wrap
* Cursor control character constants exported as PUBLIC symbols: `RA8875_CONSOLE_CURSOR_ON` (0x0e), `RA8875_CONSOLE_CURSOR_OFF` (0x0f)
* Minor optimisation to console putchar path
