# WGS preprocessing (duplicate marking and BQSR)

This module marks duplicate reads in coordinate-sorted WGS BAM files and performs Base Quality Score Recalibration (BQSR). Run the same workflow separately for tumor and matched-normal samples.

## Files

- `mark_duplicates.sh`: duplicate marking with biobambam2 and BAM indexing.
- `submit_mark_duplicates.pbs`: PBS wrapper for duplicate marking.
- `bqsr.sh`: GATK BaseRecalibrator, ApplyBQSR, and BAM indexing.
- `submit_bqsr.pbs`: PBS wrapper for BQSR.

## Inputs and outputs

Duplicate marking: coordinate-sorted BAM (`INPUT_BAM`), output BAM (`OUT`), and sorting temporary prefix (`TMP_PREFIX`). Outputs duplicate-marked BAM (`OUT`) and index (`OUT.bai`).

BQSR: duplicate-marked BAM (`INPUT_BAM`), GRCh38 reference (`REF`), known-sites VCFs (`MILLS`, `SNPS`, `DBSNP`), recalibration table (`TABLE`), and recalibrated BAM (`OUT`). Outputs recalibration table, recalibrated BAM, and index.

## Software

Software:

- `biobambam2/2.0.185-GCC-12.3.0`
- `SAMtools/1.19.2-GCC-13.2.0` (BQSR)
- `GATK/4.6.0.0-GCCcore-13.2.0-Java-17`

The reference and known-sites VCFs must be indexed as required by GATK.

## HPC resources

Around 60GB RAM and 48 hours are recommended for 100X WGS datasets, however this process can be made more time-efficient through splitting the BAM file per chromosome and performing pre-processing in parallel.

## Submit with qsub

From the repository root, set full paths. `qsub -v` values must not contain commas.

1. Mark duplicates on the complete aligned BAM:

```bash
INPUT_BAM="/path/to/sample.sorted.bam"
OUT="/path/to/sample.markdup.bam"
TMP_PREFIX="/path/to/tmp/sample_markdup"

qsub -v "INPUT_BAM=$INPUT_BAM,OUT=$OUT,TMP_PREFIX=$TMP_PREFIX" WGS/02_preprocessing/submit_mark_duplicates.pbs
```

2. Apply BQSR to the complete duplicate-marked BAM:

```bash
INPUT_BAM="/path/to/sample.markdup.bam"
REF="/path/to/hg38.fa"
MILLS="/path/to/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz"
SNPS="/path/to/1000G_phase1.snps.high_confidence.hg38.vcf.gz"
DBSNP="/path/to/dbsnp-151.vcf.gz"
TABLE="/path/to/sample.recal.table"
OUT="/path/to/sample.recal.bam"

qsub -v "INPUT_BAM=$INPUT_BAM,REF=$REF,MILLS=$MILLS,SNPS=$SNPS,DBSNP=$DBSNP,TABLE=$TABLE,OUT=$OUT" WGS/02_preprocessing/submit_bqsr.pbs
```

Submit BQSR only after duplicate marking finishes successfully. Repeat with separate tumor and matched-normal paths. PBS supports job dependencies using `qsub -W depend=afterok:JOBID`.

## Run without PBS

With the software available in your environment:

```bash
bash WGS/02_preprocessing/mark_duplicates.sh \
    /path/to/sample.sorted.bam \
    /path/to/sample.markdup.bam \
    /path/to/tmp/sample_markdup \
    1

bash WGS/02_preprocessing/bqsr.sh \
    /path/to/sample.markdup.bam \
    /path/to/hg38.fa \
    /path/to/Mills_indels.vcf.gz \
    /path/to/1000G_snps.vcf.gz \
    /path/to/dbsnp-151.vcf.gz \
    /path/to/sample.recal.table \
    /path/to/sample.recal.bam \
    4g
```
