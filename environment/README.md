# Software environment

`software_versions.tsv` lists, for every pipeline step, the software and the exact Lmod/EasyBuild module loaded by its PBS wrapper on the UGent VSC clusters. These are the versions used in the original analysis.

Some steps use different versions of the same tool (for example SAMtools 1.18 and 1.19.2, BWA 0.7.17 for RNA-seq and 0.7.18 for WGS, GATK 4.4.0.0 for ASEReadCounter and 4.6.0.0 elsewhere). They are kept as they were used, so results stay reproducible against earlier runs. Harmonising them is a separate change that needs re-validation.

To run the pipeline elsewhere, install the same versions (for example with Conda/Bioconda) and adapt or remove the `module load` lines in the `submit_*.pbs` wrappers.
