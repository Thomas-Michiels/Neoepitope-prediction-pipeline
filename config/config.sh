#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables are used by run_pipeline.sh, which sources this file
#
# Configuration for run_pipeline.sh: one patient with tumor WGS, matched-normal WGS and tumor RNA-seq.
#
# 1. Copy this file per patient, e.g.  cp config/config.sh config/patient01.sh
# 2. Replace every CHANGE_ME.
# 3. Check the job plan:               bash run_pipeline.sh config/patient01.sh --dry-run
# 4. Submit:                           bash run_pipeline.sh config/patient01.sh
#
# Values must not contain commas: they are passed to qsub -v.

# ---- Cluster locations (UGent VSC, VO gvo00101) ------------------------------------------------
VSC_DATA_VO="${VSC_DATA_VO:-/data/gent/vo/001/gvo00101}"
VSC_SCRATCH_VO_USER="${VSC_SCRATCH_VO_USER:-/scratch/gent/vo/001/gvo00101/${USER}}"

# ---- Patient and raw FASTQ files ----------------------------------------------------------------
PATIENT_ID="CHANGE_ME"

TUMOR_WGS_R1="CHANGE_ME"
TUMOR_WGS_R2="CHANGE_ME"
NORMAL_WGS_R1="CHANGE_ME"
NORMAL_WGS_R2="CHANGE_ME"
TUMOR_RNA_R1="CHANGE_ME"
TUMOR_RNA_R2="CHANGE_ME"

# Sample names written to the BAM read groups (SM). Mutect2 uses NORMAL_WGS_SAMPLE to find the normal.
TUMOR_WGS_SAMPLE="${PATIENT_ID}_tumor_WGS"
NORMAL_WGS_SAMPLE="${PATIENT_ID}_normal_WGS"
TUMOR_RNA_SAMPLE="${PATIENT_ID}_tumor_RNA"

# All results and job logs are written below this directory.
OUT_DIR="${VSC_SCRATCH_VO_USER}/neoepitope_pipeline/${PATIENT_ID}"

# ---- Reference files ----------------------------------------------------------------------------
# GRCh38 FASTA with BWA index, .fai and .dict (used for WGS, BWA-MEM RNA realignment, GATK and VEP)
REF="CHANGE_ME"
# GATK known sites for BQSR
MILLS="CHANGE_ME"   # Mills_and_1000G_gold_standard.indels.hg38.vcf.gz
SNPS="CHANGE_ME"    # 1000G_phase1.snps.high_confidence.hg38.vcf.gz
DBSNP="CHANGE_ME"   # dbsnp-151.vcf.gz
# Ensembl VEP 113 merged cache
VEP_CACHE_DIR="CHANGE_ME"
# HLA-HD 1.7.0 installation
HLAHD_ROOT="${VSC_DATA_VO}/Shared_Software/hlahd.1.7.0"

# HISAT2 indices for non-coding RNA filtering (index prefixes)
RRNA_INDEX="${VSC_DATA_VO}/genomes/Hsapiens/rRNA/hisat2/hsa_rRNA.index"
TRNA_INDEX="${VSC_DATA_VO}/genomes/Hsapiens/tRNA/hisat2/hsa_tRNA.index"
SNORNA_INDEX="${VSC_DATA_VO}/genomes/Hsapiens/sn-o-RNA/hisat2/hsa_sn-o-RNA.index"
# HISAT2 genome index (prefix) and known splice sites used in the original analysis
HISAT2_INDEX="${VSC_DATA_VO}/genomes/Hsapiens/hg38/hisat2/Ensembl_v105/Homo_sapiens.hg38.105.Index"
SPLICE_SITES="${VSC_DATA_VO}/vsc46293/Genomes/Ensembl_113/Known_splice_sites/Homo_sapiens.hg38.113.Known_Splice_Sites.txt"
# Kallisto transcriptome index and the GTF it was built from
KALLISTO_INDEX="CHANGE_ME"
GTF_FILE="CHANGE_ME"

# ---- RNA library ----------------------------------------------------------------------------------
# SMARTer Stranded Total RNA-Seq Kit v3 - Pico Input: 8-nt UMI + 6 discarded bases at the start of Read 2
UMI_READ=2
BC_PATTERN="NNNNNNNNXXXXXX"
RNA_LIBRARY="SMARTer_Total_RNA_Mammalian_Pico_Input"
PLATFORM_UNIT="NovaSeqX"

# ---- Neoepitope prediction ------------------------------------------------------------------------
# Leave HLA_FILE empty for the first run. When HLA-HD has finished, write the alleles to a file
# (see Neoepitope/01_prediction/hla_alleles.example.txt), set HLA_FILE and run:
#   bash run_pipeline.sh config/patient01.sh --only-prediction
HLA_FILE=""
MUPEXI_SCRIPT="CHANGE_ME"   # path to MuPeXI.py
MUPEXI_CONFIG="CHANGE_ME"   # MuPeXI config.ini with paths to VEP and netMHCpan
PEPTIDE_LENGTH="9"          # single length or range without commas, e.g. 8-11
