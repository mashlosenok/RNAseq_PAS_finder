# RNAseq_PAS_finder
Polyadenylation sites (PAS) identification from short RNA-seq reads with non-templated adenines (polyA reads).

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

## Pipeline

### Step 1. PAS for each sample

Identify polyA reads and PAS in each bam file:
```
for f in bams/*bam
do python polyA_overhangs_read_quality_filter_NH1.py f 
done
```
PolyA reads are reads containing a soft clipped region of at least six nucleotides that consists of 80% or more adenines. The script selects uniquely mapped polyA reads with good sequencing quality (average quality >12).

#### Usage:
`python polyA_overhangs_read_quality_filter_NH1.py bam_name.bam [sites_output_dirname]` 

Arguments
- bam_name.bam - indexed bamfile (global or local path)
- sites_output_dirname - name of the directory, where output .tsv files with PAS positions will be stored (optional, default value "sites").

Output
- sites_output_dirname/bam_name.tsv - table with candidate PAS, columns: chr, position, strand, overhang length in nt, number of supporting polyA reads. First row is the header.
- pAread_bams/bam_name_pAreads.bam - bam file with polyA reads. Bam header is copied from the input `bam_name.bam`. 
Both `sites_output_dirname` and `pAread_bams` folders are created in the current working directory. 

### Step 2. Pool PAS and filter by Shannon entropy

```
./pooled_pas_compute_entropy.sh
./filter_pas.sh 1
```
`./pooled_pas_compute_entropy.sh` concatenates all .tsv files from `./sites/` directory, for each candidate PAS computes total polyA read support and total entropy of overhang lengths distribution. Outputs `all_pas_with_entropy.bed` and `all_pas_non0_entropy.bed` that contains only PAS with nonzero entropy. Useful if one wants to examine all PAS and apply custom filtering.

`./filter_pas.sh [ent_thr]` filters PAS from `all_pas_non0_entropy.bed` by `ent_thr` entropy threshold, deletes PAS that are in genomic A/T runs and looks for canonical polyadenylation signal upstream of each PAS, merges PAS that are within 10bp into PASC. 
Output: 
`pas_entropy_[ent_thr].bed` - bed file with gemonic coordinates of each PAS, polyA read support (4th column) and number of polyadenylation signals in 40bp upstream region (7th column).  
`pasc_entropy_[ent_thr].bed` - bed file with gemonic coordinates of each PASC, polyA read support (4th column) and precence of polyadenylation signals in 40bp upstream region (7th column).
`ent_thr` can be integer or float.        

## Test run
`bams/` folder contains three small indexed bam files. Run `make` in `RNAseq_PAS_finder` directory in the container to get `.bed` file with polyadenylation sites from all `.bam` files in `bams/` folder.



_____
In output bed files candidate polyadenylation sites are filtered: 
  -  by pooled Shannon entropy (entropy >= n) -- pas_entropy_{n}_signalCol_filt.bed
  -  for intersection with genomic A- or T-runs -- pas_entropy_{n}_signalCol_filt.bed
  -  additional file contains PAS overlapping with annotated genes -- pas_entropy_{n}_signalCol_filt_in_genes.bed

The output files also contain information about polyadenylation signal in upstrean 40bp region.

Output file format: the 5th column represents number of reads supporting the PAS, and the 7th column - the number of polyadenylation signals found up to 40 bp upstream of the PAS start. 

## Requirements 
- bedtools
- python packaes: numpy, pysam.

Dedicated presentation:
https://www.researchgate.net/publication/344404962_De_novo_identification_of_polyadenylation_sites_from_RNA-seq_data
