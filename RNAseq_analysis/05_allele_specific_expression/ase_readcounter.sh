#!/usr/bin/env bash
set -euo pipefail

REF=$1
BAM=$2
VCF=$3
OUT=$4
MIN_BQ=${5:-2}
MIN_MQ=${6:-10}

for file in "$REF" "$BAM" "$VCF"; do
  [[ -f "$file" ]] || { echo "Missing input: $file" >&2; exit 1; }
done
[[ -f "${BAM}.bai" || -f "${BAM%.bam}.bai" ]] || {
  echo "BAM index not found for $BAM" >&2
  exit 1
}

mkdir -p "$(dirname "$OUT")"

gatk ASEReadCounter \
  -R "$REF" \
  -I "$BAM" \
  -V "$VCF" \
  -O "$OUT" \
  --min-base-quality "$MIN_BQ" \
  --min-mapping-quality "$MIN_MQ"
