import sys
import pandas as pd 
import numpy as np

def process_samples(home, write_loc, experiment_id, excel_file_name, odt_sample_dict):
    xl = pd.read_excel(f'{home}/metadata/{excel_file_name}', header=1)
    xl = xl[xl['Submitted Pool ID']==experiment_id]
    
    pcr = xl[xl.columns[:2]].reset_index(drop=True)
    pcr = pcr.sort_values('Sample Name')
    pcr['plate']=[item for sublist in [[i]*96 for i in [1,2,3,4]] for item in sublist]
    pcr['well']=[a+n for a in 'ABCDEFGH' for n in [str(i) for i in np.arange(12)+1]]*4
    pcr['384_plate'] = [row+str(col) for q1 in range(2) for q2 in range(1,3) 
                        for row in 'ABCDEFGHIJKLMNOP'[q1::2] for col in range(q2,25,2)]
    
    odt = pd.read_csv(f'{home}/metadata/RT_barcodes.txt', header=None)
    odt.columns = ['barcode']
    odt['plate']=[item for sublist in [[i]*96 for i in [1,2,3,4]] for item in sublist]
    odt['well']=[a+n for a in 'ABCDEFGH' for n in [str(i) for i in np.arange(12)+1]]*4
    odt['384_plate'] = [row+str(col) for q1 in range(2) for q2 in range(1,3) 
                        for row in 'ABCDEFGHIJKLMNOP'[q1::2] for col in range(q2,25,2)]
    odt['384_row'] = [a[0] for a in odt['384_plate']]
    odt['384_col'] = [int(a[1:]) for a in odt['384_plate']]
    
    odt['sample_name'] = 'TBC'
    for key, val in odt_sample_dict.items():
        odt.loc[[o in val[1] for o in odt[val[0]]],'sample_name'] = key
    
    pcr.to_csv(f"{write_loc}/{experiment_id}_PCR_samples2wells.csv")
    ids = pcr['Sample limsid']
    f = open(f"{write_loc}/PCR.txt","w")
    for i in ids:
        f.write(i+'\n')
    f.close()

    odt.to_csv(f"{write_loc}/{experiment_id}_ODT_samples2wells.csv")              
    for sample in odt.sample_name.unique():
        ids = odt[odt.sample_name==sample]['barcode']
        f = open(f"{write_loc}/RT_{sample}.txt","w")
        for i in ids:
            f.write(i+'\n')
        f.close()


if __name__ == "__main__":
    # user defined
    ODT = {
        'all':['384_col',[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]]
    }
    home = sys.argv[1]
    write_loc = sys.argv[2]
    exp_id = sys.argv[3]
    excel = sys.argv[4]
    process_samples(home, write_loc, exp_id, excel, ODT)

