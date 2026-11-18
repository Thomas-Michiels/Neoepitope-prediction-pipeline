#!/usr/bin/env bash
set -euo pipefail

# Submit the complete pipeline for one patient as PBS jobs chained with afterok dependencies.
# Each job only starts when the jobs it depends on finished successfully.

usage() {
  cat <<'EOF'
Usage: bash run_pipeline.sh <config.sh> [--dry-run] [--only-prediction]

  <config.sh>        patient configuration, see config/config.sh
  --dry-run          print the qsub commands without submitting anything
  --only-prediction  submit only MuPeXI, using the outputs of an earlier run (needs HLA_FILE)

Run on an HPC login node. Job logs are written to <OUT_DIR>/logs/.
EOF
}

[[ $# -ge 1 ]] || { usage >&2; exit 1; }
case $1 in -h|--help) usage; exit 0 ;; esac
CONFIG=$1
shift
DRY_RUN=0
ONLY_PREDICTION=0
for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=1 ;;
    --only-prediction) ONLY_PREDICTION=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; usage >&2; exit 1 ;;
  esac
done

[[ -f $CONFIG ]] || { echo "Config file not found: $CONFIG" >&2; exit 1; }
REPO_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=config/config.sh
source "$CONFIG"

# ---- Check the configuration ---------------------------------------------------------------------
required=(PATIENT_ID OUT_DIR TUMOR_WGS_R1 TUMOR_WGS_R2 NORMAL_WGS_R1 NORMAL_WGS_R2 TUMOR_RNA_R1 TUMOR_RNA_R2
          TUMOR_WGS_SAMPLE NORMAL_WGS_SAMPLE TUMOR_RNA_SAMPLE REF MILLS SNPS DBSNP VEP_CACHE_DIR HLAHD_ROOT
          RRNA_INDEX TRNA_INDEX SNORNA_INDEX HISAT2_INDEX SPLICE_SITES KALLISTO_INDEX GTF_FILE
          UMI_READ BC_PATTERN RNA_LIBRARY PLATFORM_UNIT PEPTIDE_LENGTH)
if [[ -n ${HLA_FILE:-} || $ONLY_PREDICTION -eq 1 ]]; then
  required+=(HLA_FILE MUPEXI_SCRIPT MUPEXI_CONFIG)
fi
for var in "${required[@]}"; do
  value=${!var:-}
  if [[ -z $value || $value == *CHANGE_ME* ]]; then
    echo "Config error: set $var in $CONFIG" >&2; exit 1
  fi
  if [[ $value == *,* ]]; then
    echo "Config error: $var must not contain commas (qsub -v limitation): $value" >&2; exit 1
  fi
done
[[ $UMI_READ == 1 || $UMI_READ == 2 ]] || { echo "Config error: UMI_READ must be 1 or 2" >&2; exit 1; }

if (( ! DRY_RUN )); then
  command -v qsub >/dev/null || { echo "qsub not found: run this on the HPC login node" >&2; exit 1; }
  for var in TUMOR_WGS_R1 TUMOR_WGS_R2 NORMAL_WGS_R1 NORMAL_WGS_R2 TUMOR_RNA_R1 TUMOR_RNA_R2 \
             REF MILLS SNPS DBSNP SPLICE_SITES KALLISTO_INDEX GTF_FILE; do
    [[ -f ${!var} ]] || { echo "Missing file for $var: ${!var}" >&2; exit 1; }
  done
  for var in VEP_CACHE_DIR HLAHD_ROOT; do
    [[ -d ${!var} ]] || { echo "Missing directory for $var: ${!var}" >&2; exit 1; }
  done
  for var in RRNA_INDEX TRNA_INDEX SNORNA_INDEX HISAT2_INDEX; do
    compgen -G "${!var}*.ht2" >/dev/null || { echo "No HISAT2 index files found for $var: ${!var}" >&2; exit 1; }
  done
  if [[ -n ${HLA_FILE:-} ]]; then
    for var in HLA_FILE MUPEXI_SCRIPT MUPEXI_CONFIG; do
      [[ -f ${!var} ]] || { echo "Missing file for $var: ${!var}" >&2; exit 1; }
    done
  fi
fi

# ---- Job submission helper -----------------------------------------------------------------------
LOG_DIR="$OUT_DIR/logs"
JOB=""
DRY_COUNTER=0

