# Neoepitope Prediction Pipeline

A bioinformatics workflow for the identification of tumor-specific neoepitopes using whole-genome sequencing (WGS) and RNA sequencing (RNA-seq) data.

## 1. Overview

Neoepitopes are tumor-specific peptides derived from somatic alterations that can be presented by human leukocyte antigen (HLA) molecules and potentially recognized by T cells. Their identification is a necessary step in the development of personalized cancer immunotherapies, including therapeutic cancer vaccines.

This repository contains bioinformatics scripts used to identify, characterize, and prioritize candidate neoepitopes by integrating genomic and transcriptomic datasets.

This workflow combines:

- Whole-genome sequencing (WGS): Identification of somatic variants by comparing tumor and matched normal DNA.
- RNA sequencing (RNA-seq): Assessment of gene-level and transcript-level expression supporting candidate neoepitopes.
- HLA typing: Identification of patient-specific HLA alleles occurs on both DNA and RNA level.
- Neoepitope prediction: Generation of all possible mutant peptides arising from patient-specific somatic variants and prediction of their binding to patient-specific HLA molecules.

## 2. Sequencing Data and Library Preparation

The workflow is primarily designed for paired-end sequencing data generated from tumor tissue and matched normal samples.

### 2.1 Whole-Genome Sequencing

Whole-genome sequencing should be performed on DNA extracted from tumor samples and matched normal material, such as peripheral blood.

The workflow is designed for Illumina paired-end short-read WGS data, such as libraries generated using the KAPA EvoPlus library preparation workflow.

Tumor and matched normal sequencing data are analyzed together to distinguish somatic alterations from inherited genetic variation.

### 2.2 RNA Sequencing

RNA sequencing is used to investigate transcriptional activity in tumor samples and determine whether genes carrying somatic variants are expressed.

The RNA-seq workflow scripts are designed for libraries generated using the SMARTer Stranded Total RNA-Seq Kit v3 – Pico Input Mammalian, developed for low-input RNA samples. If other library preparation kits are used, the UMI-based deduplication strategy should be adjusted accordingly.

## 3. Bioinformatics Workflow

### 3.1 WGS Processing

The WGS analysis starts with raw paired-end FASTQ files from tumor and matched normal samples.

The main processing steps include:

1. Quality control: Assessment of sequencing quality and read characteristics.
2. Read alignment: Mapping of sequencing reads to the human reference genome (GRCh38) using BWA-MEM.
3. Alignment processing: Sorting, duplicate marking, and base quality score recalibration (BQSR).
4. Somatic variant calling: Identification of tumor-specific variants using GATK Mutect2.
5. Variant filtering: Removal of likely sequencing artifacts and low-confidence variant calls.
6. Variant annotation: Identification of genes, transcripts, and protein consequences affected by somatic variants.

The primary output is a set of filtered somatic variants suitable for downstream neoepitope prediction.

### 3.2 RNA-seq Processing

RNA-seq analysis provides transcriptional information to support the interpretation and prioritization of candidate neoepitopes.

The workflow includes:

1. Quality control: Evaluation of raw sequencing reads.
2. UMI extraction: Extraction of UMIs from the library-specific read structure using UMI-tools.
3. Adapter and quality trimming: Removal of adapter sequences and low-quality bases.
4. RNA contamination filtering: Removal of reads originating from abundant non-coding RNA species, including ribosomal RNA (rRNA), transfer RNA (tRNA), and small nucleolar RNA (snoRNA).
5. Read alignment: Two-step mapping of filtered reads to the human reference genome using HISAT2 and BWA-mem.
6. UMI-aware duplicate handling: Identification of PCR duplicates using UMI information.
7. Transcript analysis: Assessment of gene expression and transcript structures.

RNA-seq results can be used to evaluate the expression of genes containing somatic variants and provide additional evidence for candidate neoepitopes.

### 3.3 HLA Typing

Patient-specific HLA alleles can be identified using:

- HLA-LA / HLA-HD: HLA genotyping using genomic sequencing data.
- seq2HLA: HLA typing using RNA-seq data.

