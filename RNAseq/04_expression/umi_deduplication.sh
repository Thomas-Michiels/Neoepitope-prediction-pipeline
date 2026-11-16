#!/usr/bin/env bash
set -euo pipefail
# Usage: umi_deduplication.sh INPUT.sorted.bam OUTPUT.dedup.bam [STATS_PREFIX]
if (( $# < 2 || $# > 3 )); then echo "Usage: $0 INPUT.sorted.bam OUTPUT.dedup.bam [STATS_PREFIX]" >&2; exit 2; fi
INPUT=$1; OUTPUT=$2
[[ -f "$INPUT" ]] || { echo "Missing BAM: $INPUT" >&2; exit 1; }
mkdir -p "$(dirname "$OUTPUT")"
args=(dedup --paired -I "$INPUT" -S "$OUTPUT")
if (( $# == 3 )); then args+=(--output-stats "$3"); fi
umi_tools "${args[@]}"
samtools index "$OUTPUT"
