#!/bin/bash
#SBATCH --job-name=ctl_main
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=100G
#SBATCH --partition=cpu
#SBATCH --output=ctlsf_main.out

### 0. DEFINE GLOBAL PARAMETERS
python_path="/camp/lab/briscoej/working/Rory/.conda2/my_envs/python_lab/bin"
home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/FATE_PILOT3"
scripts=$home/scripts
meta_dir=$home/metadata
fastq=$home/fastq
STAR=$home/STAR
GTF="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_gtf/Mus_musculus.GRCm39.104.gtf.gz"
IDX="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_idx/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa" 

snp_threshold=0.05
trim_cutoff=130
do_estimate=0

data_dir=$home/data_control_130
mkdir -p $data_dir

### 1. CREATE GLOBAL REFERENCE
echo "Creating reference..."
dynast ref -i $STAR $IDX $GTF

### 2. CREATE SAMPLE LIST: used to divide into parallel jobs
RT_samples="NT"
PCR_samples="all"

$python_path/python $scripts/demultiplex_samples_control.py $home

sample_csv_name='processing_samples_control'
$python_path/python $scripts/create_sample_csv_control.py $RT_samples $PCR_samples $meta_dir $sample_csv_name

### 3. RUN SCIFATE IN PARALLEL
echo "Beginning sciFATE..."
sbatch $scripts/array_scifate_control.sh $STAR $GTF $home $fastq $data_dir $meta_dir $scripts $sample_csv_name $python_path $trim_cutoff $snp_threshold $do_estimate
echo "Script complete."