# submit <step name> <wrapper path relative to the repository> <afterok job IDs, colon-separated, or ""> [VAR=value ...]
# Sets the global variable JOB to the submitted job ID.
submit() {
  local name=$1 pbs=$2 deps=$3
  shift 3
  local vars="REPO_DIR=$REPO_DIR" pair
  for pair in "$@"; do vars+=",$pair"; done
  local args=(-N "${name}_${PATIENT_ID}" -j oe -o "$LOG_DIR/${name}.log" -v "$vars")
  [[ -n $deps ]] && args+=(-W "depend=afterok:$deps")
  if (( DRY_RUN )); then
    DRY_COUNTER=$((DRY_COUNTER + 1))
    JOB="dryrun$DRY_COUNTER"
    printf '[%s] qsub' "$JOB"
    printf ' %q' "${args[@]}" "$REPO_DIR/$pbs"
    printf '\n\n'
  else
    JOB=$(qsub "${args[@]}" "$REPO_DIR/$pbs")
    printf '%s\t%s\t%s\n' "$JOB" "$name" "${deps:--}" >> "$LOG_DIR/jobs.tsv"
    echo "Submitted $name: $JOB"
  fi
}

# ---- Output locations ----------------------------------------------------------------------------
QC_DIR="$OUT_DIR/QC"
WGS_DIR="$OUT_DIR/WGS"
VAR_DIR="$WGS_DIR/variants"
RNA_DIR="$OUT_DIR/RNAseq"
PRED_DIR="$OUT_DIR/Neoepitope"
PASS_VCF="$VAR_DIR/${PATIENT_ID}.mutect2.filtered.PASS.vcf"
KALLISTO_DIR="$RNA_DIR/04_expression/kallisto"

if (( ! DRY_RUN )); then
  mkdir -p "$LOG_DIR"
  # Record what was run: repository version and the exact configuration.
  {
    echo "date: $(date -Iseconds)"
    echo "repository: $REPO_DIR"
    echo "commit: $(git -C "$REPO_DIR" rev-parse HEAD 2>/dev/null || echo unknown)"
    echo "uncommitted changes: $(git -C "$REPO_DIR" status --porcelain 2>/dev/null | wc -l | tr -d ' ') files"
  } > "$LOG_DIR/run_info.txt"
  cp "$CONFIG" "$LOG_DIR/config_used.sh"
fi

submit_prediction() {
  local deps=$1
  submit mupexi Neoepitope/01_prediction/submit_mupexi.pbs "$deps" \
    "VCF=$PASS_VCF" "HLA_FILE=$HLA_FILE" "EXPRESSION_TSV=$KALLISTO_DIR/abundance.tsv" \
    "OUTPUT_DIR=$PRED_DIR/mupexi" "SAMPLE_NAME=$PATIENT_ID" \
    "MUPEXI_SCRIPT=$MUPEXI_SCRIPT" "MUPEXI_CONFIG=$MUPEXI_CONFIG" "PEPTIDE_LENGTH=$PEPTIDE_LENGTH"
}

if (( ONLY_PREDICTION )); then
  if (( ! DRY_RUN )); then
    for f in "$PASS_VCF" "$KALLISTO_DIR/abundance.tsv"; do
      [[ -f $f ]] || { echo "Missing output of an earlier run: $f" >&2; exit 1; }
    done
  fi
  submit_prediction ""
  exit 0
fi

# ---- QC ------------------------------------------------------------------------------------------
submit fastqc_tumor_WGS QC/01_fastqc/submit_fastqc.pbs "" \
  "R1=$TUMOR_WGS_R1" "R2=$TUMOR_WGS_R2" "OUT_DIR=$QC_DIR/tumor_WGS"
submit fastqc_normal_WGS QC/01_fastqc/submit_fastqc.pbs "" \
  "R1=$NORMAL_WGS_R1" "R2=$NORMAL_WGS_R2" "OUT_DIR=$QC_DIR/normal_WGS"
submit fastqc_tumor_RNA QC/01_fastqc/submit_fastqc.pbs "" \
  "R1=$TUMOR_RNA_R1" "R2=$TUMOR_RNA_R2" "OUT_DIR=$QC_DIR/tumor_RNA"

