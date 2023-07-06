import os
import sys
import gzip
import pandas as pd
import numpy as np


def trim_reads(folder, sample, cutoff):
    if cutoff < 180:
        input_path = folder + "/" + sample + ".R2.fastq.gz"
        output_path = folder + "/tmp_" + sample + ".R2.fastq.gz"

        I = gzip.open(input_path)
        O = gzip.open(output_path, "wb")

        head = I.readline()
        O.write(head)
        while head:
            seq = I.readline().decode()
            O.write((seq[:cutoff] + "\n").encode())
            sep = I.readline().decode()
            O.write(sep.encode())
            qcs = I.readline().decode()
            O.write((qcs[:cutoff] + "\n").encode())            
            head = I.readline() #begin the next line
            O.write(head)
        I.close()
        O.close()

        os.system(f"rm {input_path}")
        os.system(f"mv {output_path} {input_path}")
    else:
        print(f"{sample}: No significant trimming required.")


def align(sample, RT, PCR, whitelist, output, fastq, tmp, star, trim_cutoff):

    # 1. combine lanes and rename samples
    os.system(f"mkdir -p {output}")

    os.system(
        f"cat {fastq}/{sample}*L001_R1*gz {fastq}/{sample}*L002_R1*gz > {output}/{sample}.R1.fastq.gz"
    )
    os.system(
        f"cat {fastq}/{sample}*L001_R2*gz {fastq}/{sample}*L002_R2*gz > {output}/{sample}.R2.fastq.gz"
    )

    # 2. trim read 2
    trim_reads(output, sample, trim_cutoff)

    # 3. align
    CDNA_FASTQ = f"{output}/{sample}.R2.fastq.gz"
    BARCODE_UMI_FASTQ = f"{output}/{sample}.R1.fastq.gz"
    align_dir = f"{output}/alignment"
    align_tmp = f"{tmp}_A"
    tech = "scifate"
    os.system(
        f"dynast align -i {star} -o {align_dir} --tmp {align_tmp} -w {whitelist} -x {tech} {CDNA_FASTQ} {BARCODE_UMI_FASTQ}"
    )

    # 4. clean up
    os.system(f"rm {output}/{sample}.R1.fastq.gz")
    os.system(f"rm {output}/{sample}.R2.fastq.gz")


def count(output, gtf, tmp, whitelist, snp_threshold):
    alignment = f"{output}/alignment/Aligned.sortedByCoord.out.bam"
    count_output = f"{output}/count"
    count_tmp = f"{tmp}_C"
    os.system(
        f"dynast count -g {gtf} --barcode-tag CB --umi-tag UB --barcodes {whitelist} -o {count_output} --conversion TC --snp-threshold {snp_threshold} --control --tmp {count_tmp} {alignment}"
    )


def estimate(output, tmp):
    os.system("module load GCC/11.2.0")
    count_output = f"{output}/count"
    estimate_output = f"{output}/estimate"
    est_tmp = f"{tmp}_E"
    os.system(
        f"dynast estimate -o {estimate_output} --control --tmp {est_tmp} {count_output}"
    )


if __name__ == "__main__":
    sample_csv_name = sys.argv[1]
    data_dir = sys.argv[2]
    meta_dir = sys.argv[3]
    scripts = sys.argv[4]
    gtf = sys.argv[5]
    star = sys.argv[6]
    fastq = sys.argv[7]
    trim_cutoff = int(sys.argv[8])
    snp_threshold = float(sys.argv[9])
    task_id = int(sys.argv[10])
    n_tasks = int(sys.argv[11])

    sample_df = pd.read_csv(meta_dir + f"/{sample_csv_name}.csv", index_col=0)
    cur_tasks = np.array_split(sample_df.index, n_tasks)[task_id]

    for task in cur_tasks:
        # 0. definitions
        sample = sample_df.loc[task]["samples"]
        RT = sample_df.loc[task]["RT"]
        PCR = sample_df.loc[task]["PCR"]
        cur_whitelist = meta_dir + f"/{RT}_RT_samples.txt"
        cur_output = f"{data_dir}/{RT}_{PCR}/{sample}"
        cur_tmp = f"{data_dir}/{RT}_{PCR}/tmp_{RT}_{PCR}_{sample}"

        # 1. create alignment
        align(
            sample,
            RT,
            PCR,
            cur_whitelist,
            cur_output,
            fastq,
            cur_tmp,
            star,
            trim_cutoff,
        )

        # count edits
        count(cur_output, gtf, cur_tmp, cur_whitelist, snp_threshold)

    # do estimation separately because it takes ages
    for task in cur_tasks:
        sample = sample_df.loc[task]["samples"]
        RT = sample_df.loc[task]["RT"]
        PCR = sample_df.loc[task]["PCR"]
        cur_output = f"{data_dir}/{RT}_{PCR}/{sample}"
        cur_tmp = f"{data_dir}/{RT}_{PCR}/tmp_{RT}_{PCR}_{sample}"
        estimate(cur_output, cur_tmp)
