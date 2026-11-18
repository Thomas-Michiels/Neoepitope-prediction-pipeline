# RNA-seq filtering (HISAT2)

Sequential removal of reads mapping to rRNA, tRNA and sn-/snoRNA references.

## Files

- `filter_ncrna.sh`: one HISAT2 filtering script used for all three references; the reference is chosen with the index argument.
- `submit_filter_rrna.pbs`, `submit_filter_trna.pbs`, `submit_filter_snorna.pbs`: PBS wrappers that run `filter_ncrna.sh` with the rRNA, tRNA or sn/snoRNA index as default.

## Inputs and outputs

Each step accepts paired compressed FASTQs, a HISAT2 index prefix, and an output prefix. The paired unmapped reads are retained for the next stage, with filenames `<OUT>.fastq.1.gz` and `<OUT>.fastq.2.gz`.

Index defaults in PBS wrappers to be changed accordingly:
- `$VSC_DATA_VO/genomes/Hsapiens/rRNA/hisat2/hsa_rRNA.index`
- `$VSC_DATA_VO/genomes/Hsapiens/tRNA/hisat2/hsa_tRNA.index`
- `$VSC_DATA_VO/genomes/Hsapiens/sn-o-RNA/hisat2/hsa_sn-o-RNA.index`

Override any index with `INDEX=/path/to/index_prefix`.

## Software

HISAT2 2.2.1 (`HISAT2/2.2.1-gompi-2023a`).

## HPC resources

Each wrapper requests 48 CPUs, 80 GB RAM, 72 hours. 

## Submit with qsub

Run from the repository root. Example (replace paths with your own):

```bash
qsub -v R1=/path/R1_UMI_extracted_trimmed.fastq.gz,R2=/path/R2_UMI_extracted_trimmed.fastq.gz,OUT=/path/sample_rRNA_Filtered RNAseq/02_rna_filtering/submit_filter_rrna.pbs
```

When rRNA filtering finishes successfully:

```bash
qsub -v R1=/path/sample_rRNA_Filtered.fastq.1.gz,R2=/path/sample_rRNA_Filtered.fastq.2.gz,OUT=/path/sample_r-t-RNA_Filtered RNAseq/02_rna_filtering/submit_filter_trna.pbs
```

Then:

```bash
qsub -v R1=/path/sample_r-t-RNA_Filtered.fastq.1.gz,R2=/path/sample_r-t-RNA_Filtered.fastq.2.gz,OUT=/path/sample_r-t-sn-o-RNA_Filtered RNAseq/02_rna_filtering/submit_filter_snorna.pbs
```

For automatic scheduling, use `qsub -W depend=afterok:<previous_job_id>` on the second and third submissions, alongside `-v`.

## Run without PBS

```bash
bash RNAseq/02_rna_filtering/filter_ncrna.sh R1.fastq.gz R2.fastq.gz /path/hsa_rRNA.index /path/sample_rRNA_Filtered 16
```
