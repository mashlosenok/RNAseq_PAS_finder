
FROM continuumio/miniconda3:4.8.2

WORKDIR /home/

RUN conda install numpy conda=4.8.2
RUN conda config --add channels bioconda
RUN conda install pysam=0.15.3
RUN conda install bedtools=2.30.0
RUN apt-get -y install make 
