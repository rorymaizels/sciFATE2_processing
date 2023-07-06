#!/bin/bash
sample=$1
whitelist=$2
output=$3
gtf=$4
star=$5
fastq=$6
tmp=$7
tech="scifate"
count_output=$output/count

# 5. Estimate
module load GCC/11.2.0
estimate_output=$output/estimate
est_tmp=${tmp}_E
dynast estimate -o $estimate_output --tmp $est_tmp $count_output 

# 6. Cleanup
