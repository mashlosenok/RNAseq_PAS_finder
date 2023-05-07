#!/bin/bash

ent_thr=$1;
awk -v OFS="\t" -v e=$ent_thr '$7>=e' all_pas_non0_entropy.bed | cut -f1-6 | \
bedtools intersect -s -v -sorted -a - -b ./references/AT_10_strict_positions.bed | \
bedtools intersect -s -c -sorted -a - -b ./references/PAsignal_covered_reg.bed | \
sort -k1,1 -k2,2n > pas_entropy_${ent_thr}.bed;
