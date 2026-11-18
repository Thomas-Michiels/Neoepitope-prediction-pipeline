#!/usr/bin/env bash
set -euo pipefail

# Quality control of a pair of FASTQ files with FastQC.
# Usage: fastqc.sh <R1.fastq.gz> <R2.fastq.gz> <output_dir> [threads]

R1=$1
R2=$2
OUT_DIR=$3
THREADS=${4:-2}

mkdir -p "$OUT_DIR"
fastqc --threads "$THREADS" --outdir "$OUT_DIR" "$R1" "$R2"
