#!/bin/bash
#SBATCH --job-name=sf_main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=100G
#SBATCH --partition=cpu
#SBATCH --output=sf_main.out

### 0. DEFINE GLOBAL PARAMETERS
python_path="/camp/lab/briscoej/working/Rory/.conda2/my_envs/python_lab/bin"
home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/FATE_PILOT3"
scripts=$home/scripts
meta_dir=$home/metadata
fastq=$home/fastq
do_estimate=0

unique_id='130'
trim_cutoff=130

data_dir=$home/data_${unique_id}
STAR=$home/STAR
GTF="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_gtf/Mus_musculus.GRCm39.104.gtf.gz"
IDX="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_idx/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa" 

RT_samples="NT,IO,DI,FT"
PCR_samples="old,qia,zym,pub"
CONTROL_SAMPLE="NT_all"

mkdir -p $data_dir

### 1. CREATE GLOBAL REFERENCE
echo "Creating reference..."
dynast ref -i $STAR $IDX $GTF

### 2. SET UP SNPS AND P_E

control=$home/data_control_${unique_id}/${CONTROL_SAMPLE}
background_loc=$home
pattern="MAI"

$python_path/python $scripts/prepare_background.py $control $background_loc $pattern $unique_id
snv_csv=$background_loc/global_snps_${unique_id}.csv
p_e=$background_loc/global_pe_${unique_id}.csv

### 2. CREATE SAMPLE LIST: used to divide into parallel jobs

# this has to be tweaked by user:
$python_path/python $scripts/demultiplex_samples.py $home

sample_csv_name='processing_samples'
$python_path/python $scripts/create_sample_csv.py $RT_samples $PCR_samples $meta_dir $sample_csv_name

### 3. RUN SCIFATE IN PARALLEL
echo "Beginning sciFATE..."
sbatch $scripts/array_scifate.sh $STAR $GTF $home $fastq $data_dir $meta_dir $scripts $sample_csv_name $python_path $p_e $snv_csv $trim_cutoff $do_estimate
echo "Script complete."
