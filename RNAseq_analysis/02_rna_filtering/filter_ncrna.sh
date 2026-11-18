#!/usr/bin/env bash
set -euo pipefail

# Remove reads that align to a non-coding RNA reference (rRNA, tRNA or sn/snoRNA).
# Read pairs that do NOT align concordantly are kept as <OUT>.fastq.1.gz / <OUT>.fastq.2.gz.
# Usage: filter_ncrna.sh <R1.fastq.gz> <R2.fastq.gz> <hisat2_index_prefix> <out_prefix> [threads] [sam_output]

R1=$1
R2=$2
INDEX=$3
OUT=$4
THREADS=${5:-48}
SAM=${6:-/dev/null}

mkdir -p "$(dirname "$OUT")"
hisat2 -x "$INDEX" \
  -1 "$R1" -2 "$R2" \
  -q --un-conc-gz "${OUT}.fastq.gz" \
  -p "$THREADS" -S "$SAM"
