#!/bin/bash

in_dir=${1:-"./sites"};
cat $(ls ${in_dir}/*.tsv) > all_pas.tmp;
sort -k1,1 -k2,2n -k3 all_pas.tmp | egrep $'chr[0-9XY]{1,2}\t' > all_pas_sort_ref.tmp;
awk -v OFS="\t" 'NR==1{pos=$1"\t"$2"\t"$3;n[$4]+=$5;tot_r+=$5;next}; $1"\t"$2"\t"$3==pos{n[$4]+=$5;tot_r+=$5;next};{for (key in n){ent-=(n[key]/tot_r)*log(n[key]/tot_r)/log(2) };print pos,tot_r,ent;delete n;ent=0;tot_r=0; pos=$1"\t"$2"\t"$3;n[$4]+=$5;tot_r+=$5}; END {for (key in n){ent-=(n[key]/tot_r)*log(n[key]/tot_r)/log(2) };print pos,tot_r,ent}' all_pas_sort_ref.tmp > all_pas_ent.tsv;
awk -v OFS="\t" '{print $1,$2,$2+1,".",$4,$3,$5}' all_pas_ent.tsv | sort -k1,1 -k2,2n > all_pas_with_entropy.bed;
#awk -v OFS="\t" '$7>0' all_pas_with_entropy.bed > all_pas_non0_entropy.bed;

rm all_pas*tmp all_pas_ent.tsv;
