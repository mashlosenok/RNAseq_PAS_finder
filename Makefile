SHELL:=/bin/bash
vpath %.bam bams
vpath %.tsv sites
vpath %.bai bams
ENT?=1
tsvs=$(shell ls bams/|grep "bam$$" |sed 's/bam/tsv/')

all: pasc_entropy_$(ENT).bed 

pasc_entropy_$(ENT).bed: pas_entropy_$(ENT).bed
	@echo "entropy threshold " $(ENT); \
	if [ -s $^ ]; then \
	echo "merging" $^; \
       	bedtools merge -d 11 -s -c 4,5,6,7 -o distinct,sum,distinct,sum -i pas_entropy_$(ENT).bed | \
	sort -k1,1 -k2,2n | \
	awk -v OFS="\t" '{print $$1,$$2,$$3,$$4,$$5,$$6,($$7>0)?"+signal":"-signal"}' > pasc_entropy_$(ENT).bed; \
	else \
	echo "Error: no PAS with entropy >=" $(ENT); \
	fi

pas_entropy_$(ENT).bed: all_pas_non0_entropy.bed references/PAsignal_covered_reg.bed references/AT_10_strict_positions.bed 
	./filter_pas.sh $(ENT)

all_pas_non0_entropy.bed: sites $(tsvs)
	./pooled_pas_compute_entropy.sh

$(tsvs): %.tsv: %.bam %.bam.bai sites pAread_bams
	python polyA_overhangs_read_quality_filter_NH1.py bams/$(shell basename $@ .tsv).bam  

sites:
	mkdir sites

pAread_bams:
	mkdir pAread_bams

#references/PAsignal_covered_reg.bed:
#	wget -qO references/PAsignal_covered_reg.bed.gz "https://zenodo.org/record/7799648/files/PAS_finder/PAsignal_covered_reg.bed.gz?download=1"; gunzip references/PAsignal_covered_reg.bed.gz; 
#	OR ./references/PAsignal.sh, but then references/genome/ has to contain faste files with chr sequences. 
    
#references/AT_10_strict_positions.bed:
#	wget -qO references/AT_10_strict_positions.bed.gz "https://zenodo.org/record/7799648/files/PAS_finder/AT_10_strict_positions.bed.gz?download=1"; gunzip references/AT_10_strict_positions.bed.gz;
#	OR ./references/AT10_positions.sh, but then references/genome/ has to contain faste files with chr sequences. 

#references/genome: 
#	mkdir references/genome; rsync -azP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/ references/genome/; gunzip references/genome/*.fa.gz