# ---- WGS: alignment, duplicate marking, BQSR (tumor and normal) ---------------------------------
declare -A BQSR_JOB
for role in tumor normal; do
  if [[ $role == tumor ]]; then
    r1=$TUMOR_WGS_R1; r2=$TUMOR_WGS_R2; sample=$TUMOR_WGS_SAMPLE
  else
    r1=$NORMAL_WGS_R1; r2=$NORMAL_WGS_R2; sample=$NORMAL_WGS_SAMPLE
  fi
  dir="$WGS_DIR/$role"

  submit "align_${role}_WGS" WGS/01_alignment/submit_alignment.pbs "" \
    "REF=$REF" "R1=$r1" "R2=$r2" "SAMPLE=$sample" \
    "OUT=$dir/$sample.sorted.bam" "TMP_PREFIX=$dir/tmp/${sample}_sort"
  align=$JOB

  submit "markdup_${role}_WGS" WGS/02_preprocessing/submit_mark_duplicates.pbs "$align" \
    "INPUT_BAM=$dir/$sample.sorted.bam" "OUT=$dir/$sample.markdup.bam" "TMP_PREFIX=$dir/tmp/${sample}_markdup"
  markdup=$JOB

  submit "bqsr_${role}_WGS" WGS/02_preprocessing/submit_bqsr.pbs "$markdup" \
    "INPUT_BAM=$dir/$sample.markdup.bam" "REF=$REF" "MILLS=$MILLS" "SNPS=$SNPS" "DBSNP=$DBSNP" \
    "TABLE=$dir/$sample.recal.table" "OUT=$dir/$sample.recal.bam"
  BQSR_JOB[$role]=$JOB
done

# ---- WGS: somatic variant calling, filtering, annotation ----------------------------------------
submit mutect2 WGS/03_variant_calling/submit_mutect2.pbs "${BQSR_JOB[tumor]}:${BQSR_JOB[normal]}" \
  "REF=$REF" "TUMOR_BAM=$WGS_DIR/tumor/$TUMOR_WGS_SAMPLE.recal.bam" \
  "NORMAL_BAM=$WGS_DIR/normal/$NORMAL_WGS_SAMPLE.recal.bam" "NORMAL_SAMPLE=$NORMAL_WGS_SAMPLE" \
  "OUT=$VAR_DIR/${PATIENT_ID}.mutect2.vcf"
mutect2=$JOB

submit filter_mutect2 WGS/03_variant_calling/submit_filter_mutect2_pass.pbs "$mutect2" \
  "REF=$REF" "INPUT_VCF=$VAR_DIR/${PATIENT_ID}.mutect2.vcf" \
  "FILTERED_VCF=$VAR_DIR/${PATIENT_ID}.mutect2.filtered.vcf" "PASS_VCF=$PASS_VCF"
filter=$JOB

submit vep WGS/03_variant_calling/submit_annotate_vep.pbs "$filter" \
  "INPUT_VCF=$PASS_VCF" "OUT=$VAR_DIR/${PATIENT_ID}.mutect2.filtered.PASS.vep.vcf.gz" \
  "STATS=$VAR_DIR/${PATIENT_ID}.vep.html" "CACHE_DIR=$VEP_CACHE_DIR" "REF=$REF"

# ---- WGS: HLA typing on the matched normal -------------------------------------------------------
submit hla_hd WGS/04_HLA_typing/submit_hla_hd.pbs "" \
  "R1=$NORMAL_WGS_R1" "R2=$NORMAL_WGS_R2" "SAMPLE=$NORMAL_WGS_SAMPLE" \
  "OUT_DIR=$WGS_DIR/HLA" "HLAHD_ROOT=$HLAHD_ROOT"

# ---- RNA-seq: UMI extraction, trimming, ncRNA filtering ------------------------------------------
S=$TUMOR_RNA_SAMPLE
PRE="$RNA_DIR/01_preprocessing/$S"
FIL="$RNA_DIR/02_rna_filtering/$S"
ALN="$RNA_DIR/03_alignment/$S"
EXP="$RNA_DIR/04_expression/$S"

submit umi_extraction RNAseq/01_preprocessing/submit_umi_extraction_read${UMI_READ}.pbs "" \
  "R1=$TUMOR_RNA_R1" "R2=$TUMOR_RNA_R2" "OUT_R1=${PRE}_R1.umi.fastq.gz" "OUT_R2=${PRE}_R2.umi.fastq.gz" \
  "BC_PATTERN=$BC_PATTERN"
umi=$JOB

submit adapter_trimming RNAseq/01_preprocessing/submit_adapter_trimming.pbs "$umi" \
  "R1=${PRE}_R1.umi.fastq.gz" "R2=${PRE}_R2.umi.fastq.gz" \
  "OUT_R1=${PRE}_R1.umi.trimmed.fastq.gz" "OUT_R2=${PRE}_R2.umi.trimmed.fastq.gz"
trim=$JOB

submit filter_rrna RNAseq/02_rna_filtering/submit_filter_rrna.pbs "$trim" \
  "R1=${PRE}_R1.umi.trimmed.fastq.gz" "R2=${PRE}_R2.umi.trimmed.fastq.gz" \
  "OUT=${FIL}_rRNA_filtered" "INDEX=$RRNA_INDEX"
rrna=$JOB

submit filter_trna RNAseq/02_rna_filtering/submit_filter_trna.pbs "$rrna" \
  "R1=${FIL}_rRNA_filtered.fastq.1.gz" "R2=${FIL}_rRNA_filtered.fastq.2.gz" \
  "OUT=${FIL}_r-tRNA_filtered" "INDEX=$TRNA_INDEX"
