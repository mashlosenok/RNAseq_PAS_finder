#!/bin/bash

ent_thr=${1:-1};
AT_file="./references/AT_10_strict_positions.bed";
signal_file="./references/PAsignal_covered_reg.bed";

awk -v OFS="\t" -v e=$ent_thr '$7>=e' all_pas_with_entropy.bed | cut -f1-6 | \
bedtools intersect -s -v -sorted -a - -b $AT_file | \
bedtools intersect -s -c -sorted -a - -b $signal_file | \
sort -k1,1 -k2,2n > pas_entropy_${ent_thr}.bed;
if [ -s pas_entropy_${ent_thr}.bed ]; then
echo "merging PAS in" pas_entropy_${ent_thr}.bed;
bedtools merge -d 11 -s -c 4,5,6,7 -o distinct,sum,distinct,sum -i pas_entropy_${ent_thr}.bed | \
sort -k1,1 -k2,2n | \
awk -v OFS="\t" '{print $1,$2,$3,$4,$5,$6,($7>0)?"+signal":"-signal"}' > pasc_entropy_${ent_thr}.bed;
else
echo "No PAS with entropy >=" $ent_thr;
fi
