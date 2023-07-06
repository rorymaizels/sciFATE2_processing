#!/bin/bash
#SBATCH --job-name=bgnd
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=100G
#SBATCH --partition=cpu
#SBATCH --output=make_background.out

python_path="/camp/lab/briscoej/working/Rory/.conda2/my_envs/python_lab/bin"
home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/experiments"
scripts=$home/scripts
background_read=$home/background/data/all_all/
background_write=$home
pattern="MAI"

$python_path/python $scripts/prepare_background.py $background_read $background_write $pattern

echo "Done!"