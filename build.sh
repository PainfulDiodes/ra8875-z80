#!/usr/bin/env bash

# Assembles all driver modules and links a test binary for each target:
# beanboard and beanboardspi. Each binary includes the target transport,
# general environment, ra8875 driver, console, and the tests main module.
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
RAM_START="${1:-0x8000}"

mkdir -p "$OUTDIR"

for target in beanboard beanboardspi; do
    echo "Building $target (RAM_START=${RAM_START})..."
    z88dk-z80asm -b -l -m -I"$REPO_DIR" -DRAM_START="${RAM_START}" \
        -o"$OUTDIR/${target}.bin" \
        "$REPO_DIR/tests/main.asm" \
        "$REPO_DIR/asm/ra8875.asm" \
        "$REPO_DIR/targets/${target}.asm" \
        "$REPO_DIR/asm/console.asm" \
        "$REPO_DIR/targets/environment.asm"

    z88dk-appmake +hex --org "${RAM_START}" \
        -b "$OUTDIR/${target}.bin" \
        -o "$OUTDIR/${target}.ihx"
done

echo ""
echo "All targets built successfully."
echo "Output: $OUTDIR"
