# Neoepitope prediction

This module combines the outputs of the WGS and RNA-seq workflows:

- PASS-filtered somatic VCF from `WGS/03_variant_calling`
- HLA alleles from `WGS/04_HLA_typing`
- transcript expression (Kallisto `abundance.tsv`) from `RNAseq/04_expression`

## Files

- `mupexi.sh`, `submit_mupexi.pbs`: MuPeXI extracts mutant peptides, integrates expression and predicts MHC class I binding. MuPeXI runs VEP and netMHCpan itself, using the tool paths in its `config.ini`.
- `netmhcpan.sh`, `submit_netmhcpan.pbs`: stand-alone netMHCpan on any peptide FASTA, for example non-canonical peptide candidates.
- `hla_alleles.example.txt`: format of the HLA allele file (one allele per line).

## HLA allele file

`qsub -v` values cannot contain commas, so the alleles are passed as a file. Copy the class I alleles from the HLA-HD result (`<OUT_DIR>/<SAMPLE>/result/<SAMPLE>_final.result.txt`) into a file in the format of `hla_alleles.example.txt`.

## Software

- MuPeXI with its own `config.ini` pointing to VEP, netMHCpan and the reference files.
- netMHCpan (academic licence from DTU Health Tech).

Check that the transcript IDs in the expression table match the VEP annotation used by MuPeXI (with or without version suffix).

## HPC resources

MuPeXI: 48 CPUs, 30 GB, 24 h. netMHCpan: 1 CPU, 30 GB, 24 h.

## Submit with qsub

Run from the repository root:

```bash
qsub -v "VCF=/path/mutect2.filtered.PASS.vcf,HLA_FILE=/path/hla_alleles.txt,EXPRESSION_TSV=/path/kallisto/abundance.tsv,OUTPUT_DIR=/path/mupexi,SAMPLE_NAME=patient01,MUPEXI_SCRIPT=/path/MuPeXI.py,MUPEXI_CONFIG=/path/config.ini,PEPTIDE_LENGTH=8-11" Neoepitope/01_prediction/submit_mupexi.pbs

qsub -v "PEPTIDE_FASTA=/path/peptides_9mer.fasta,HLA_FILE=/path/hla_alleles.txt,OUTPUT_FILE=/path/netmhcpan/patient01_9mer.xls" Neoepitope/01_prediction/submit_netmhcpan.pbs
```

## Run without PBS

```bash
bash Neoepitope/01_prediction/mupexi.sh /path/PASS.vcf HLA-A02:01,HLA-B07:02 9 /path/abundance.tsv /path/mupexi patient01 /path/MuPeXI.py /path/config.ini 8
bash Neoepitope/01_prediction/netmhcpan.sh /path/peptides.fasta HLA-A02:01,HLA-B07:02 9 /path/out.xls
```
