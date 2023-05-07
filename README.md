# RNAseq_PAS_finder
RNA-seq based polyadenylation sites (PAS) identification using adenine-rich softclips.

## Input
By default *RNAseq_PAS_finder* identifies PAS from all .bam files stored in `bams/` direcory. The input files have to be indexed.

## Output
List of polyadenylation clusters (PASC) with number of supporting polyA reads.

## Setting up

Clone this repository to your local system.
```
git clone https://github.com/mashlosenok/RNAseq_PAS_finder.git
cd RNAseq_PAS_finder
```
Install and start [Docker](https://docs.docker.com/get-docker/) to run a container. 
Build a local image from `Dockerfile` and run an interactive container with mounted `RNAseq_PAS_finder` directory.
```
docker build --tag my_image_name .
docker run -v path_to_folder/RNAseq_PAS_finder:/home/RNAseq_PAS_finder -it my_image_name /bin/bash
```
You should be in `/home/RNAseq_PAS_finder` directory in the container. 

## Test run
`bams/` folder contains three small indexed bam files. Run `make` in `RNAseq_PAS_finder` directory in the container to get `.bed` file with polyadenylation sites from all `.bam` files in `bams/` folder.



In output bed files candidate polyadenylation sites are filtered: 
  -  by pooled Shannon entropy (entropy >= n) -- pas_entropy_{n}_signalCol_filt.bed
  -  for intersection with genomic A- or T-runs -- pas_entropy_{n}_signalCol_filt.bed
  -  additional file contains PAS overlapping with annotated genes -- pas_entropy_{n}_signalCol_filt_in_genes.bed

The output files also contain information about polyadenylation signal in upstrean 40bp region.

Output file format: the 5th column represents number of reads supporting the PAS, and the 7th column - the number of polyadenylation signals found up to 40 bp upstream of the PAS start. 

Annotation: GENCODE v34lift37. 
Requires: bedtools; pysam, collections.

Dedicated presentation:
https://www.researchgate.net/publication/344404962_De_novo_identification_of_polyadenylation_sites_from_RNA-seq_data
