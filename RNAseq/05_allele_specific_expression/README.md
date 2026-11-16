# Allele-specific expression — GATK ASEReadCounter

This module runs ASEReadCounter.

## Files
- `ase_readcounter.sh`: run GATK ASEReadCounter on an existing deduplicated RNA BAM and prepared variant VCF.
- `submit_ase_readcounter.pbs`: PBS submission wrapper.

## Inputs and outputs
- Reference FASTA (and its required GATK reference indices).
- Coordinate-sorted, indexed RNA BAM, preferably after UMI deduplication.
- Output tab file with reference and alternative read counts.

## Software and HPC resources
- GATK `4.4.0.0-GCCcore-12.3.0-Java-17` from the original RNA notebook.
- PBS: 1 CPU, 50 GB memory, 24 h walltime.
- Notebook thresholds: minimum base quality 2, minimum mapping quality 10.

## Submit with qsub
Run from the repository root; replace example paths with actual HPC paths:

```bash
qsub -v REF=/path/hg38.fa,BAM=/path/rna_dedup.bam,VCF=/path/prepared_variants.vcf.gz,OUT=/path/ase.tsv RNAseq/05_allele_specific_expression/submit_ase_readcounter.pbs
```

Optional: set `MIN_BQ` and `MIN_MQ` in the `-v` list.

## Run without PBS
```bash
module load GATK/4.4.0.0-GCCcore-12.3.0-Java-17
bash RNAseq/05_allele_specific_expression/ase_readcounter.sh \
  /path/hg38.fa /path/rna_dedup.bam /path/prepared_variants.vcf.gz \
  /path/ase.tsv 2 10
```
