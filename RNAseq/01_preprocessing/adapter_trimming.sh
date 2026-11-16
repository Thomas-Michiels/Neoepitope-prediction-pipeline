#!/bin/bash

R1="$1"
R2="$2"
OUT_R1="$3"
OUT_R2="$4"

cutadapt \
    -a AGATCGGAAGAGC \
    -A AGATCGGAAGAGC \
    -q 20 \
    -m 20 \
    -j 0 \
    -o "$OUT_R1" \
    -p "$OUT_R2" \
    "$R1" \
    "$R2"
