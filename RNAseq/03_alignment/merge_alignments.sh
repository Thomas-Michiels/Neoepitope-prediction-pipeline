#!/usr/bin/env bash
set -euo pipefail

hisat=$1; bwa=$2; out=$3; threads=$4
mkdir -p "$(dirname "$out")"
tmp=$(mktemp -d "$(dirname "$out")/.merge_alignments.XXXXXXXX")

# Preserve notebook MAPQ >= 10 for HISAT2; exclude unmapped, secondary and supplementary alignments.
samtools view -@ "$threads" -b -q 10 -F 0x904 -o "$tmp/hisat.bam" "$hisat"
# Preserve notebook's BWA exclusion of XA and SA tags and requirement for proper pairs.
# awk retains BAM header and discards XA:Z and SA:Z alignments.
samtools view -@ "$threads" -h -f 0x2 -F 0x904 "$bwa" | \
  awk 'BEGIN{FS="\t"} /^@/{print;next} {bad=0;for(i=12;i<=NF;i++)if($i ~ /^(XA|SA):Z:/){bad=1;break} if(!bad)print}' | \
  samtools view -@ "$threads" -b -o "$tmp/bwa.bam" -
samtools sort -@ "$threads" -o "$tmp/hisat.sorted.bam" "$tmp/hisat.bam"
samtools sort -@ "$threads" -o "$tmp/bwa.sorted.bam" "$tmp/bwa.bam"
samtools merge -@ "$threads" -f "$tmp/merged.bam" "$tmp/hisat.sorted.bam" "$tmp/bwa.sorted.bam"
samtools sort -@ "$threads" -o "$out" "$tmp/merged.bam"
samtools index -@ "$threads" "$out"
