# HLA typing (HLA-HD)

This module performs HLA typing from paired-end Illumina WGS FASTQ files using HLA-HD 1.7.0. Run the same module separately for tumor and matched-normal samples. 

## Files

- `hla_hd.sh`: reusable HLA-HD typing command.
- `submit_hla_hd.pbs`: PBS wrapper to load Bowtie2 and request HPC resources.

## Inputs and outputs

Inputs: paired-end FASTQ files (`R1`, `R2`), a sample identifier (`SAMPLE`), an output directory (`OUT_DIR`), and the HLA-HD installation directory (`HLAHD_ROOT`). `THREADS` controls the HLA-HD thread count.

Outputs: HLA-HD typing results under `OUT_DIR`, in a sample-specific results directory created by HLA-HD.

## Software

Software:

- `HLA-HD 1.7.0` (installed under `$VSC_DATA_VO/Shared_Software/hlahd.1.7.0`)
- `Bowtie2/2.5.4-GCC-13.2.0`

The HLA-HD installation must contain `bin/hlahd.sh`, `freq_data/`, `HLA_gene.split.txt`, and `dictionary/`.

## HPC resources

The tumor and healthy PBS scripts requested 18 CPU cores, 30 GB memory, and 48 hours walltime. 

## Submit with qsub

From the repository root on the HPC:

```bash
R1="/path/to/normal_R1.fastq.gz"
R2="/path/to/normal_R2.fastq.gz"
SAMPLE="normal_sample"
OUT_DIR="/path/to/output/HLA"

qsub -v "R1=$R1,R2=$R2,SAMPLE=$SAMPLE,OUT_DIR=$OUT_DIR" WGS/04_HLA_typing/submit_hla_hd.pbs
```

Repeat with tumor FASTQs and a distinct `SAMPLE` and `OUT_DIR` if tumor HLA typing is also required. The wrapper uses 18 threads by default. To override, add `THREADS=12` to the `qsub -v` string. To specify another installation, add `HLAHD_ROOT=/path/to/hlahd.1.7.0`.

## Run without PBS

With Bowtie2 and HLA-HD dependencies available in the environment:

```bash
bash WGS/04_HLA_typing/hla_hd.sh \
    /path/to/normal_R1.fastq.gz \
    /path/to/normal_R2.fastq.gz \
    normal_sample \
    /path/to/output/HLA \
    /path/to/hlahd.1.7.0 \
    18
```
