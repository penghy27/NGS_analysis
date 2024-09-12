# module-06-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: November 7th, 2022  
Purpose: Assemble the Rhodobacter spheroides genome

# Genome Assembly and Quality Analysis Pipeline

## Overview

This project involves retrieving raw sequencing data from the NCBI Sequence Read Archive (SRA), performing quality trimming, assembling a bacterial genome, and analyzing the quality of the assembly. The project follows a typical bioinformatics workflow for genome assembly from raw sequencing data, which includes data retrieval, preprocessing, assembly, and quality assessment.

## Methods

### 1. Data Retrieval

The raw sequencing data is obtained from the [NCBI Sequence Read Archive (SRA)](https://www.ncbi.nlm.nih.gov/sra), a repository for storing raw sequencing data. The SRA allows researchers to access raw sequencing reads, which can then be processed for various downstream analyses.

### 2. Quality Trimming

**Tool Used: [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic)**

- **Description**: Trimmomatic is a Java-based tool for trimming low-quality bases from sequencing reads and removing adapter sequences. It utilizes a sliding window approach to assess the quality of reads and trim sequences where quality scores drop below a specified threshold.
- **Purpose**: Ensures that low-quality sequences and adapter contaminations are removed before genome assembly, which improves the accuracy of the assembly process.
- **Command Line Usage**: A shell script is used to run Trimmomatic for paired-end FASTQ reads to generate quality-trimmed reads for assembly.

### 3. Genome Assembly

**Tool Used: [SPAdes](https://cab.spbu.ru/software/spades/)**

- **Description**: SPAdes (St. Petersburg genome assembler) is a popular assembler for bacterial genomes that reconstructs genomes from short-read sequencing data.
- **Purpose**: Converts quality-trimmed sequencing reads into assembled contigs, which represent the genome of the target organism.
- **Command Line Usage**: The `spades.py` program is run with specific parameters to assemble the genome from quality-trimmed reads, with the output directed to a specified folder (`rhodo`).

### 4. Quality Assessment of Assembly

**Tool Used: [QUAST](http://quast.sourceforge.net/)**

- **Description**: QUAST (Quality Assessment Tool for Genome Assemblies) evaluates the quality of assembled contigs by providing various metrics such as N50, number of contigs, and other assembly statistics.
- **Purpose**: Provides a detailed analysis of the genome assembly quality to assess its completeness and accuracy.
- **Command Line Usage**: The `quast.py` script is run to generate a basic analysis report for the assembled genome, helping to determine its overall quality and statistics like N50.

### 5. Workflow Automation Script

To streamline the entire process of genome assembly and quality analysis, a shell script (`assembleGenome.sh`) is provided that combines all the steps into a single, automated workflow. This script is designed to run on an HPC (High-Performance Computing) cluster using the SLURM job scheduling system.

### Script Description
The script, `assembleGenome.sh`, executes the following steps in sequence:

1. **Job Setup**: The script begins by setting up the SLURM job parameters, such as partition type, job name, time limit, number of nodes, tasks per node, and output file naming convention.
   
2. **Environment Preparation**: Loads the required Anaconda environment (`BINF-12-2021`) to ensure that all necessary bioinformatics tools and dependencies (Trimmomatic, SPAdes, QUAST) are available.

3. **Data Retrieval**: Runs a sub-script (`getNGS.sh`) to download raw sequencing data from the SRA for the specified organism (`Rhodo`) and SRR ID (`SRR522244`).

4. **Quality Trimming**: Executes the `trim.sh` script, which uses Trimmomatic to remove low-quality sequences and adapter contamination from the raw reads.

5. **Genome Assembly**: Invokes the `runSpades.sh` script to assemble the quality-trimmed reads into contigs using the SPAdes assembler.

6. **Quality Assessment**: Runs the `runQuast.sh` script to analyze the quality of the assembled genome using QUAST, generating metrics such as N50 and the number of contigs.

7. **Completion**: Outputs timestamps at each step to provide a clear log of the workflow's progress and completion.



## Usage

1. **Data Retrieval**: Obtain raw sequencing reads from the SRA.
2. **Quality Trimming**: Use the provided shell script to run Trimmomatic for quality trimming of raw reads.
3. **Genome Assembly**: Run the `spades.py` script to assemble the quality-trimmed reads.
4. **Quality Assessment**: Use `quast.py` to analyze the quality of the assembled genome.
5. **Workflow Automation**:

To run the workflow:

- Make sure you have access to a computing cluster with SLURM installed and the necessary modules (Anaconda, bioinformatics tools) available.
- Modify the script as needed to specify the organism and SRR ID. The current script uses `Rhodo` as the organism and `SRR522244` as the SRR ID.
- Submit the job script to the SLURM scheduler with `sbatch assembleGenome.sh`.


## Scripts

- `trim.sh`: Shell script for trimming paired-end FASTQ reads using Trimmomatic.
- `runSpades.sh`: Shell script for assembling the genome using SPAdes.
- `runQuast.sh`: Shell script for quality analysis of the assembled genome using QUAST.
- `assembleGenome.sh`: Shell script combining all the steps, including genome assembly and quality analysis, into automated workflow.

## References

- NCBI Sequence Read Archive (SRA): [SRA Website](https://www.ncbi.nlm.nih.gov/sra)
- Trimmomatic: [Trimmomatic Website](http://www.usadellab.org/cms/?page=trimmomatic)
- SPAdes: [SPAdes Website](https://ablab.github.io/spades/)
- QUAST: [QUAST Website](http://quast.sourceforge.net/)

## Analysis
### Conclusion:
The assembly quality appears to be relatively good based on several key metrics. The N50 value of 25,496 bp suggests a moderate level of contiguity, with half of the assembled genome length contained in contigs of at least this size. Additionally, 54 contigs are longer than 25,000 bp, indicating a reasonable level of assembly contiguity with fewer fragmented pieces. The absence of N's (gaps) in the assembly, as indicated by the 0.00 N's per 100 kbp, is a significant strength, suggesting high accuracy in the sequencing and assembly process. The total assembly length of about 4.5 million bp is close to the expected size for a bacterial genome, and the largest contig is 104,244 bp, suggesting that some large genomic regions are well-represented. Together, these metrics imply that while the assembly is not perfect, it provides a reasonably contiguous and accurate representation of the genome.

 

**key metrics**
| Assembly         |           contigs |
|------------------|-------------------|
|# contigs (>= 0 bp)|         420      |
|# contigs (>= 1000 bp)|      285      |
|# contigs (>= 5000 bp)|      200      |
|# contigs (>= 10000 bp)|     147      |
|# contigs (>= 25000 bp)|     54       |
|# contigs (>= 50000 bp)|     13       |
|Total length (>= 0 bp) |     4555060  |
|Total length (>= 1000 bp)|   4503318  |
|Total length (>= 5000 bp)|   4275282  |
|Total length (>= 10000 bp)|  3881057  |
|Total length (>= 25000 bp)|  2363848  |
|Total length (>= 50000 bp)|  1002058  |
|# contigs |                  323      |
|Largest contig |              104244  |
|Total length   |             4531150  
GC (%)          |            68.80  
N50             |            25496  
N75             |            14630  
L50             |            51  
L75             |            108  
N's per 100 kbp |          0.00
