#!/usr/bin/bash

mkdir -p ./sites

#identify candidate PAS based on A-rich softclips
module load ScriptLang/Anaconda/5.1/3.6
for BAM_FILE in $(ls ./bams/*bam); do
    python ./polyA_overhangs_collection_maxM20.py $BAM_FILE
done;

#pool together candidate sites from all files in bams/
cat $(ls ./sites/*.tsv) > all_pas.tmp;
sort -k1,1 -k2,2n -k3 all_pas.tmp | egrep $'chr[0-9XY]{1,2}\t' > all_pas_sort_ref.tmp;

#calculate pooled Shannon entropy for each candidate polyadenylation site:
awk -v OFS="\t" 'NR==1{pos=$1"\t"$2"\t"$3;n[$4]+=$5;tot_r+=$5;next}; $1"\t"$2"\t"$3==pos{n[$4]+=$5;tot_r+=$5;next};{for (key in n){ent-=(n[key]/tot_r)*log(n[key]/tot_r)/log(2) };print pos,tot_r,ent;delete n;ent=0;tot_r=0; pos=$1"\t"$2"\t"$3;n[$4]+=$5;tot_r+=$5}; END {for (key in n){ent-=(n[key]/tot_r)*log(n[key]/tot_r)/log(2) };print pos,tot_r,ent}' all_pas_sort_ref.tmp > all_pas_ent.tsv;
awk -v OFS="\t" '{print $1,$2,$2+1,".",$4,$3,$5}' all_pas_ent.tsv > all_pas_ent.bed;
awk -v OFS="\t" '$7>0{p[$1]+=1;print $1,$2,$3,$1"_pas"p[$1],$5,$6,$7}' all_pas_ent.bed > all_pas_ent_non0.bed;

for ent_thr in 1 2 3; do 
    #filtering by Shannon entropy
    awk -v OFS="\t" -v e=$ent_thr '$7>=e' all_pas_ent_non0.bed | cut -f1-6 |bedtools intersect -s -c -sorted -a - -b ./references/PAsignal_covered_reg_sort.bed > pas_pooled_entropy_${ent_thr}_signal1Col.bed;
    bedtools intersect -s -v -sorted -a pas_pooled_entropy_${ent_thr}_signal1Col.bed -b ./references/AT_10_positions_w1_sort.bed | bedtools intersect -v -sorted -a - -b ./references/repeat_tablehg19_sort.bed > pas_pooled_entropy_${ent_thr}_signal1Col_noRep_noA.bed;
    bedtools intersect -s -wa -sorted -a pas_pooled_entropy_${ent_thr}_signal1Col_noRep_noA.bed -b ./references/genes_v34l37_+-1000_noOverlap.bed > pas_pooled_entropy_${ent_thr}_signal1Col_noRep_noA_in_genes.bed;
done;

rm all_pas*tmp
