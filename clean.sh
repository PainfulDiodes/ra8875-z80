#!/usr/bin/env bash

# Clean all build outputs

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTDIR="$SCRIPT_DIR/output"

if [ -d "$OUTDIR" ]; then
    echo "Cleaning output"
    rm -rf "$OUTDIR"
fi

# Clean assembler intermediate files
rm -f "$SCRIPT_DIR"/asm/*.lis "$SCRIPT_DIR"/asm/*.o
rm -f "$SCRIPT_DIR"/asm/drivers/*.lis "$SCRIPT_DIR"/asm/drivers/*.o
rm -f "$SCRIPT_DIR"/target/*.lis "$SCRIPT_DIR"/target/*.o
