import sys
import pandas as pd 
import numpy as np

# user defined
EXPERIMENT_ID = 'SCIFATE_PILOT_4'
EXCEL = 'PM20196.xlsx'
ODT = {
    'NT':['plate',[1]],
    'IO':['plate',[2]],
    'DI':['plate',[3]],
    'FT':['plate',[4]]
}
PCR = {
    'old':['plate',[1]],
    'qia':['plate',[2]],
    'zym':['plate',[3]],
    'pub':['plate',[4]]
}

def process_samples(home, experiment_id, excel_file_name, odt_sample_dict, pcr_sample_dict):
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
    
    odt['sample_name'] = 'TBC'
    for key, val in odt_sample_dict.items():
        odt.loc[[o in val[1] for o in odt[val[0]]],'sample_name'] = key

    pcr['sample_name'] = 'TBC'
    for key, val in pcr_sample_dict.items():
        pcr.loc[[p in val[1] for p in pcr[val[0]]],'sample_name'] = key
    
    pcr.to_csv(f"{home}/metadata/PCR.csv")          
    for sample in pcr.sample_name.unique():
        ids = pcr[pcr.sample_name==sample]['Sample limsid']
        f = open(f"{home}/metadata/PCR_{sample}.txt","w")
        for i in ids:
            f.write(i+'\n')
        f.close()

    odt.to_csv(f"{home}/metadata/ODT.csv")              
    for sample in odt.sample_name.unique():
        ids = odt[odt.sample_name==sample]['barcode']
        f = open(f"{home}/metadata/RT_{sample}.txt","w")
        for i in ids:
            f.write(i+'\n')
        f.close()


if __name__ == "__main__":
    home = sys.argv[1]
    process_samples(home, EXPERIMENT_ID, EXCEL, ODT, PCR)

