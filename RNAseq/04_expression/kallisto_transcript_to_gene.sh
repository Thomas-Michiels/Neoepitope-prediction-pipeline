#!/usr/bin/env bash

RSCRIPT="$1"
GTF="$2"
ABUNDANCE="$3"
OUTPUT="$4"

mkdir -p "$(dirname "$OUTPUT")"
Rscript "$RSCRIPT" --gtf_file="$GTF" --kallisto_transcript_matrix_in="$ABUNDANCE" --kallisto_transcript_matrix_out="$OUTPUT"
