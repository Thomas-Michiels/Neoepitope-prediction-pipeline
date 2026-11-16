#!/usr/bin/env bash

r1=$1; r2=$2; idx=$3; splice=$4; out=$5; threads=$6; rg=$7; sample=$8; library=${9:-SMARTer_Total_RNA_Mammalian_Pico_Input}; pu=${10:-NovaSeqX}
mkdir -p "$(dirname "$out")"
hisat2 -x "$idx" -1 "$r1" -2 "$r2" -q \
  --un-conc-gz "${out}_unmapped.fastq.gz" \
  --known-splicesite-infile "$splice" \
  --rg-id "$rg" --rg "LB:$library" --rg PL:illumina --rg "SM:$sample" --rg "PU:$pu" \
  -p "$threads" -S "${out}_hisat2.sam"
