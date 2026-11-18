#!/usr/bin/env bash
set -euo pipefail

R1="$1"
R2="$2"
OUT_R1="$3"
OUT_R2="$4"
THREADS="${5:-1}"

cutadapt \
    -a AGATCGGAAGAGC \
    -A AGATCGGAAGAGC \
    -q 20 \
    -m 20 \
    -j "$THREADS" \
    -o "$OUT_R1" \
    -p "$OUT_R2" \
    "$R1" \
    "$R2"
