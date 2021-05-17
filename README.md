# RNAseq_PAS_finder
RNA-seq based polyadenylation sites (PAS) identification using adenine-rich softclips.

In output bed files candidate polyadenylation sites are filtered 
  -  by pooled entropy,
  -  for intersection with annotated repeats,
  -  for overlap with borders of genomic A- or T-runs,
  -  additional file contains PAS overlapping with annotated genes.

The output files contain information about polyadenylation signal in upstrean 40bp region. 
Output file format: bed. Where the 5th column represents number of reads supporting the PAS, and the 7th column - the number of polyadenylation signals found up to 40 bp upstream of the PAS start. 

Input files: bam. The files have to be indexed and put into bams/ repository.

Dedicated presentation:
https://www.researchgate.net/publication/344404962_De_novo_identification_of_polyadenylation_sites_from_RNA-seq_data
