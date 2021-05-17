#!/bin/bash

#script to generate positions of A- or T-runs borders from fasta files of chromosomes. For filtering.

OUT_DIR="./references/"
 
# fasta files for chromosomes:
for CHR_FILE_PATH in $(ls hg19_chr/*fa); do
    CHR=$(basename $CHR_FILE_PATH .fa)
    tail ${CHR_FILE_PATH} -n +2 | tr -d '\n' | grep -aob -P -i '(?<=A{10})[^A]' | cut -f1 -d: | awk -v chr=$CHR -v OFS="\t" '{print chr,$1-1,$1+1,".",0,"+"}' > ${OUT_DIR}/${CHR}_A.bed
    tail ${CHR_FILE_PATH} -n +2 | tr -d '\n' | grep -aob -P -i '[^T]T{10}' | cut -f1 -d: | awk -v chr=$CHR -v OFS="\t" '{print chr,$1-1,$1+1,".",0,"-"}' > ${OUT_DIR}/${CHR}_T.bed
done
cat chr*_[AT].bed | sort -k1,1 -k2,2n > PAsignal_pos_sort.bed
rm chr*_[AT].bed
