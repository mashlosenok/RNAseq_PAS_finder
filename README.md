# RNAseq_PAS_finder
RNA-seq based polyadenylation sites (PAS) identification using adenine-rich softclips.

In output bed files candidate polyadenylation sites are filtered: 
  -  by pooled Shannon entropy (entropy >= n) -- pas_entropy_{n}_signalCol_filt.bed
  -  for intersection with annotated repeat regions and overlap with borders of genomic A- or T-runs -- pas_entropy_{n}_signalCol_filt.bed
  -  additional file contains PAS overlapping with annotated genes -- pas_entropy_{n}_signalCol_filt_in_genes.bed

The output files also contain information about polyadenylation signal in upstrean 40bp region. 
Output file format: bed. Where the 5th column represents number of reads supporting the PAS, and the 7th column - the number of polyadenylation signals found up to 40 bp upstream of the PAS start. 
Annotation: GENCODE v34lift37.

Input files: bam. The files have to be indexed and stored in bams/ repository.

Dedicated presentation:
https://www.researchgate.net/publication/344404962_De_novo_identification_of_polyadenylation_sites_from_RNA-seq_data
