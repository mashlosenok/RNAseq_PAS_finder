#!/usr/bin/bash
ent_thr=$(echo $1 |grep -o entropy_[0-9]| grep -o [0-9])
awk -v OFS="\t" -v e=$ent_thr '$7>=e' all_pas_ent_non0.bed | cut -f1-6 |bedtools intersect -s -c -sorted -a - -b ./references/PAsignal_covered_reg_sort.bed > pas_entropy_${ent_thr}_signalCol.bed;
bedtools intersect -s -v -sorted -a pas_entropy_${ent_thr}_signalCol.bed -b ./references/AT_10_strict_positions_w1_sort.bed | bedtools intersect -v -sorted -a - -b ./references/repeat_tablehg19_sort.bed > pas_entropy_${ent_thr}_signalCol_filt.bed;
bedtools intersect -s -wa -sorted -a pas_entropy_${ent_thr}_signalCol_filt.bed -b ./references/genes_v34l37_w1000_noOverlap.bed > pas_entropy_${ent_thr}_signalCol_filt_in_genes.bed;
