import os
import sys
import gzip

def trim_reads(folder, sample, cutoff):
    input_path = folder+'/'+sample+".R2.fastq.gz"
    output_path = folder'/tmp_'+sample+".R2.fastq.gz"

    I = gzip.open(input_path)
    O = gzip.open(output_path, 'wb')

    head = I.readline()
    O.write(head)
    while head:
        seq = I.readline().decode()
        O.write((seq[:cutoff]+'\n').encode())
        O.write(I.readline()) #l3
        O.write(I.readline()) #l4
        head = I.readline()
        O.write(head) #l1
    I.close()
    O.close()
    
    os.system(f"rm {input_path}")
    os.system(f"mv {output_path} {input_path}")
    
if __name__ == "__main__":
    folder = sys.argv[1]
    sample = sys.argv[2]
    cutoff = int(sys.argv[3])
    trim_reads(folder, sample, cutoff)