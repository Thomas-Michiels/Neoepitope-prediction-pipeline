#!/bin/bash

R1="${1:?Provide R1 FASTQ}"
R2="${2:?Provide R2 FASTQ}"
OUT_R1="${3:?Provide output R1 FASTQ}"
OUT_R2="${4:?Provide output R2 FASTQ}"
BC_PATTERN="${5:-NNNNNNNNXXXXXX}"

# UMI/barcode pattern is extracted from original Read 2.
umi_tools extract \
    --bc-pattern="$BC_PATTERN" \
    --stdin="${R2}" \
    --stdout="${OUT_R2}" \
    --read2-in="${R1}" \
    --read2-out="${OUT_R1}"
