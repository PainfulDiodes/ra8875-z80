#!/usr/bin/env bash

# Build script for ra8875 standalone repo.
# Assembles all driver modules and the reference console to verify they
# assemble cleanly. Produces .o files only (library, not a standalone ROM).
#
# Usage: ./build.sh [RAM_START]
# Examples:
#   ./build.sh           # test binary at 0x8000 (default)
#   ./build.sh 0x9000    # test binary at 0x9000
#
# Requires: z88dk (z88dk-z80asm, z88dk-appmake)

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

echo "  asm/console.asm (reference)"
z88dk-z80asm -l -m -I"$REPO_DIR" \
    -o"$OUTDIR/console.o" "$REPO_DIR/asm/console.asm"

# RAM test binary - assembles all modules together and links to a flat binary.
RAM_START="${1:-0x8000}"
echo ""
echo "Assembling test binary (RAM_START=${RAM_START})..."
z88dk-z80asm -b -l -m -I"$REPO_DIR" -DRAM_START="${RAM_START}" \
    -o"$OUTDIR/test_ra8875.bin" \
    "$REPO_DIR/asm/test/test_ra8875.asm" \
    "$REPO_DIR/asm/drivers/ra8875.asm" \
    "$REPO_DIR/asm/drivers/ra8875_spi.asm" \
    "$REPO_DIR/asm/console.asm" \
    "$REPO_DIR/asm/test/stubs.asm"

z88dk-appmake +hex --org "${RAM_START}" \
    -b "$OUTDIR/test_ra8875.bin" \
    -o "$OUTDIR/test_ra8875.ihx"

echo ""
echo "All modules assembled successfully."
echo "Output: $OUTDIR"
