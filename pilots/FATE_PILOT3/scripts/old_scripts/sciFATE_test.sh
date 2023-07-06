#!/bin/bash
#SBATCH --job-name=sci_count
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --time=24:00:00
#SBATCH --mem=150G
#SBATCH --partition=cpu

home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/FATE_PILOT1"

# 1. Rename fastqs
sample=MAI1503A100
folder=$home/fastq
new_folder=$home/test_fastq
mkdir -p $new_folder

cat $folder/$sample*L001_R1*gz $folder/$sample*L002_R1*gz > $new_folder/$sample.R1.fastq.gz 
cat $folder/$sample*L001_R2*gz $folder/$sample*L002_R2*gz > $new_folder/$sample.R2.fastq.gz

# 2. Build STAR index
STAR=$home/STAR
GTF="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_gtf/Mus_musculus.GRCm39.104.gtf.gz"
IDX="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/STAR/GRCm39_idx/Mus_musculus.GRCm39.dna_sm.primary_assembly.fa"

dynast ref -i $STAR $IDX $GTF

# 3. Align
TECHNOLOGY="scifate"
CDNA_FASTQ=$new_folder/$sample.R2.fastq.gz
BARCODE_UMI_FASTQ=$new_folder/$sample.R1.fastq.gz 
align_dir=$home/alignment
barcode_list=$home/metadata/OT_samples.txt
dynast align -i $STAR -o $align_dir -w $barcode_list -x $TECHNOLOGY $CDNA_FASTQ $BARCODE_UMI_FASTQ 

# 4. Count
# echo "Beginning count."
count_output=$home/test_count
dynast count -g $GTF --barcode-tag CB --umi-tag UB $align_dir/Aligned.sortedByCoord.out.bam -o $count_output --conversion TC
echo "Count complete."

# 5. Estimate
echo "Beginning estimate."

module load GCC/11.2.0
estimate_output=$home/testimate
dynast estimate -o $estimate_output $count_output
echo "Pipeline complete."
