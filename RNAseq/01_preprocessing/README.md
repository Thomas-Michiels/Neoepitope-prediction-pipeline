# RNA-seq preprocessing (UMI-tools and Cutadapt)

This module extracts UMIs and optional cell barcodes from paired-end Illumina RNA-seq reads, then trims sequencing adapters. Choose the UMI extraction script according to which original read contains the barcode sequence.

## Files

- `umi_extraction_read1.sh`: extract the pattern from original Read 1.
- `submit_umi_extraction_read1.pbs`: PBS wrapper for Read 1 extraction.
- `umi_extraction_read2.sh`: extract the pattern from original Read 2.
- `submit_umi_extraction_read2.pbs`: PBS wrapper for Read 2 extraction.
- `adapter_trimming.sh`: Cutadapt trimming script.
- `submit_adapter_trimming.pbs`: PBS wrapper for Cutadapt.

## Inputs and outputs

UMI inputs: paired FASTQ files (`R1`, `R2`), output FASTQ paths (`OUT_R1`, `OUT_R2`) and an optional `BC_PATTERN`.

UMI outputs: paired FASTQ files with UMI/barcode information extracted and recorded in the read identifiers according to UMI-tools conventions.

In the UMI-tools string-pattern syntax, `N` is a UMI base, `C` is a cell-barcode base and `X` is a base to discard. For example, `NNNNNNNNXXXXXX` means an 8-base UMI followed by 6 discarded bases; it **does not** define a cell barcode. The default pattern is `NNNNNNNNXXXXXX` for both scripts, but the pattern should match the library preparation protocol.

## Software

- `UMI-tools/1.1.4-foss-2023a`
- Cutadapt 5.0 (see trimming script and PBS wrapper)

## HPC resources

The original UMI extraction PBS script requested 1 CPU, 20 GB memory and 24 hours walltime.

## Submit with qsub

For UMIs defined through SMARTer® Stranded Total RNA-Seq Kit v3 - Pico Input Mammalian:

```bash
SCRIPT="$(pwd)/RNAseq/01_preprocessing/umi_extraction_read2.sh"
R1="/path/to/sample_R1.fastq.gz"
R2="/path/to/sample_R2.fastq.gz"
OUT_R1="/path/to/sample_R1_UMI_extracted.fastq.gz"
OUT_R2="/path/to/sample_R2_UMI_extracted.fastq.gz"
BC_PATTERN="NNNNNNNNXXXXXX"

qsub -v "SCRIPT=$SCRIPT,R1=$R1,R2=$R2,OUT_R1=$OUT_R1,OUT_R2=$OUT_R2,BC_PATTERN=$BC_PATTERN" RNAseq/01_preprocessing/submit_umi_extraction_read2.pbs
```

For UMIs on Read 1, use `umi_extraction_read1.sh` and `submit_umi_extraction_read1.pbs` with the same arguments.

To define a cell barcode, adapt the pattern to the actual library design, for example `CCCCNNNNNNNN` for a 4-base cell barcode followed by an 8-base UMI. Do not use this example unless it matches the reads.

## Run without PBS

With UMI-tools available in the environment:

```bash
bash RNAseq/01_preprocessing/umi_extraction_read2.sh \
    /path/to/sample_R1.fastq.gz \
    /path/to/sample_R2.fastq.gz \
    /path/to/output_R1.fastq.gz \
    /path/to/output_R2.fastq.gz \
    NNNNNNNNXXXXXX
```

Adapter trimming is performed separately with `adapter_trimming.sh` and `submit_adapter_trimming.pbs`.
