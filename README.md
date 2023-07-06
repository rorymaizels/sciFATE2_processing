# sciFATE2_processing

This repository contains the directory structure, scripts and metadata used to run dynast on sequencing pilots and experiments for:

*Deep dynamical modelling of developmental trajectories with temporal transcriptomics*
Rory J. Maizels, Daniel M. Snell, James Briscoe

To re-run:

1. fastqs must first be downloaded from GEO (GSE236520), and scripts must be updated to reflect the new position.

2. the STAR directory must be populated with reference genome files (specifically, something that looks like `Mus_musculus.GRCm39.104.gtf.gz` and `Mus_musculus.GRCm39.dna_sm.primary_assembly.fa`) with the GTF and IDX variables of scripts updated to reflect this change.

3. Each experiment's processing script, "scifate_*.sh" can then be run. Excel sheets in the metadata should relate particular fastq files to particular experiments and conditions; so be sure not to change the name of any fastqs. Analysis was run using the environment detailed in sci_processing.yaml with [dynast](https://dynast-release.readthedocs.io/en/latest/) version 1.0.1.

Any problems? email rory.maizels@crick.ac.uk