import os
import sys
import numpy as np
import pandas as pd

if __name__ == "__main__":
    control_dir = sys.argv[1]
    write_loc = sys.argv[2]
    file_pattern = sys.argv[3]

    dirs = [d for d in os.listdir(control_dir) if d[:3]==file_pattern[:3]]

    pes = []
    for di in dirs:
        try:
            p = pd.read_csv(control_dir+'/'+di+'/estimate/p_e.csv',header=None).values[0][0]
            pes.append(p)
        except:
            pass

    f = open(write_loc+f"/global_pe.csv","w")
    f.write(str(np.mean(pes)))
    f.close()
        
    snps = []
    for di in dirs:
        try:
            s = pd.read_csv(control_dir+'/'+di+'/count/snps.csv', index_col=0)
            snps.append(s)
        except:
            pass
        
    snp = pd.concat(snps)
    snp_unique = snp.drop_duplicates()
    snp_unique.to_csv(write_loc+f'/global_snps.csv')
