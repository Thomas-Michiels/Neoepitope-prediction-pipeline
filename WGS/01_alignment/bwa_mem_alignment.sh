#!/bin/bash

# WGS alignment: run separately for tumor and matched normal samples.

REF="$1"
R1="$2"
R2="$3"
SAMPLE="$4"
OUT="$5"
TMP_PREFIX="$6"
BWA_THREADS="${7:-48}"
SORT_THREADS="${8:-48}"

mkdir -p "$(dirname "$OUT")" "$(dirname "$TMP_PREFIX")"

bwa mem -c 250 -M -t "$BWA_THREADS" \
    -R "@RG\tID:${SAMPLE}\tLB:WGS\tPL:illumina\tSM:${SAMPLE}\tPU:NovaSeqX" \
    -v 1 "$REF" "$R1" "$R2" \
    | samtools sort -@ "$SORT_THREADS" -m 256M -T "$TMP_PREFIX" -o "$OUT"

samtools index "$OUT"
