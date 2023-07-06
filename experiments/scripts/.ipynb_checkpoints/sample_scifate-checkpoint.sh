#!/bin/bash
sample=$1
whitelist=$2
output=$3
gtf=$4
star=$5
fastq=$6
tmp=$7
tech="scifate"

cat $fastq/$sample*L001_R1*gz $fastq/$sample*L002_R1*gz > $output/$sample.R1.fastq.gz 
cat $fastq/$sample*L001_R2*gz $fastq/$sample*L002_R2*gz > $output/$sample.R2.fastq.gz

# 3. Align
CDNA_FASTQ=$output/$sample.R2.fastq.gz
BARCODE_UMI_FASTQ=$output/$sample.R1.fastq.gz 
align_dir=$output/alignment
align_tmp=${tmp}_A
dynast align -i $star -o $align_dir --tmp $align_tmp -w $whitelist -x $tech $CDNA_FASTQ $BARCODE_UMI_FASTQ 

# 4. Count
count_output=$output/count
count_tmp=${tmp}_C
THRESHOLD=0.3
dynast count -g $gtf --barcode-tag CB --umi-tag UB --barcodes $whitelist -o $count_output --conversion TC --tmp $count_tmp --snp-threshold $THRESHOLD $align_dir/Aligned.sortedByCoord.out.bam 

# 5. Estimate
module load GCC/11.2.0
estimate_output=$output/estimate
est_tmp=${tmp}_E
dynast estimate -o $estimate_output --tmp $est_tmp $count_output 

# 6. Cleanup
rm $output/$sample.R1.fastq.gz 
rm $output/$sample.R2.fastq.gz