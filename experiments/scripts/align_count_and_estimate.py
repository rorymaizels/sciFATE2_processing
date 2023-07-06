import os
import sys
import gzip
import pandas as pd
import numpy as np


def trim_reads(folder, sample, r2_cutoff, trim_r1=True):
    if trim_r1:
        r1_cutoff = 18
        input_path = folder + "/" + sample + ".R1.fastq.gz"
        output_path = folder + "/tmp_" + sample + ".R1.fastq.gz"

        I = gzip.open(input_path)
        O = gzip.open(output_path, "wb")

        head = I.readline()
        O.write(head)
        while head:
            seq = I.readline().decode()
            O.write((seq[:r1_cutoff] + "\n").encode())
            sep = I.readline().decode()
            O.write(sep.encode())
            qcs = I.readline().decode()
            O.write((qcs[:r1_cutoff] + "\n").encode())            
            head = I.readline() #begin the next line
            O.write(head)
        I.close()
        O.close()

        os.system(f"rm {input_path}")
        os.system(f"mv {output_path} {input_path}")

    if r2_cutoff < 130:
        input_path = folder + "/" + sample + ".R2.fastq.gz"
        output_path = folder + "/tmp_" + sample + ".R2.fastq.gz"

        I = gzip.open(input_path)
        O = gzip.open(output_path, "wb")

        head = I.readline()
        O.write(head)
        while head:
            seq = I.readline().decode()
            O.write((seq[:r2_cutoff] + "\n").encode())
            sep = I.readline().decode()
            O.write(sep.encode())
            qcs = I.readline().decode()
            O.write((qcs[:r2_cutoff] + "\n").encode())            
            head = I.readline() #begin the next line
            O.write(head)
        I.close()
        O.close()

        os.system(f"rm {input_path}")
        os.system(f"mv {output_path} {input_path}")
    else:
        print(f"{sample} R2: No significant trimming required.")


def align(sample, whitelist, output, fastq, tmp, star, trim_cutoff, novaseq_system='S1'):

    # 1. combine lanes and rename samples
    os.system(f"mkdir -p {output}")

    if novaseq_system=='SP':
        os.system(
            f"cat {fastq}/{sample}*L001_R1*gz {fastq}/{sample}*L002_R1*gz > {output}/{sample}.R1.fastq.gz"
        )
        os.system(
            f"cat {fastq}/{sample}*L001_R2*gz {fastq}/{sample}*L002_R2*gz > {output}/{sample}.R2.fastq.gz"
        )
    elif novaseq_system=='S1':
        os.system(
            f"cat {fastq}/{sample}*R1*gz > {output}/{sample}.R1.fastq.gz"
        )
        os.system(
            f"cat {fastq}/{sample}*R2*gz > {output}/{sample}.R2.fastq.gz"
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
        f"dynast align -i {star} -t 32 -o {align_dir} --tmp {align_tmp} -w {whitelist} -x {tech} {CDNA_FASTQ} {BARCODE_UMI_FASTQ}"
    )

    # 4. clean up
    os.system(f"rm {output}/{sample}.R1.fastq.gz")
    os.system(f"rm {output}/{sample}.R2.fastq.gz")


def count(output, gtf, tmp, whitelist, snp_csv=None):
    alignment = f"{output}/alignment/Aligned.sortedByCoord.out.bam"
    count_output = f"{output}/count"
    count_tmp = f"{tmp}_C"
    os.system(
        f"dynast count -g {gtf} -t 32 --barcode-tag CB --umi-tag UB --barcodes {whitelist} -o {count_output} --conversion TC --tmp {count_tmp} --snp-csv {snp_csv} {alignment}"
    )


def estimate(output, tmp, p_e=None, method='alpha'):
    # os.system("module load GCC/11.3.0")
    count_output = f"{output}/count"
    estimate_output = f"{output}/estimate"
    est_tmp = f"{tmp}_E"
    if p_e:
        os.system(
            f"dynast estimate -o {estimate_output} -t 32 --method {method} --tmp {est_tmp} --p-e {p_e} {count_output}"
        )
    else:
        os.system(
            f"dynast estimate -o {estimate_output} -t 32 --method {method} --tmp {est_tmp} {count_output}"
        )


if __name__ == "__main__":
    # os.system("module load GCC/11.3.0")
    sample_csv_name = sys.argv[1]
    data_dir = sys.argv[2]
    meta_dir = sys.argv[3]
    dmpx_write = sys.argv[4]
    scripts = sys.argv[5]
    gtf = sys.argv[6]
    star = sys.argv[7]
    fastq = sys.argv[8]
    p_e = sys.argv[9]
    if p_e == "None":
        p_e = None
    snv_csv = sys.argv[10]
    trim_cutoff = int(sys.argv[11])
    do_estimate = bool(int(sys.argv[12]))
    task_id = int(sys.argv[13])
    n_tasks = int(sys.argv[14])
    est_method = sys.argv[15]
    seq_system = sys.argv[16]

    sample_df = pd.read_csv(dmpx_write + f"/{sample_csv_name}.csv", index_col=0)
    cur_tasks = np.array_split(sample_df.index, n_tasks)[task_id]

    for task in cur_tasks:
        # 0. definitions
        sample = sample_df.loc[task]["samples"]
        RT = sample_df.loc[task]["RT"]
        cur_whitelist = dmpx_write + f"/RT_{RT}.txt"
        cur_output = f"{data_dir}/{RT}/{sample}"

        # 1. create alignment
        cur_tmp = f"{data_dir}/{RT}/tmpA_{RT}_{sample}"
        align(
            sample,
            cur_whitelist,
            cur_output,
            fastq,
            cur_tmp,
            star,
            trim_cutoff,
            seq_system
        )

        # count edits
        cur_tmp = f"{data_dir}/{RT}/tmpC_{RT}_{sample}"
        count(cur_output, gtf, cur_tmp, cur_whitelist, snv_csv)
    if do_estimate:
        # do estimation separately because it takes ages
        for task in cur_tasks:
            sample = sample_df.loc[task]["samples"]
            RT = sample_df.loc[task]["RT"]
            cur_output = f"{data_dir}/{RT}/{sample}"
            cur_tmp = f"{data_dir}/{RT}/tmpE_{RT}_{sample}"
            estimate(cur_output, cur_tmp, p_e, method=est_method) 
