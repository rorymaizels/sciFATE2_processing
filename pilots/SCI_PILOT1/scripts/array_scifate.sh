#!/bin/bash
#SBATCH --job-name=sf_sub
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=3-00:00:00
#SBATCH --mem=200G
#SBATCH --partition=cpu
#SBATCH --array=1-10
#SBATCH --output=sf_sub%a.out

### ARGS
STAR=${1} 
GTF=${2}
home=${3}
fastq=${4}
data_dir=${5} 
meta_dir=${6}
dmpx_write=${7}
scripts=${8}
sample_csv_name=${9} 
python_path=${10}
p_e=${11} 
snv_csv=${12}
trim_cutoff=${13}
do_estimate=${14}
est_method=${15}

TASK_ID=`expr ${SLURM_ARRAY_TASK_ID} - 1`
N_TASKS=${SLURM_ARRAY_TASK_COUNT}

module load GCC/9.3.0

$python_path/python $scripts/align_count_and_estimate.py $sample_csv_name $data_dir $meta_dir $dmpx_write $scripts $GTF $STAR $fastq $p_e $snv_csv $trim_cutoff $do_estimate $TASK_ID $N_TASKS $est_method
