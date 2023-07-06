import sys
import pandas as pd 
import numpy as np

if __name__ == "__main__":
    RT_samples = sys.argv[1].split(',')
    write_dir = sys.argv[2]
    sample_csv_name = sys.argv[3]
    df = pd.DataFrame({})
    pcr_samples = write_dir+f'/PCR.txt'
    for RT in RT_samples:
        tmp_df = pd.read_csv(pcr_samples, header=None)
        tmp_df.rename(columns = {0:'samples'}, inplace = True)
        tmp_df['RT'] = RT
        df = df.append(tmp_df)
    df = df.reset_index().drop('index',axis=1)
    df.to_csv(write_dir+f'/{sample_csv_name}.csv')
