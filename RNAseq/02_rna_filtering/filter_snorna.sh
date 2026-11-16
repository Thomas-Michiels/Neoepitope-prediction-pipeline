#!/usr/bin/env bash

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
