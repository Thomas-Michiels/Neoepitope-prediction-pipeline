#!/usr/bin/env bash

# Usage: kallisto_quant.sh INDEX R1.fastq.gz R2.fastq.gz OUTPUT_DIR [THREADS]

INDEX=$1; R1=$2; R2=$3; OUT=$4; THREADS=${5:-18}
for f in "$INDEX" "$R1" "$R2"; do [[ -f "$f" ]] || { echo "Missing input: $f" >&2; exit 1; }; done
mkdir -p "$OUT"
kallisto quant --index="$INDEX" --output-dir="$OUT" --threads="$THREADS" --plaintext "$R1" "$R2"