trna=$JOB

submit filter_snorna RNAseq/02_rna_filtering/submit_filter_snorna.pbs "$trna" \
  "R1=${FIL}_r-tRNA_filtered.fastq.1.gz" "R2=${FIL}_r-tRNA_filtered.fastq.2.gz" \
  "OUT=${FIL}_r-t-snoRNA_filtered" "INDEX=$SNORNA_INDEX"
snorna=$JOB

# ---- RNA-seq: two-step alignment -----------------------------------------------------------------
submit hisat2_alignment RNAseq/03_alignment/submit_hisat2_alignment.pbs "$snorna" \
  "R1=${FIL}_r-t-snoRNA_filtered.fastq.1.gz" "R2=${FIL}_r-t-snoRNA_filtered.fastq.2.gz" \
  "HISAT2_INDEX=$HISAT2_INDEX" "SPLICE_SITES=$SPLICE_SITES" "OUT_PREFIX=$ALN" \
  "RG_ID=$S" "SAMPLE=$S" "LIBRARY=$RNA_LIBRARY" "PLATFORM_UNIT=$PLATFORM_UNIT"
hisat2=$JOB

submit sam_to_bam RNAseq/03_alignment/submit_sam_to_bam.pbs "$hisat2" \
  "INPUT_SAM=${ALN}_hisat2.sam" "OUTPUT_BAM=${ALN}_hisat2.bam"
sam2bam=$JOB

submit bwa_mem_RNA RNAseq/03_alignment/submit_bwa_mem_alignment.pbs "$hisat2" \
  "R1=${ALN}_unmapped.fastq.1.gz" "R2=${ALN}_unmapped.fastq.2.gz" "BWA_REFERENCE=$REF" \
  "OUTPUT_BAM=${ALN}_bwa.bam" "RG_ID=$S" "SAMPLE=$S" "LIBRARY=$RNA_LIBRARY" "PLATFORM_UNIT=$PLATFORM_UNIT"
bwa=$JOB

submit merge_alignments RNAseq/03_alignment/submit_merge_alignments.pbs "$sam2bam:$bwa" \
  "HISAT2_BAM=${ALN}_hisat2.bam" "BWA_BAM=${ALN}_bwa.bam" "OUTPUT_BAM=${ALN}_merged.sorted.bam"
merge=$JOB

# ---- RNA-seq: deduplication and expression -------------------------------------------------------
submit umi_dedup RNAseq/04_expression/submit_umi_deduplication.pbs "$merge" \
  "INPUT_BAM=${ALN}_merged.sorted.bam" "OUTPUT_BAM=${EXP}.dedup.bam" "STATS_PREFIX=${EXP}.dedup"
dedup=$JOB

submit bam_to_fastq RNAseq/04_expression/submit_bam_to_fastq.pbs "$dedup" \
  "INPUT_BAM=${EXP}.dedup.bam" "R1_FASTQ=${EXP}.dedup_R1.fastq.gz" "R2_FASTQ=${EXP}.dedup_R2.fastq.gz"
bam2fastq=$JOB

submit kallisto RNAseq/04_expression/submit_kallisto_quant.pbs "$bam2fastq" \
  "KALLISTO_INDEX=$KALLISTO_INDEX" "R1_FASTQ=${EXP}.dedup_R1.fastq.gz" "R2_FASTQ=${EXP}.dedup_R2.fastq.gz" \
  "OUTPUT_DIR=$KALLISTO_DIR"
kallisto=$JOB

submit tx_to_gene RNAseq/04_expression/submit_kallisto_transcript_to_gene.pbs "$kallisto" \
  "GTF_FILE=$GTF_FILE" "ABUNDANCE_TSV=$KALLISTO_DIR/abundance.tsv" \
  "GENE_OUTPUT_TSV=$KALLISTO_DIR/gene_level_abundance.tsv"

# ---- Neoepitope prediction -----------------------------------------------------------------------
if [[ -n ${HLA_FILE:-} ]]; then
  submit_prediction "$filter:$kallisto"
else
  cat <<EOF
Neoepitope prediction was not submitted because HLA_FILE is empty.
When HLA-HD has finished, copy the class I alleles from
  $WGS_DIR/HLA/$NORMAL_WGS_SAMPLE/result/${NORMAL_WGS_SAMPLE}_final.result.txt
into a file (format: Neoepitope/01_prediction/hla_alleles.example.txt), set HLA_FILE in $CONFIG and run:
  bash run_pipeline.sh $CONFIG --only-prediction
EOF
fi
