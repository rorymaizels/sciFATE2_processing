#!/bin/bash
#SBATCH --job-name=sf_main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=100G
#SBATCH --partition=cpu
#SBATCH --output=sf_main.out


### GLOBALS
home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/FATE_PILOT1"
scripts=$home/scripts

data_dir=$home/data
mkdir -p $data_dir

STAR=$home/STAR
GTF="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_gtf/Mus_musculus.GRCm39.104.gtf.gz"
IDX="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_idx/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa" 
echo "Creating reference..."
# skipping as already run
# dynast ref -i $STAR $IDX $GTF

echo "Beginning sciFATE..."
sbatch $scripts/array_scifate.sh $STAR $GTF
echo "All done."
