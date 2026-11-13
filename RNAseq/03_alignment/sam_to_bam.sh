#!/usr/bin/env bash

# Usage: sam_to_bam.sh INPUT.sam OUTPUT.bam THREADS
samtools view -@ "$3" -b -o "$2" "$1"