The resulting HLA genotypes are used as inputs for peptide–HLA binding prediction.

### 3.4 Neoepitope Prediction

Somatic variants are translated into candidate mutant peptide sequences based on their predicted effects on protein-coding transcripts.

Candidate peptides are subsequently evaluated for their predicted binding to patient-specific HLA molecules.

The workflow supports:

- MHC class I prediction: Using netMHCpan to evaluate candidate peptides for presentation by HLA class I molecules.
- MHC class II prediction: Using netMHCIIpan to evaluate candidate peptides for presentation by HLA class II molecules.

### 3.5 Neoepitope Prioritization

Candidate neoepitopes can be prioritized by integrating multiple features, including:

- Predicted peptide–HLA binding affinity or percentile rank.
- Expression of the corresponding gene or transcript.
- Variant allele frequency and sequencing support.
- Estimated tumor purity and variant clonality.
- HLA genotype and potential HLA allele loss.

The aim is to identify a set of candidate neoepitopes for further experimental validation or potential inclusion in personalized cancer vaccines.

## 4. Repository Structure

The repository is organized into independent modules corresponding to the main stages of the analysis.

```text
Neoepitope-prediction-pipeline/
├── README.md
├── LICENSE
├── .gitignore
├── QC/
├── WGS_analysis/
│   ├── 01_alignment/
│   ├── 02_preprocessing/
│   ├── 03_variant_calling/
│   └── 04_HLA_typing/
├── RNAseq_analysis/
│   ├── 01_preprocessing/
│   ├── 02_rna_filtering/
│   ├── 03_alignment/
│   ├── 04_expression/
│   └── 05_allele_specific_expression/
├── Neoepitope_prediction/
└── environment/
```

Each module contains the analysis scripts (`*.sh`, `*.R`), a PBS submission wrapper per script (`submit_*.pbs`) and a README describing the required inputs, expected outputs, software dependencies and the `qsub` command. Submit the wrappers from the repository root, or pass `REPO_DIR=/path/to/repository` with `qsub -v`.

## 5. Computational Environment

The analysis scripts are primarily developed for execution on a Linux-based high-performance computing (HPC) environment. The software module used by every step is listed in `environment/software_versions.tsv`.

## 6. References and Software

Key tools used or planned for the workflow include:

- [BWA](https://github.com/lh3/bwa) — Short-read alignment.
- [SAMtools](https://www.htslib.org/) — Alignment file processing.
- [biobambam2](https://gitlab.com/german.tischler/biobambam2) — Duplicate marking.
- [GATK](https://gatk.broadinstitute.org/) — Somatic variant calling and preprocessing.
- [HISAT2](https://daehwankimlab.github.io/hisat2/) — RNA-seq alignment.
- [UMI-tools](https://github.com/CGATOxford/UMI-tools) — UMI extraction and duplicate handling.
- [Cutadapt](https://cutadapt.readthedocs.io/) — Adapter and quality trimming.
- [Kallisto](https://pachterlab.github.io/kallisto/) and [tximport](https://bioconductor.org/packages/tximport/) — Expression quantification.
- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) — Read quality control.
- [seq2HLA](https://github.com/TRON-Bioinformatics/seq2HLA) — RNA-seq-based HLA typing.
- [HLA-HD](https://www.genome.med.kyoto-u.ac.jp/HLA-HD/) — HLA genotyping.
- [HLA-LA](https://github.com/DiltheyLab/HLA-LA) — HLA genotyping.
- [Ensembl VEP](https://www.ensembl.org/info/docs/tools/vep/index.html) — Variant annotation.
- [netMHCpan / netMHCIIpan](https://services.healthtech.dtu.dk/) — Peptide–MHC binding prediction.
- [MuPeXI](https://github.com/ambj/MuPeXI) — Neoepitope prediction and prioritization.

## 7. Disclaimer

This repository is intended for research purposes only. Predicted neoepitopes require appropriate experimental validation before any clinical interpretation or application.
