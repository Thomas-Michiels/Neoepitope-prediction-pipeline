# RNA-seq UMI deduplication and expression analysis

1. `umi_deduplication.sh`: UMI-tools `dedup --paired` on the merged, coordinate-sorted BAM. UMI information must already be encoded in read names by the extraction step and retained through alignment.
2. `bam_to_fastq.sh`: name-collate the deduplicated BAM and export paired-end FASTQs using SAMtools. Only paired primary alignments are exported; singleton/other reads are discarded.
3. `kallisto_quant.sh`: paired-end Kallisto quantification (`--plaintext`) against a configurable transcriptome index.
4. `kallisto_transcript_to_gene.sh`: call the R script to summarize transcript-level abundances to gene level.

## Files

Each `.sh` has a corresponding `submit_*.pbs` wrapper. PBS wrappers accept environment variables via `qsub -v` and can be submitted independently with `afterok` dependencies.

## Inputs and outputs

- Dedup: merged coordinate-sorted BAM → deduplicated BAM and `.bai` (optional UMI stats).
- BAM to FASTQ: deduplicated BAM → `R1.fastq.gz` and `R2.fastq.gz`.
- Kallisto: index + paired FASTQs → `abundance.tsv`, `abundance.h5`, `run_info.json` in output directory.
- Transcript to gene: GTF + `abundance.tsv` → gene-level TSV, using `kallisto_gene_matrix_tximport_2.R` from this folder (override with `TXIMPORT_R_SCRIPT`).


## Submit with qsub

Run from the repository root. Use absolute input/output paths and replace placeholders:

```bash
qsub -v INPUT_BAM=/path/merged.sorted.bam,OUTPUT_BAM=/path/merged.dedup.bam RNAseq/04_expression/submit_umi_deduplication.pbs
qsub -v INPUT_BAM=/path/merged.dedup.bam,R1_FASTQ=/path/dedup_R1.fastq.gz,R2_FASTQ=/path/dedup_R2.fastq.gz RNAseq/04_expression/submit_bam_to_fastq.pbs
qsub -v KALLISTO_INDEX=/path/transcriptome.idx,R1_FASTQ=/path/dedup_R1.fastq.gz,R2_FASTQ=/path/dedup_R2.fastq.gz,OUTPUT_DIR=/path/kallisto RNAseq/04_expression/submit_kallisto_quant.pbs
qsub -v GTF_FILE=/path/annotation.gtf,ABUNDANCE_TSV=/path/kallisto/abundance.tsv,GENE_OUTPUT_TSV=/path/kallisto/gene_level_abundance.tsv RNAseq/04_expression/submit_kallisto_transcript_to_gene.pbs
```

Submit in order or use `qsub -W depend=afterok:JOB_ID ...` for each downstream step.

## Run without PBS

```bash
bash RNAseq/04_expression/umi_deduplication.sh merged.sorted.bam merged.dedup.bam
bash RNAseq/04_expression/bam_to_fastq.sh merged.dedup.bam dedup_R1.fastq.gz dedup_R2.fastq.gz 4
bash RNAseq/04_expression/kallisto_quant.sh transcriptome.idx dedup_R1.fastq.gz dedup_R2.fastq.gz kallisto_output 18
bash RNAseq/04_expression/kallisto_transcript_to_gene.sh RNAseq/04_expression/kallisto_gene_matrix_tximport_2.R annotation.gtf kallisto_output/abundance.tsv kallisto_output/gene_level_abundance.tsv
```
