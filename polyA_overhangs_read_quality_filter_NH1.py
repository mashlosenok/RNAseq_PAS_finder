import sys
import os, fnmatch
import pysam
import collections
import numpy as np

if len(sys.argv) >= 3:    
	filename = sys.argv[1]
	out_dir = sys.argv[2]
	print("Warning: only first two arguments are used")
elif len(sys.argv) == 2:
	filename = sys.argv[1]
	out_dir="sites"
else:	
	print("Error: filename as argument needed")

def polyA_overhangs(filename, out_dir):
    name=os.path.basename(filename).split(".")[0]
    samfile = pysam.AlignmentFile(filename, "rb")
    pas_reads_file = pysam.AlignmentFile("pAread_bams/"+name+"_pAreads.bam", "wb", template=samfile)
    counts = collections.Counter()
    d=dict()
    for read in samfile.fetch():
        cigar = read.cigar
        if np.mean(read.get_forward_qualities()) > 12 and read.get_tag("NH")==1:
            if cigar[0][0] == 4 and \
            cigar[0][1] >= 6:
                soft_cl=cigar[0][1];
                if read.query_sequence[:soft_cl].count("T") >=  0.8*soft_cl:
                    counts.update(["\t".join([read.reference_name,str(read.reference_start+1),'-',str(soft_cl)])])
                    pas_reads_file.write(read)
            if cigar[-1][0] == 4 and \
            cigar[-1][1] >= 6:
                soft_cl=cigar[-1][1]
                if read.query_sequence[-soft_cl:].count("A") >=  0.8*soft_cl:
                    counts.update(["\t".join([read.reference_name,str(read.reference_end),'+',str(soft_cl)])])
                    pas_reads_file.write(read)
    pas_reads_file.close()
    samfile.close()
    with open(out_dir+"/"+name+".tsv",'w') as out:
        out.write("\t".join(['chr','position','strand','overhang','NReads'])+"\n")
        for line in counts:
            out.write("\t".join([line,str(counts[line])])+'\n')
            key=line.rsplit('\t',1)[0];
            if key in d:
                d.update({key:np.append(d[key],counts[line])})
            else:
                d.update({key:np.array([counts[line]])})

if not os.path.exists(out_dir):
	os.makedirs(out_dir)
	
if not os.path.exists('pAread_bams'):
	os.makedirs('pAread_bams')	

polyA_overhangs(filename, out_dir)
