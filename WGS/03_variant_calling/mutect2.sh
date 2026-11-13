#!/bin/bash

REF="$1"
TUMOR_BAM="$2"
NORMAL_BAM="$3"
NORMAL_SAMPLE="$4"
OUT="$5"
JAVA_HEAP="${6:-56g}"

mkdir -p "$(dirname "$OUT")"
gatk --java-options "-Xmx${JAVA_HEAP}" Mutect2 \
    -R "$REF" \
    -I "$TUMOR_BAM" \
    -I "$NORMAL_BAM" \
    -normal "$NORMAL_SAMPLE" \
    -O "$OUT"
