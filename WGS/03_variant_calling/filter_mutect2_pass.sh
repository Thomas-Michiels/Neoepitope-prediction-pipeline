#!/usr/bin/env bash
set -euo pipefail

REF="$1"
INPUT_VCF="$2"
FILTERED_VCF="$3"
PASS_VCF="$4"

mkdir -p "$(dirname "$FILTERED_VCF")" "$(dirname "$PASS_VCF")"
gatk FilterMutectCalls \
    -V "$INPUT_VCF" \
    -R "$REF" \
    -O "$FILTERED_VCF"

bcftools view -f PASS -Ov -o "$PASS_VCF" "$FILTERED_VCF"
