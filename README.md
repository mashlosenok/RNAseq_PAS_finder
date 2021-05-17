# RNAseq_PAS_finder
RNA-seq based polyadenylation sites identification using adenine-rich softclips.

In output bed files Candidate polyadenylation sites are filtered 
  -  by pooled entropy,
  -  for intersection with annotated repeats,
  -  for overlap with borders of genomic A- or T-runs,
  -  additional file contains PAS overlapping with annotated genes.

The output files contain information about polyadenylation signal in upstrean 40bp region. 
Output file format: bed. Where the 5th column represents number of reads supporting the PAS, and the 7th column - the number of polyadenylation signals found up to 40 bp upstream of the PAS start. 

Input files: bam. The files have to be indexed and put into bams/ repository.
