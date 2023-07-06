import sys
import pandas as pd 
import numpy as np

if __name__ == "__main__":
    RT_samples = sys.argv[1].split(',')
    PCR_samples = sys.argv[2].split(',')
    meta_dir = sys.argv[3]
    sample_csv_name = sys.argv[4]
    df = pd.DataFrame({})
    for PCR in PCR_samples:
        for RT in RT_samples:
            cur_samples=meta_dir+f'/PCR_{PCR}.txt'
            tmp_df = pd.read_csv(cur_samples, header=None)
            tmp_df.rename(columns = {0:'samples'}, inplace = True)
            tmp_df['PCR'] = PCR
            tmp_df['RT'] = RT
            df = df.append(tmp_df)
    df = df.reset_index().drop('index',axis=1)
    df.to_csv(meta_dir+f'/{sample_csv_name}.csv')
