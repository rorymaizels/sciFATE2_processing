#!/bin/bash
#SBATCH --job-name=ctl_sub
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=3-00:00:00
#SBATCH --mem=150G
#SBATCH --partition=cpu
#SBATCH --array=1-10
#SBATCH --output=ctlsf_sub%a.out

### ARGS
STAR=${1} 
GTF=${2}
home=${3}
fastq=${4}
data_dir=${5} 
meta_dir=${6}
scripts=${7}
sample_csv_name=${8} 
python_path=${9}
trim_cutoff=${10}
snp_threshold=${11}
do_estimate=${12}

TASK_ID=`expr ${SLURM_ARRAY_TASK_ID} - 1`
N_TASKS=${SLURM_ARRAY_TASK_COUNT}

$python_path/python $scripts/control_run.py $sample_csv_name $data_dir $meta_dir $scripts $GTF $STAR $fastq $trim_cutoff $snp_threshold $do_estimate $TASK_ID $N_TASKS
