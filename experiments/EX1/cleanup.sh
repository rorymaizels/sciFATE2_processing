#!/bin/bash
#SBATCH --job-name=cleanup
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=100G
#SBATCH --partition=cpu
#SBATCH --output=cleanup_%j.out

SAMPLE="EX1"

home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/experiments"
target=$home/${SAMPLE}/data

echo "Cleaning up!"

rm -r ${target}/*h/MAI*/alignment
rm -r ${target}/*h/MAI*/count/alignments.csv
rm -r ${target}/*h/MAI*/count/conversions.csv

echo '...done!'
