# module-07-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: November 14th, 2022  
Purpose: Aligning RNA sequences reads of sea anemones (*Aiptasia pallida*).

The following is working on Discovery. Running this alignment in /scratch/username/ with a computing node.

# Short read alignment of RNA-seq with GSNAP

## Overview  
This project contains scripts and instructions for trimming reads, building reference genome indexes, aligning reads to a reference genome, and performing post-alignment processing (such as converting SAM to BAM files and indexing BAM files) using various bioinformatics tools. We use short-read aligners like GSNAP, which are splice-aware and can handle the complexity of RNA-Seq data. 

## Methods  
### 1. Data 
The input data for this assignment is a subset of an RNA-Seq experiment to study immune response and symbiosis in sea anemones (*Aiptasia pallida*). There were four treatment groups and six replicates per treatment group for a total of 24 anemones. (Data provided by the professor)

### 2. Quality Trimming

**Tool Used: [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic)**

Trimmomatic is a Java-based tool for trimming low-quality bases from sequencing reads and removing adapter sequences. It utilizes a sliding window approach to assess the quality of reads and trim sequences where quality scores drop below a specified threshold. Trimmomatic also removes any adapter sequences, which can interfere with alignment and downstream analysis.

- Script: `AipTrim.sh`
- Input: Raw FASTQ files (data/rawreads/)
- Output: Trimmed FASTQ files (data/trimmed/)

### 3. Building GMAP Database

**Tool Used: [GMAP](https://academic.oup.com/bioinformatics/article/21/9/1859/409207) (gmap_build command)**

We build a GMAP database for the reference genome to optimize the RNA-Seq alignment process. The database is indexed to allow faster alignments. This step involves creating an index of the reference genome and generating a database of known introns using the GFF3 file.

- Script: `AipBuild.sh`
- Input: Reference genome in FASTA format and GFF3 file
- Output: Indexed GMAP database

### 4. Alignment with GSNAP

**Tool Used: [GSNAP](http://research-pub.gene.com/gmap/) (gsnap command). A Genomic Short-read Nucleotide Alignment Program**

For RNA-Seq data, we align reads to the reference genome using GSNAP, a splice-aware aligner that considers intronic regions during alignment. GSNAP is chosen due to its high alignment accuracy and free, open-source nature. The alignment output is generated in SAM format.

- Script: `alignReads.sh`
- Input: Trimmed FASTQ files and GMAP database
- Output: Aligned SAM files

### 5. SAM to BAM Conversion and Sorting

**Tool Used: [Samtools](http://www.htslib.org)**

Aligned SAM files are converted to the more compact BAM format and sorted for efficient storage and downstream processing. This step is essential as most bioinformatics tools require sorted BAM files.

- Script: `sortAlign.sh`
- Input: Aligned SAM files
- Output: Sorted BAM files

### 6. Indexing BAM Files

**Tool Used: [Samtools](http://www.htslib.org)**

To facilitate quick access and visualization of BAM files, we index them using Samtools. Indexing is crucial for various downstream applications, including variant calling and data visualization.

- Script: `indexSam.sh`
- Input: Sorted BAM files
- Output: BAM index files

### 7.Multi-File Processing and Automation

To handle multiple samples efficiently, we use shell scripting to automate the processing pipeline. The multi-file shell scripts iterate through all available samples, perform quality trimming, alignment, conversion, and indexing, reducing manual intervention and errors.

- Scripts: `findSampleNames.sh`, `listSamples.sh`, `trimAll.sh`
- Purpose: Automate processing steps across multiple RNA-Seq samples


## Usage

1. **Quality Trimming**: Run `AipTrim.sh` to trim raw FASTQ files.
2. **Build GMAP Database**: Run `AipBuild.sh` to create the GMAP database.
3. **Align Reads**: Execute `alignReads.sh` to align reads to the reference genome using GSNAP.
4. **Sort and Index BAM Files**: Use `sortAlign.sh` and `indexSam.sh` for BAM file processing.
5. **Automate Pipeline**: Run `trimAll.sh` for automated multi-file processing.


## Reference
- Lamolle, G., Musto, H. Why Prokaryotes Genomes Lack Genes with Introns Processed by Spliceosomes?. J Mol Evol 86, 611–612 (2018). https://doi.org/10.1007/s00239-018-9874-4  
- Baruzzo, G., Hayer, K. E., Kim, E. J., Di Camillo, B., FitzGerald, G. A., & Grant, G. R. (2017). Simulation-based comprehensive benchmarking of RNA-seq aligners. Nature Methods, 14(2), 135–139. https://doi.org/10.1038/nmeth.4106  

