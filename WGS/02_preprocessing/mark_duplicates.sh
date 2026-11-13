#!/bin/bash

INPUT_BAM="$1"
OUT="$2"
TMP_PREFIX="$3"
THREADS="${4:-1}"
mkdir -p "$(dirname "$OUT")" "$(dirname "$TMP_PREFIX")"
bamsormadup inputformat=bam threads="$THREADS" outputformat=bam SO=coordinate "tmpfile=$TMP_PREFIX" < "$INPUT_BAM" > "$OUT"
samtools index "$OUT"
