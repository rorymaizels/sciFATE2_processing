#!/bin/bash
#SBATCH --job-name=background
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=100G
#SBATCH --partition=cpu
#SBATCH --output=ctlsf_main.out

### 0. DEFINE GLOBAL PARAMETERS
python_path="/camp/lab/briscoej/working/Rory/.conda2/my_envs/python_lab/bin"
home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/experiments"
scripts=$home/background/background_scripts
meta_dir=$home/metadata
fastq=$home/background/fastq
STAR=$home/STAR
GTF="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_gtf/Mus_musculus.GRCm39.104.gtf.gz"
IDX="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_idx/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa" 

snp_threshold=0.05
trim_cutoff=130
do_estimate=1

data_dir=$home/background/data
mkdir -p $data_dir

### 1. CREATE GLOBAL REFERENCE
echo "Creating reference..."
dynast ref -i $STAR $IDX $GTF

### 2. CREATE SAMPLE LIST: used to divide into parallel jobs
RT_samples="all"
PCR_samples="all"

$python_path/python $home/background/format_samples.py $home

sample_csv_name='processing_samples'
$python_path/python $scripts/create_sample_csv_background.py $RT_samples $PCR_samples $meta_dir $sample_csv_name

### 3. RUN SCIFATE IN PARALLEL
echo "Beginning sciFATE..."
sbatch $scripts/array_scifate_background.sh $STAR $GTF $home $fastq $data_dir $meta_dir $scripts $sample_csv_name $python_path $trim_cutoff $snp_threshold $do_estimate
echo "Script complete."
