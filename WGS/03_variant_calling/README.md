# WGS variant calling, filtering and annotation

This module calls somatic variants from paired tumor and matched-normal WGS BAM files using GATK Mutect2, filters the calls and retains PASS variants, then annotates them with Ensembl VEP 113. 

## Files

- `mutect2.sh`: tumor–normal somatic variant calling with GATK Mutect2.
- `submit_mutect2.pbs`: PBS wrapper for Mutect2.
- `filter_mutect2_pass.sh`: GATK FilterMutectCalls followed by bcftools PASS selection.
- `submit_filter_mutect2_pass.pbs`: PBS wrapper for filtering and PASS selection.
- `annotate_vep.sh`: VEP annotation and bgzip compression.
- `submit_annotate_vep.pbs`: PBS wrapper for annotation.

## Inputs and outputs

Mutect2: BQSR-processed tumor BAM (`TUMOR_BAM`), matched-normal BAM (`NORMAL_BAM`), indexed GRCh38 FASTA (`REF`), and normal sample name in the BAM read-group SM field (`NORMAL_SAMPLE`). Outputs an unfiltered somatic VCF (`OUT`). 

Filtering: unfiltered Mutect2 VCF (`INPUT_VCF`) and reference (`REF`). Outputs a filtered VCF (`FILTERED_VCF`) and a PASS-only VCF (`PASS_VCF`).

Annotation: PASS-only VCF (`INPUT_VCF`), VEP merged cache directory (`CACHE_DIR`), reference FASTA (`REF`), output VCF.gz (`OUT`), and VEP statistics HTML (`STATS`).

## Software

Software:

- `GATK/4.6.0.0-GCCcore-13.2.0-Java-17`
- `BCFtools/1.18-GCC-12.3.0`
- `VEP/113.0-GCC-12.3.0`

## Submit with qsub

Run these commands from the repository root. Use absolute paths without commas in `qsub -v` values.

1. Call somatic variants:

```bash
SCRIPT="$(pwd)/WGS/03_variant_calling/mutect2.sh"
REF="/path/to/hg38.fa"
TUMOR_BAM="/path/to/tumor.recal.bam"
NORMAL_BAM="/path/to/normal.recal.bam"
NORMAL_SAMPLE="normal_sample_id"
OUT="/path/to/output/mutect2.vcf"

qsub -v "SCRIPT=$SCRIPT,REF=$REF,TUMOR_BAM=$TUMOR_BAM,NORMAL_BAM=$NORMAL_BAM,NORMAL_SAMPLE=$NORMAL_SAMPLE,OUT=$OUT" WGS/03_variant_calling/submit_mutect2.pbs
```

2. Filter calls and retain PASS variants:

```bash
SCRIPT="$(pwd)/WGS/03_variant_calling/filter_mutect2_pass.sh"
INPUT_VCF="/path/to/output/mutect2.vcf"
FILTERED_VCF="/path/to/output/mutect2.filtered.vcf"
PASS_VCF="/path/to/output/mutect2.filtered.PASS.vcf"

qsub -v "SCRIPT=$SCRIPT,REF=$REF,INPUT_VCF=$INPUT_VCF,FILTERED_VCF=$FILTERED_VCF,PASS_VCF=$PASS_VCF" WGS/03_variant_calling/submit_filter_mutect2_pass.pbs
```

3. Annotate with VEP:

```bash
SCRIPT="$(pwd)/WGS/03_variant_calling/annotate_vep.sh"
INPUT_VCF="/path/to/output/mutect2.filtered.PASS.vcf"
OUT="/path/to/output/mutect2.filtered.PASS.vep.vcf.gz"
STATS="/path/to/output/mutect2.vep.html"
CACHE_DIR="/path/to/vep/cache"
REF="/path/to/hg38.fa"

qsub -v "SCRIPT=$SCRIPT,INPUT_VCF=$INPUT_VCF,OUT=$OUT,STATS=$STATS,CACHE_DIR=$CACHE_DIR,REF=$REF" WGS/03_variant_calling/submit_annotate_vep.pbs
```

Submit each step only after the previous job succeeds. For automated ordering, use PBS job dependencies, e.g. `qsub -W depend=afterok:JOBID ...`.

## Run without PBS

With GATK, bcftools, VEP, and bgzip available in the environment:

```bash
bash WGS/03_variant_calling/mutect2.sh \
    /path/to/hg38.fa /path/to/tumor.recal.bam /path/to/normal.recal.bam \
    normal_sample_id /path/to/output/mutect2.vcf

bash WGS/03_variant_calling/filter_mutect2_pass.sh \
    /path/to/hg38.fa /path/to/output/mutect2.vcf \
    /path/to/output/mutect2.filtered.vcf /path/to/output/mutect2.filtered.PASS.vcf

bash WGS/03_variant_calling/annotate_vep.sh \
    /path/to/output/mutect2.filtered.PASS.vcf \
    /path/to/output/mutect2.filtered.PASS.vep.vcf.gz \
    /path/to/output/mutect2.vep.html /path/to/vep/cache /path/to/hg38.fa 16
```
