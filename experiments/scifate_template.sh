#!/bin/bash
#SBATCH --job-name=sf_e1.1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00
#SBATCH --mem=100G
#SBATCH --partition=cpu
#SBATCH --output=sf_main_%j.out

SAMPLE="E1.1"

### 0. DEFINE GLOBAL PARAMETERS
python_path="/camp/lab/briscoej/working/Rory/.conda2/my_envs/python_lab/bin"
home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/experiments"
excel="PM22232.xlsx"

scripts=$home/scripts
meta_dir=$home/metadata
fastq=$home/${SAMPLE}/fastq
data_dir=$home/${SAMPLE}/data
mkdir -p $data_dir

do_estimate=1
est_method="alpha"
make_star=0
trim_cutoff=130
seq_system="S1"


STAR=$home/STAR
GTF="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_gtf/Mus_musculus.GRCm39.104.gtf.gz"
IDX="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_idx/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa" 

RT_samples="D3,D4,D5,D6,D7,D8"

### 1. CREATE GLOBAL REFERENCE
if [ $make_star == 1 ];
then
	echo "Creating reference..."
	dynast ref -i $STAR $IDX $GTF
fi

### 2. SET UP SNPS AND P_E, created separately in prepare_background.py
snv_csv=$home/global_snps.csv
p_e=$home/global_pe.csv

### 2. CREATE SAMPLE LIST: used to divide into parallel jobs

# this specifies how samples were organised by OdT primer plate:
dmpx_write=$home/${SAMPLE}/metadata
mkdir -p $dmpx_write
$python_path/python $scripts/demultiplex_samples.py $home $dmpx_write $SAMPLE $excel

sample_csv_name='processing_samples'
$python_path/python $scripts/create_sample_csv.py $RT_samples $dmpx_write $sample_csv_name

### 3. RUN SCIFATE IN PARALLEL
echo "Beginning sciFATE..."
sbatch $scripts/array_scifate.sh $STAR $GTF $home $fastq $data_dir $meta_dir $dmpx_write $scripts $sample_csv_name $python_path $p_e $snv_csv $trim_cutoff $do_estimate $est_method $seq_system
echo "Script complete."
