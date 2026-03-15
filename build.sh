#!/usr/bin/env bash

# Build script for ra8875 standalone repo.
# Assembles all driver modules and the reference console to verify they
# assemble cleanly. Produces .o files only (library, not a standalone ROM).
#
# Requires: z88dk (z88dk-z80asm)

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="$REPO_DIR/output"

mkdir -p "$OUTDIR"

echo "Assembling ra8875 modules..."
for module in ra8875 ra8875_spi ra8875_gpio; do
    echo "  asm/drivers/$module.asm"
    z88dk-z80asm -l -m -I"$REPO_DIR" \
        -o"$OUTDIR/$module.o" "$REPO_DIR/asm/drivers/$module.asm"
done

echo "  asm/console_beandeck.asm (reference)"
z88dk-z80asm -l -m -I"$REPO_DIR" \
    -o"$OUTDIR/console_beandeck.o" "$REPO_DIR/asm/console_beandeck.asm"

echo ""
echo "All modules assembled successfully."
echo "Output: $OUTDIR"
