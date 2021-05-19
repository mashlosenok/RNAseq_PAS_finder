#!/bin/bash
#PBS -l walltime=24:00:00 
#PBS -d /home/mvlasenok/GTEX_polyA/program/

cat $(ls ./sites/*.tsv) > all_pas.tmp;
sort -k1,1 -k2,2n -k3 all_pas.tmp | egrep $'chr[0-9XY]{1,2}\t' > all_pas_sort_ref.tmp;
awk -v OFS="\t" 'NR==1{pos=$1"\t"$2"\t"$3;n[$4]+=$5;tot_r+=$5;next}; $1"\t"$2"\t"$3==pos{n[$4]+=$5;tot_r+=$5;next};{for (key in n){ent-=(n[key]/tot_r)*log(n[key]/tot_r)/log(2) };print pos,tot_r,ent;delete n;ent=0;tot_r=0; pos=$1"\t"$2"\t"$3;n[$4]+=$5;tot_r+=$5}; END {for (key in n){ent-=(n[key]/tot_r)*log(n[key]/tot_r)/log(2) };print pos,tot_r,ent}' all_pas_sort_ref.tmp > all_pas_ent.tsv;
awk -v OFS="\t" '{print $1,$2,$2+1,".",$4,$3,$5}' all_pas_ent.tsv > all_pas_ent.bed;
awk -v OFS="\t" '$7>0{p[$1]+=1;print $1,$2,$3,$1"_pas"p[$1],$5,$6,$7}' all_pas_ent.bed > all_pas_ent_non0.bed;

rm all_pas*tmp

#awk -v OFS="\t" 'NR==1{pos=$1"\t"$2"\t"$3"\t"$4;tot_r+=$5;next}; $1"\t"$2"\t"$3"\t"$4==pos{tot_r+=$5;next}; {print pos,tot_r;tot_r=0;pos=$1"\t"$2"\t"$3"\t"$4; tot_r+=$5}; END {print pos,tot_r}' all_pas_sort_ref.tmp > all_pas_offset_reads.tsv;
#awk -v OFS="\t" '{print $1,$2,$2+1,".",$4,$3,$5}' all_pas_offset_reads.tsv > all_pas_offset_reads.bed;
