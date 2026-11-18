#!/usr/bin/env bash
set -euo pipefail

R1="${1:?Provide R1 FASTQ}"
R2="${2:?Provide R2 FASTQ}"
SAMPLE="${3:?Provide sample identifier}"
OUT_DIR="${4:?Provide output directory}"
HLAHD_ROOT="${5:?Provide HLA-HD installation directory}"
THREADS="${6:-18}"

mkdir -p "$OUT_DIR"
export PATH="$HLAHD_ROOT/bin:$PATH"

"$HLAHD_ROOT/bin/hlahd.sh" \
    -t "$THREADS" \
    -f "$HLAHD_ROOT/freq_data/" \
    "$R1" \
    "$R2" \
    "$HLAHD_ROOT/HLA_gene.split.txt" \
    "$HLAHD_ROOT/dictionary/" \
    "$SAMPLE" \
    "$OUT_DIR"
