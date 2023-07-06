#!/bin/bash

echo "Changing fastq file names to remove the sample and lane information. Condensing two lanes into one."

folder=$1
samples=$2

new_folder=${folder}_renamed
mkdir -p $new_folder

for sample in $(cat $samples); 
do 
	cat $folder/$sample*L001_R1*gz $folder/$sample*L002_R1*gz > $new_folder/$sample.R1.fastq.gz 
	cat $folder/$sample*L001_R2*gz $folder/$sample*L002_R2*gz > $new_folder/$sample.R2.fastq.gz
done


echo
echo "Fastq renaming complete."
echo

