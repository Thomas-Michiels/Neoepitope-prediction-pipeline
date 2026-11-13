#!/usr/bin/env bash
# Usage: bwa_mem_alignment.sh UNMAPPED_R1 UNMAPPED_R2 BWA_REFERENCE OUTPUT.bam THREADS RG_ID SAMPLE [LIBRARY] [PLATFORM_UNIT]

r1=$1; r2=$2; ref=$3; out=$4; threads=$5; rg=$6; sample=$7; library=${8:-SMARTer_Total_RNA_Mammalian_Pico_Input}; pu=${9:-NovaSeqX}
mkdir -p "$(dirname "$out")"
bwa mem -c 250 -M -t "$threads" -v 1 -R "@RG\\tID:${rg}\\tLB:${library}\\tPL:illumina\\tSM:${sample}\\tPU:${pu}" \
  "$ref" "$r1" "$r2" | samtools view -@ "$threads" -b -o "$out" -
