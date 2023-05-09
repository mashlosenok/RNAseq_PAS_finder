SHELL:=/bin/bash
vpath %.bam bams
vpath %.tsv sites
vpath %.bai bams
ENT?=1
tsvs=$(shell ls bams/|grep "bam$$" |sed 's/bam/tsv/')

all: pasc_entropy_$(ENT).bed

pasc_entropy_$(ENT).bed: all_pas_with_entropy.bed references/PAsignal_covered_reg.bed references/AT_10_strict_positions.bed 
	./filter_pas.sh $(ENT)
	@if [ $(ENT) -eq 1 ] && cmp -s pasc_entropy_$(ENT).bed pasc_entropy_1_test.bed; then \
	echo "successful test run for entropy threshold=1"; fi


all_pas_with_entropy.bed: $(tsvs)
	./pooled_pas_compute_entropy.sh

$(tsvs): %.tsv: %.bam %.bam.bai
	python polyA_overhangs_read_quality_filter_NH1.py bams/$(shell basename $@ .tsv).bam  

#references/PAsignal_covered_reg.bed: references/genome 
#	./references/PAsignal.sh ./references/genome/
#	references/genome/ has to contain fasta files with chr sequences. 
    
#references/AT_10_strict_positions.bed: references/genome 
#	./references/AT10_positions.sh ./references/genome/
#	references/genome/ has to contain fasta files with chr sequences. 

#references/genome: 
#	mkdir references/genome; rsync -azP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/ references/genome/; gunzip references/genome/chr*.fa.gz

clean:
	rm sites/*tsv pAread_bams/*bam all_pas_with_entropy.bed pasc_entropy_1.bed pas_entropy_1.bed	

