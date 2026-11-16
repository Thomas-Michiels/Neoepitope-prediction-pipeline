#!/usr/bin/env bash

# Called by submit_mupexi.pbs. All settings are defined there.
: "${MUPEXI_SCRIPT:?Missing MUPEXI_SCRIPT}"
: "${VCF:?Missing VCF}"
: "${HLA:?Missing HLA}"
: "${PEPTIDE_LENGTH:?Missing PEPTIDE_LENGTH}"
: "${EXPRESSION_TSV:?Missing EXPRESSION_TSV}"
: "${OUTPUT_DIR:?Missing OUTPUT_DIR}"
: "${SAMPLE_NAME:?Missing SAMPLE_NAME}"
: "${MUPEXI_CONFIG:?Missing MUPEXI_CONFIG}"

THREADS=${THREADS:-48}
EXPRESSION_LEVEL=${EXPRESSION_LEVEL:-transcript}
PYTHON_BIN=${PYTHON_BIN:-python}

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
