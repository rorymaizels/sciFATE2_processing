#!/bin/bash
sample=$1
whitelist=$2
output=$3
gtf=$4
star=$5
fastq=$6
tmp=$7
tech="scifate"
align_dir=$output/alignment

# 4. Count
count_output=$output/count
count_tmp=${tmp}_C
THRESHOLD=0.5
dynast count -g $gtf --barcode-tag CB --umi-tag UB --barcodes $whitelist -o $count_output --conversion TC --tmp $count_tmp --snp-threshold $THRESHOLD $align_dir/Aligned.sortedByCoord.out.bam 

