# Neoepitope prediction

MuPeXI generates candidate mutant peptides using somatic variants, HLA alleles and RNA expression data. netMHCpan predicts peptide binding to the selected HLA alleles.

## MuPeXI

Edit the sample settings and paths in `submit_mupexi.pbs`, then submit from the repository root:

```bash
qsub RNAseq/06_neoepitope_prediction/submit_mupexi.pbs
```

## netMHCpan

Edit the peptide FASTA, HLA alleles, peptide length and output path in `submit_netmhcpan.pbs`:

```bash
qsub RNAseq/06_neoepitope_prediction/submit_netmhcpan.pbs
```

The execution commands are in `mupexi.sh` and `netmhcpan.sh`.
