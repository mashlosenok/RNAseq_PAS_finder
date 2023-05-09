#!/bin/bash

#script to generate positions of polyadenylation signal from fasta files of chromosomes. For filtering.

OUT_DIR="."
GENOME_DIR=${1:-"./references/genome"}

# fasta files for chromosomes:
for CHR_FILE_PATH in $(ls ${GENOME_DIR}/*fa); do
    CHR_NAME=$(basename $CHR_FILE_PATH .fa); 
    tail ${CHR_FILE_PATH} -n +2 | tr -d '\n' | grep -aob -i '[ATGC]ATAAA\|A[CGTA]TAAA\|AAT[TCGA]AA\|AATA[TCGA]A' > ${OUT_DIR}/${CHR_NAME}.start_pos+.tmp;
    tail ${CHR_FILE_PATH} -n +2 | tr -d '\n' | grep -aob -i 'T[TCGA]TATT\|TT[TCGA]ATT\|TTTA[TCGA]T\|TTTAT[TCGA]' > ${OUT_DIR}/${CHR_NAME}.start_pos-.tmp;
    done
cd ${OUT_DIR};
awk -v OFS="\t" -v FS=":" 'FNR==1{split(FILENAME,name,".")};{print name[1],$1,$1+5,$2,substr(name[2],length(name[2]),1)}' chr*.start_pos*.tmp >> PAsignal_pos0.bed
awk -v OFS="\t" '{print $1,($5=="+")?$2-40:$2,($5=="+")?$3:$3+40,$4,0,$5}' PAsignal_pos0.bed | sort -k1,1 -k2,2n | uniq  > PAsignal_covered_reg.bed;
rm chr*.start_pos*.tmp PAsignal_pos0.bed;
