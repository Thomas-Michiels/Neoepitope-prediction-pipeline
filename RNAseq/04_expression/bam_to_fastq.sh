#!/usr/bin/env bash

# Usage: bam_to_fastq.sh INPUT.dedup.bam OUTPUT_R1.fastq.gz OUTPUT_R2.fastq.gz [THREADS]
INPUT=$1; R1=$2; R2=$3; THREADS=${4:-1}
[[ -f "$INPUT" ]] || { echo "Missing BAM: $INPUT" >&2; exit 1; }
mkdir -p "$(dirname "$R1")" "$(dirname "$R2")"
# Name-collate before paired FASTQ output; coordinate-sorted input is not sufficient.
samtools collate -u -@ "$THREADS" -O "$INPUT" | samtools fastq -@ "$THREADS" -n -f 1 -F 0x900 -1 "$R1" -2 "$R2" -0 /dev/null -s /dev/null -
