#!/bin/bash
#SBATCH --job-name=sf_sub
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --time=3-00:00:00
#SBATCH --mem=150G
#SBATCH --partition=cpu
#SBATCH --array=1-3
#SBATCH --output=sfTMP_sub%a.out

### ARGS
STAR=$1
GTF=$2

### GLOBALS
home="/camp/lab/briscoej/working/Rory/transcriptomics/sciFATE_data/FATE_PILOT1"
fastq=$home/fastq
data_dir=$home/data
meta_dir=$home/metadata
scripts=$home/scripts

# declare -a RT_samples=("NT" "OT" "MT" "NT" "OT" "MT")
# declare -a PCR_samples=("old" "old" "old" "new" "new" "new")

declare -a RT_samples=("NT" "OT" "MT")
declare -a PCR_samples=("new" "new" "new")


TARGET_ARRAY_ID=`expr ${SLURM_ARRAY_TASK_ID} - 1`
RT=${RT_samples[TARGET_ARRAY_ID]}
PCR=${PCR_samples[TARGET_ARRAY_ID]}

output_folder=$data_dir/${RT}_${PCR}
cur_samples=$meta_dir/${PCR}_protocol_samples_tmp.txt
cur_whitelist=$meta_dir/${RT}_samples.txt

# 1. Align
for sample in $(cat $cur_samples); do
	echo $sample
	cur_output=$output_folder/$sample
	cur_tmp=$output_folder/tmp_${RT}_${PCR}_${sample}
	mkdir -p $cur_output
	sh $scripts/sample_align.sh $sample $cur_whitelist $cur_output $GTF $STAR $fastq $cur_tmp
	sh $scripts/sample_count.sh $sample $cur_whitelist $cur_output $GTF $STAR $fastq $cur_tmp
done

# 3. Estimate
for sample in $(cat $cur_samples); do
	echo $sample
	cur_output=$output_folder/$sample
	cur_tmp=$output_folder/tmp_${RT}_${PCR}_${sample}
	sh $scripts/sample_estimate.sh $sample $cur_whitelist $cur_output $GTF $STAR $fastq $cur_tmp
done

# # 1. Align
# for sample in $(cat $cur_samples); do
# 	echo $sample
# 	cur_output=$output_folder/$sample
# 	cur_tmp=$output_folder/tmp_${RT}_${PCR}_${sample}
# 	mkdir -p $cur_output
# 	sh $scripts/sample_align.sh $sample $cur_whitelist $cur_output $GTF $STAR $fastq $cur_tmp
# done

# # 2. Count
# for sample in $(cat $cur_samples); do
# 	echo $sample
# 	cur_output=$output_folder/$sample
# 	cur_tmp=$output_folder/tmp_${RT}_${PCR}_${sample}
# 	sh $scripts/sample_count.sh $sample $cur_whitelist $cur_output $GTF $STAR $fastq $cur_tmp
# done


