#!/usr/bin/env bash
set -euo pipefail

# Mutant peptide extraction and MHC class I binding prediction with MuPeXI.
# MuPeXI annotates the VCF with VEP and runs netMHCpan itself, using the paths in its config.ini.
# Usage: mupexi.sh <somatic.vcf> <HLA alleles, comma-separated> <peptide length(s), e.g. 9 or 8-11>
#                  <expression.tsv> <output_dir> <sample_name> <MuPeXI.py> <config.ini>
#                  [threads] [expression_level] [python]

VCF=$1
HLA=$2
PEPTIDE_LENGTH=$3
EXPRESSION_TSV=$4
OUTPUT_DIR=$5
SAMPLE_NAME=$6
MUPEXI_SCRIPT=$7
MUPEXI_CONFIG=$8
THREADS=${9:-48}
EXPRESSION_LEVEL=${10:-transcript}
PYTHON_BIN=${11:-python}

mkdir -p "$OUTPUT_DIR"

"$PYTHON_BIN" "$MUPEXI_SCRIPT" \
  -v "$VCF" \
  -a "$HLA" \
  -l "$PEPTIDE_LENGTH" \
  -e "$EXPRESSION_TSV" \
  -E "$EXPRESSION_LEVEL" \
  -d "$OUTPUT_DIR" \
  -p "${SAMPLE_NAME}_${PEPTIDE_LENGTH}mer" \
  -s human -F "$THREADS" -f -c "$MUPEXI_CONFIG" -t
