#!/bin/bash
sample=$1
whitelist=$2
output=$3
gtf=$4
star=$5
fastq=$6
tmp=$7
python_path=$8
tech="scifate"

# 1. Combine lanes and rename files
cat $fastq/$sample*L001_R1*gz $fastq/$sample*L002_R1*gz > $output/$sample.R1.fastq.gz 
cat $fastq/$sample*L001_R2*gz $fastq/$sample*L002_R2*gz > $output/$sample.R2.fastq.gz

# 2. Trim reads to defined length
$python_path/python $scripts/trim_reads.py $fastq/$
# 3. Align
CDNA_FASTQ=$output/$sample.R2.fastq.gz
BARCODE_UMI_FASTQ=$output/$sample.R1.fastq.gz 
align_dir=$output/alignment
align_tmp=${tmp}_A
dynast align -i $star -o $align_dir --tmp $align_tmp -w $whitelist -x $tech $CDNA_FASTQ $BARCODE_UMI_FASTQ 
