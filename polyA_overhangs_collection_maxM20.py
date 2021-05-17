import sys
import os, fnmatch
import pysam
import collections
#import pandas as pd
import numpy as np

if len(sys.argv) == 2:    
    filename = sys.argv[1]
else:
    print("filename as arguement needed")

def polyA_overhangs(filename, name):
    samfile = pysam.AlignmentFile(filename, "rb")
    with open(name,'w') as out:
        out.write("\t".join(['chr','position','strand','overhang','NReads'])+"\n")
        counts = collections.Counter()
        for read in samfile.fetch():
            cigar = read.cigar
            seq = read.query_sequence
            if len(cigar) > 1:
                cigar_maxM = max([i[1] for i in cigar if i[0]==0])
                if cigar[0][0] == 4 and \
                cigar[0][1] >= 4 and \
                cigar[1][0] == 0 and \
                cigar_maxM >= 20:
                    soft_cl=cigar[0][1]
                    if seq[:soft_cl].count("T") >= 0.8*soft_cl:
                        counts.update(["\t".join(
                            [read.reference_name,str(read.reference_start+1),'-',str(soft_cl)])])
                if cigar[-2][0] == 0 and \
                cigar_maxM >= 20 and \
                cigar[-1][0] == 4 and \
                cigar[-1][1] >= 4:
                    soft_cl=cigar[-1][1]
                    if seq[-soft_cl:].count("A") >= 0.8*soft_cl:
                        counts.update(["\t".join(
                            [read.reference_name,str(read.reference_end),'+',str(soft_cl)])])
        for line in counts:
            out.write("\t".join([line,str(counts[line])])+'\n') 
    samfile.close()

name=os.path.basename(filename).split(".")[0]
polyA_overhangs(filename, "sites/"+name+".tsv")