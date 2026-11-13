#!/usr/bin/env bash

# Usage: bash filter_snorna.sh R1.fastq.gz R2.fastq.gz INDEX_PREFIX OUTPUT_PREFIX [THREADS] [SAM_OUTPUT]
# SAM_OUTPUT defaults to /dev/null to avoid very large contamination SAM files.

R1=$1
R2=$2
INDEX=$3
OUT=$4
THREADS=${5:-48}
SAM=${6:-/dev/null}
[[ -f "$R1" && -f "$R2" ]] || { echo "Input FASTQ missing" >&2; exit 1; }
[[ "$THREADS" =~ ^[1-9][0-9]*$ ]] || { echo "THREADS must be a positive integer" >&2; exit 1; }
mkdir -p "$(dirname "$OUT")"
hisat2 -x "$INDEX" \
  -1 "$R1" -2 "$R2" \
  -q --un-conc-gz "${OUT}.fastq.gz" \
  -p "$THREADS" -S "$SAM"
# HISAT2 writes paired outputs as ${OUT}.fastq.1.gz and ${OUT}.fastq.2.gz.
