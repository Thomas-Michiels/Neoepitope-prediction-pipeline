#!/usr/bin/env bash

INPUT="$1"
OUTPUT="$2"
STATS_PREFIX="${3:-}"

mkdir -p "$(dirname "$OUTPUT")"

if [ -n "$STATS_PREFIX" ]; then
    umi_tools dedup --paired -I "$INPUT" -S "$OUTPUT" --output-stats "$STATS_PREFIX"
else
    umi_tools dedup --paired -I "$INPUT" -S "$OUTPUT"
fi

samtools index "$OUTPUT"
