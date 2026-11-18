# WGS alignment (BWA-MEM)

This module aligns paired-end Illumina WGS reads to GRCh38, sorts the alignments into a BAM file, and creates its index. Run the same module separately for tumor and matched-normal samples

## Files

- `bwa_mem_alignment.sh`: reusable alignment, sorting, and indexing commands.
- `submit_alignment.pbs`: PBS wrapper to load modules and request resources.

## Inputs and outputs

Inputs: two paired-end FASTQ files (`R1`, `R2`), a BWA-indexed GRCh38 FASTA (`REF`), and a sample identifier (`SAMPLE`). The `OUT` argument specifies the sorted BAM output, and `TMP_PREFIX` specifies the temporary SAMtools sorting file prefix.

Outputs: coordinate-sorted BAM (`OUT`) and its index (`OUT.bai`).

## Software

Software:

- `BWA/0.7.18-GCCcore-13.2.0`
- `SAMtools/1.19.2-GCC-13.2.0`

The reference used in the original workflow is the BWA-indexed GRCh38/hg38 FASTA.

## HPC resources

The original PBS scripts requested 48 CPU cores, 60 GB memory, and 72 hours walltime for 100X coverage WGS data.

## Submit with qsub


```bash
REF="/path/to/hg38.fa"
R1="/path/to/tumor_R1.fastq.gz"
R2="/path/to/tumor_R2.fastq.gz"
SAMPLE="tumor_sample"
OUT="/path/to/output/tumor.sorted.bam"
TMP_PREFIX="/path/to/output/tmp/tumor_sort"

qsub -v "REF=$REF,R1=$R1,R2=$R2,SAMPLE=$SAMPLE,OUT=$OUT,TMP_PREFIX=$TMP_PREFIX" WGS/01_alignment/submit_alignment.pbs
```

Repeat the submission with the matched-normal FASTQ files, a distinct sample identifier, output BAM, and temporary prefix.

The default thread settings reproduce the original notebook commands. To override them, include `BWA_THREADS=32,SORT_THREADS=16` in the `qsub -v` argument. 

## Run without PBS

With BWA and SAMtools available in the environment:

```bash
bash WGS/01_alignment/bwa_mem_alignment.sh \
    /path/to/hg38.fa \
    /path/to/sample_R1.fastq.gz \
    /path/to/sample_R2.fastq.gz \
    sample_id \
    /path/to/output/sample.sorted.bam \
    /path/to/output/tmp/sample_sort \
    32 16
```
