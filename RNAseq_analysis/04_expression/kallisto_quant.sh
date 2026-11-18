#!/usr/bin/env bash
set -euo pipefail

INDEX="$1"
R1="$2"
R2="$3"
OUT="$4"
THREADS="${5:-18}"

mkdir -p "$OUT"
kallisto quant --index="$INDEX" --output-dir="$OUT" --threads="$THREADS" --plaintext "$R1" "$R2"
