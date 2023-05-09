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
cd RNAseq_PAS_finder
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
`./pooled_pas_compute_entropy.sh [/path_to_dir_with_tsvs]`  concatenates all .tsv files from `./path_to_dir_with_tsvs` directory, for each candidate PAS computes total polyA read support and total entropy of overhang lengths distribution. The script takes path to directory with .tsv files as an argument, default value is `./sites`.

Output:

`all_pas_with_entropy.bed` - list of all candidate PAS with total polyA read support (5th column) and entropy (7th column). 

`all_pas_non0_entropy.bed` - same as `all_pas_with_entropy.bed`, but limited to PAS with nonzero entropy. Useful if one wants to examine all PAS and apply custom filtering.
Both files are created in the current working directory. 

### Step 3. Prepare files for PAS filtering.
To exclude PAS in genomic A/T runs and to locate polyadenylation signals, you will need the assembly of the genome of interest in fasta format. 
For example, we used human GRCh37 (hg19) which can be downaloaded from UCSC servers with `rsync`. 
```
rsync -azP rsync://hgdownload.cse.ucsc.edu/goldenPath/hg19/chromosomes/ /path_to_genome_dir/genome/; 
gunzip /path_to_genome_dir/genome/chr*.fa.gz
```
*NB: the container does not have rsync, so to download assembly from the container you'll need to install it with `apt install rsync`.*  

To generate files with genomic A/T runs and regions dowstream of polyadenylation signals from the genome sequence, use `AT10_positions.sh` and `PAsignal.sh` scripts from `/references` folder. Both scripts accept path to the directory with `chr*.fa` files as argument.
```
./references/AT10_positions.sh /path_to_genome_dir/genome/
./references/PAsignal.sh /path_to_genome_dir/genome/
```
The scripts create `AT_10_strict_positions.bed` and `PAsignal_covered_reg.bed` files in the current working directory. `AT_10_strict_positions.bed` is a bed file with borders of many (>10nt) consequent A(T) nucleotides in the genome. `PAsignal_covered_reg.bed` is a bed file with genomic position of regions dowstream of known polyadenylation signals. 

### Step 4. Filter and cluster PAS.
```
./filter_pas.sh 1
```
`./filter_pas.sh [ent_thr]` filters PAS from `all_pas_non0_entropy.bed` by `ent_thr` entropy threshold, deletes PAS that are in genomic A/T runs (in `./references/AT_10_strict_positions.bed`) and looks for canonical polyadenylation signal upstream of each PAS (via `./references/PAsignal_covered_reg.bed`), then the PAS are clustered into PASCs. All paths are local.

Output: 

`pas_entropy_[ent_thr].bed` - bed file with gemonic coordinates of each PAS, polyA read support (5th column) and number of polyadenylation signals in 40bp upstream region (7th column).  
`pasc_entropy_[ent_thr].bed` - bed file with gemonic coordinates of each PASC, total polyA read support of PAS in the cluster (5th column), and `+/-signal` indication of polyadenylation signals in upstream region (7th column).
`ent_thr` can be integer or float. 

Both output files are created in the current working directory.


## Test run
Run `make` in `RNAseq_PAS_finder` directory in the container to get `.bed` file with PASC from test `.bam` files in `bams/` folder.

`make` creates `pasc_entropy_1.bed` and `pas_entropy_1.bed` files, as well as the output of the intermediate steps: for each bam `bam_name.tsv` in `sites/` directory, `bam_name_pAreads.bam` in `pAread_bams/` , and the pooled `all_pas_with_entropy.bed`. There is `pasc_entropy_1_test.bed` to compare with test run output `pasc_entropy_1.bed`, if the files are identical `make` prints `successful test run for entropy threshold=1`. 

*NB: `AT_10_strict_positions.bed` and `PAsignal_covered_reg.bed` in this GitHub directory cover only chr22. They are only sufficient for the test run. To create reference files for the whole genome refer to [Step3](https://github.com/mashlosenok/RNAseq_PAS_finder/edit/main/README.md#step-3-prepare-files-for-pas-filtering).*

## Requirements 
- bedtools >=2.29
- python 3.7
  - numpy >=1.21
  - pysam >=0.15.

## Publication
Mariia Vlasenok, Sergey Margasyuk, Dmitri D. Pervouchine. Transcriptome sequencing suggests that pre-mRNA splicing counteracts widespread intronic cleavage and polyadenylation. bioRxiv 2022.05.27.493724; doi: https://doi.org/10.1101/2022.05.27.493724 
