#!/usr/bin/env bash

# Uses the original external R script; supply its path explicitly.
if (( $# != 4 )); then echo "Usage: $0 TXIMPORT_R_SCRIPT GTF ABUNDANCE_TSV GENE_OUTPUT_TSV" >&2; exit 2; fi
RSCRIPT=$1; GTF=$2; ABUNDANCE=$3; OUTPUT=$4
for f in "$RSCRIPT" "$GTF" "$ABUNDANCE"; do [[ -f "$f" ]] || { echo "Missing input: $f" >&2; exit 1; }; done
mkdir -p "$(dirname "$OUTPUT")"
Rscript "$RSCRIPT" --gtf_file="$GTF" --kallisto_transcript_matrix_in="$ABUNDANCE" --kallisto_transcript_matrix_out="$OUTPUT"
