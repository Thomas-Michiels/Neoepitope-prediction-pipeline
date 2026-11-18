#!/usr/bin/env bash
set -euo pipefail

INPUT_BAM="$1"
REF="$2"
MILLS="$3"
SNPS="$4"
DBSNP="$5"
TABLE="$6"
OUT="$7"
JAVA_HEAP="${8:-4g}"
mkdir -p "$(dirname "$TABLE")" "$(dirname "$OUT")"
gatk --java-options "-Xmx${JAVA_HEAP}" BaseRecalibrator \
    -R "$REF" \
    -I "$INPUT_BAM" \
    --known-sites "$MILLS" \
    --known-sites "$SNPS" \
    --known-sites "$DBSNP" \
    -O "$TABLE"
gatk ApplyBQSR \
    -R "$REF" \
    -I "$INPUT_BAM" \
    --bqsr-recal-file "$TABLE" \
    -O "$OUT"
samtools index "$OUT"
