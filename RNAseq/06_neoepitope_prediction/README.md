# MuPeXI and netMHCpan — simple PBS modules

Each tool has one execution script and one PBS submission script.

## How to run

1. Open `submit_mupexi.pbs` or `submit_netmhcpan.pbs`.
2. Edit the EDIT THESE SETTINGS section: sample, HLA alleles, peptide length, input/output paths, and tool installation paths.
3. Add your Python/VEP or netMHCpan environment activation at the indicated comment.
4. From the repository root, submit:

```bash
qsub Neoepitope_prediction/submit_mupexi.pbs
qsub Neoepitope_prediction/submit_netmhcpan.pbs
```

Run MuPeXI first if you plan to use its peptide FASTA for netMHCpan. Check the actual generated FASTA filename and put that path in `submit_netmhcpan.pbs`. 

