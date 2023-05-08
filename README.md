# RNAseq_PAS_finder
Polyadenylation sites (PAS) identification from short RNA-seq reads with non-templated adenines (polyA reads).

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

### Input
By default the pipeline identifies PAS from all .bam files stored in `bams/` direcory. The input files have to be indexed.

### Final output
List of polyadenylation clusters (PASC) with number of supporting polyA reads.

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

### Step 2. Pool PAS

```
./pooled_pas_compute_entropy.sh
```
Concatenates all .tsv files from `./sites/` directory, for each candidate PAS computes total polyA read support and total entropy of overhang lengths distribution. 

Output:

`all_pas_with_entropy.bed` - list of all candidate PAS with total polyA read support (5th column) and entropy (7th column). 

`all_pas_non0_entropy.bed` - same as `all_pas_with_entropy.bed`, but limited to PAS with nonzero entropy. Useful if one wants to examine all PAS and apply custom filtering.

### Step 3. Filter PAS by Shannon entropy and cluster.

```
./filter_pas.sh 1
```

`./filter_pas.sh [ent_thr]` filters PAS from `all_pas_non0_entropy.bed` by `ent_thr` entropy threshold, deletes PAS that are in genomic A/T runs and looks for canonical polyadenylation signal upstream of each PAS, merges PAS that are within 10bp into PASC. 

Output: 

`pas_entropy_[ent_thr].bed` - bed file with gemonic coordinates of each PAS, polyA read support (5th column) and number of polyadenylation signals in 40bp upstream region (7th column).  
`pasc_entropy_[ent_thr].bed` - bed file with gemonic coordinates of each PASC, total polyA read support of PAS in the cluster (5th column), and `+/-signal` indication of polyadenylation signals in upstream region (7th column).
`ent_thr` can be integer or float. 

The script requires `./references/AT_10_strict_positions.bed` and `./references/PAsignal_covered_reg.bed` files. 
The former contains coordinates of genomic A/T runs and can be generated from fasta files with genome sequences via `AT10_positions.sh` script. 
`./references/PAsignal_covered_reg.bed` contains genomic locations of polyadenylation signals and regions dowstream of them and can be generated from fasta files with genome sequences via `PAsignal.sh` script.  

## Test run
`bams/` folder contains three small indexed bam files. Run `make` in `RNAseq_PAS_finder` directory in the container to get `.bed` file with polyadenylation clusters from all `.bam` files in `bams/` folder.

## Requirements 
- bedtools >=2.29
- python 3.7
  - numpy 
  - pysam >=0.15.

## Publication
Mariia Vlasenok, Sergey Margasyuk, Dmitri D. Pervouchine. Transcriptome sequencing suggests that pre-mRNA splicing counteracts widespread intronic cleavage and polyadenylation. bioRxiv 2022.05.27.493724; doi: https://doi.org/10.1101/2022.05.27.493724 
