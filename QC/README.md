# Read quality control (FastQC)

Runs FastQC on a pair of raw FASTQ files. Use it for tumor WGS, matched-normal WGS and tumor RNA-seq reads before any other step.

## Files

- `fastqc.sh`: FastQC on R1 and R2.
- `submit_fastqc.pbs`: PBS wrapper.

## Inputs and outputs

Inputs: paired FASTQ files (`R1`, `R2`) and an output directory (`OUT_DIR`). Outputs: one HTML report and one ZIP archive per FASTQ file in `OUT_DIR`.

## Software

- `FastQC/0.12.1-Java-11` (check the name on your cluster with `module avail FastQC`)

## HPC resources

2 CPUs, 8 GB memory, 12 h walltime.

## Submit with qsub

```bash
qsub -v "R1=/path/sample_R1.fastq.gz,R2=/path/sample_R2.fastq.gz,OUT_DIR=/path/output/fastqc/sample" QC/submit_fastqc.pbs
```

## Run without PBS

```bash
bash QC/fastqc.sh /path/sample_R1.fastq.gz /path/sample_R2.fastq.gz /path/output/fastqc/sample 2
```
