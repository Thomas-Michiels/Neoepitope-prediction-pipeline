#!/usr/bin/env bash
set -euo pipefail

# Stand-alone netMHCpan prediction for any peptide FASTA (for example non-canonical peptides).
# Usage: netmhcpan.sh <peptides.fasta> <HLA alleles, comma-separated> <peptide length(s)> <output.xls> [netMHCpan binary]

PEPTIDE_FASTA=$1
HLA=$2
PEPTIDE_LENGTH=$3
OUTPUT_FILE=$4
NETMHCPAN_BIN=${5:-netMHCpan}

mkdir -p "$(dirname "$OUTPUT_FILE")"

"$NETMHCPAN_BIN" \
  -f "$PEPTIDE_FASTA" \
  -a "$HLA" \
  -l "$PEPTIDE_LENGTH" \
  -s -xls -xlsfile "$OUTPUT_FILE"
