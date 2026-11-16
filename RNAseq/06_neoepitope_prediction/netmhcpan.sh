#!/usr/bin/env bash

: "${PEPTIDE_FASTA:?Missing PEPTIDE_FASTA}"
: "${HLA:?Missing HLA}"
: "${PEPTIDE_LENGTH:?Missing PEPTIDE_LENGTH}"
: "${OUTPUT_FILE:?Missing OUTPUT_FILE}"
NETMHCPAN_BIN=${NETMHCPAN_BIN:-netMHCpan}

mkdir -p "$(dirname "$OUTPUT_FILE")"

"$NETMHCPAN_BIN" \
  -f "$PEPTIDE_FASTA" \
  -a "$HLA" \
  -l "$PEPTIDE_LENGTH" \
  -s -xls -xlsfile "$OUTPUT_FILE"
