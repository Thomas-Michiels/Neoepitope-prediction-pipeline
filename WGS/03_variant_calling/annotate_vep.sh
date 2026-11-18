#!/usr/bin/env bash
set -euo pipefail

INPUT_VCF="$1"
OUT="$2"
STATS="$3"
CACHE_DIR="$4"
REF="$5"
FORKS="${6:-16}"

mkdir -p "$(dirname "$OUT")" "$(dirname "$STATS")"
vep --vcf -o stdout -i "$INPUT_VCF" \
    --fork "$FORKS" --buffer_size 50 --species homo_sapiens \
    --stats_file "$STATS" \
    --cache --offline --dir "$CACHE_DIR" \
    --symbol --numbers --biotype --total_length --canonical --gene_phenotype --ccds --uniprot --domains \
    --regulatory --protein --tsl --appris --af --max_af --af_1kg --af_gnomad --pubmed --variant_class --allele_number \
    --fasta "$REF" \
    --sift b --polyphen b --hgvs --shift_hgvs 1 --merged --pick \
    | sed '/^#/! s/;;/;/g' | bgzip -c > "$OUT"
