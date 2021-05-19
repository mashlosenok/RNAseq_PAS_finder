SHELL:=/bin/bash
vpath %.bam bams
vpath %.tsv sites

all: pas_entropy_1_signalCol.bed pas_entropy_2_signalCol.bed pas_entropy_3_signalCol.bed

pas_entropy_1_signalCol.bed pas_entropy_2_signalCol.bed pas_entropy_3_signalCol.bed: all_pas_ent_non0.bed references/PAsignal_covered_reg_sort.bed references/AT_10_strict_positions_w1_sort.bed references/repeat_tablehg19_sort.bed references/genes_v34l37_w1000_noOverlap.bed
	./filter_pas.sh $@;

all_pas_ent_non0.bed: sites $(shell ls bams/|grep bai |sed 's/bam.bai/tsv/')
	echo $^;
	./all_pas_pooled_ent.sh

%.tsv: %.bam sites
	module load ScriptLang/python/2.7u3_2019i;
	echo bams/$(shell basename $@ .tsv).bam;     
	python2 polyA_overhangs_collection_maxM20.py bams/$(shell basename $@ .tsv).bam  

sites:
	mkdir sites
    
references/PAsignal_covered_reg_sort.bed:
	./references/PAsignal.sh
    
references/AT_10_strict_positions_w1_sort.bed:
	./references/AT10_positions_w1_sort.sh
