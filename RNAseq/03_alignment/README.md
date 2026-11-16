# Two-step RNA-seq alignment (HISAT2 → BWA-MEM)

First align paired-end filtered FASTQs with HISAT2, then realign HISAT2-unmapped pairs using BWA-MEM. Convert the HISAT2 SAM to BAM and combine filtered alignments into a coordinate-sorted, indexed BAM for downstream UMI deduplication.

## Files

- `hisat2_alignment.sh`, `submit_hisat2_alignment.pbs`: first alignment; emits SAM and unmapped `.fastq.1.gz` / `.fastq.2.gz`
- `sam_to_bam.sh`, `submit_sam_to_bam.pbs`: SAM → BAM
- `bwa_mem_alignment.sh`, `submit_bwa_mem_alignment.pbs`: second alignment
- `merge_alignments.sh`, `submit_merge_alignments.pbs`: filter, sort, merge, index

## Inputs and outputs

Use `R1`, `R2` from `02_rna_filtering`. HISAT2 requires an index prefix and known-splice-sites file. BWA-MEM requires a BWA-indexed genome FASTA. Set a unique `RG_ID` and `SAMPLE` for each sample. All output filenames are controlled by the caller.

HISAT2 produces `${OUT_PREFIX}_hisat2.sam` and `${OUT_PREFIX}_unmapped.fastq.1.gz` / `.fastq.2.gz`. Feed the latter pair to BWA-MEM. The merge step produces `OUTPUT_BAM` and its `.bai` index.

## Software

- HISAT2 2.2.1 (`HISAT2/2.2.1-gompi-2023a`)
- BWA-MEM 0.7.17 (`BWA/0.7.17-GCCcore-12.3.0`)
- SAMtools 1.18 (`SAMtools/1.18-GCC-12.3.0`)

## HPC resources

HISAT2: 48 CPUs, 40 GB, 72 h; SAM→BAM: 16 CPUs, 40 GB, 10 h; BWA-MEM: 48 CPUs, 60 GB, 24 h; merge: 16 CPUs, 40 GB, 48 h.

## Submit with qsub

Set `SCRIPT_DIR` to the absolute location of this folder and export all step-specific variables via `qsub -v` or an environment exported with `qsub -V`. Example:

```bash
export SCRIPT_DIR="$PWD/RNAseq/03_alignment"
export R1=/path/filtered.fastq.1.gz R2=/path/filtered.fastq.2.gz
export HISAT2_INDEX="$VSC_DATA_VO/genomes/Hsapiens/hg38/hisat2/Ensembl_v105/Homo_sapiens.hg38.105.Index"
export SPLICE_SITES=/data/gent/vo/001/gvo00101/vsc46293/Genomes/Ensembl_113/Known_splice_sites/Homo_sapiens.hg38.113.Known_Splice_Sites.txt
export OUT_PREFIX=/path/output/sample
export RG_ID=sample_RNA SAMPLE=RNA_sample
qsub -V "$SCRIPT_DIR/submit_hisat2_alignment.pbs"
```

After that job succeeds, set `INPUT_SAM` and `OUTPUT_BAM` and submit SAM→BAM; separately set `R1`/`R2` to the HISAT2 unmapped FASTQs and submit BWA-MEM. Finally set `HISAT2_BAM`, `BWA_BAM`, and `OUTPUT_BAM` and submit merge. Use `qsub -W depend=afterok:<jobid>` to enforce step dependencies.

## Run without PBS

```bash
bash hisat2_alignment.sh R1.gz R2.gz HISAT2_INDEX SPLICE_SITES out/sample 48 sample_rg sample_id
bash sam_to_bam.sh out/sample_hisat2.sam out/sample_hisat2.bam 16
bash bwa_mem_alignment.sh out/sample_unmapped.fastq.1.gz out/sample_unmapped.fastq.2.gz hg38.fa out/sample_bwa.bam 48 sample_rg sample_id
bash merge_alignments.sh out/sample_hisat2.bam out/sample_bwa.bam out/sample_merged.sorted.bam 16
```
