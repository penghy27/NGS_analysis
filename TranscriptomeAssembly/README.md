# module-08-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: November 20th, 2022  
Purpose: Using Trinity for both reference-guided and de novo assemblies.

# Reference-Guided and De Novo Assembly of RNA-Seq with Trinity

## Overview

This repository contains scripts and instructions for performing both reference-guided and de novo transcriptome assembly using Trinity. The data used in this project comes from RNA sequencing of the sea anemone *Aiptasia pallida*. The methods include trimming reads, merging BAM files, performing reference-guided and de novo assembly of reads, and assembly quality assessment. Key tools used in this project include **Trinity**, **Samtools**, and **TrinityStats.pl**.

## Methods

### 1. Read Trimming and Quality Control
- **Trimming Reads**: Reads are pre-processed to remove low-quality bases and adapter sequences using appropriate tools.

### 2. Merging BAM Files
**Tool Used**: `samtools`
- **Description**: For reference-guided assembly, a single sorted BAM file is required. We merge multiple BAM files using `samtools merge` to create a combined BAM file (`mergeAll.bam`). The merging process excludes files that could not be matched by barcode to the original RNA samples.
- **Input**: sorted bam files redirected to `bamIn.txt`
- **Output**: `AipAll.bam`

### 3. Reference-Guided Transcriptome Assembly
**Tool Used**: `Trinity`
- **Description**: Using the merged BAM file (`AipAll.bam`), a reference-guided assembly is performed with Trinity. Key parameters include specifying the maximum intron size and setting a memory limit. The output, `Trinity-GG.fasta`, represents the assembled transcriptome. Users can monitor the assembly progress using job scheduling commands (`squeue`) and examine the output logs (`trinity.log` and `trinity.err`).
- **Input**: `AipAll.bam`
- **Output**: `Trinity-GG.fasta`

### 4. De Novo Transcriptome Assembly
- **Tool Used**: `Trinity`
- **Description**: For de novo assembly, Trinity is run using two lists of left and right reads generated from raw data. The output, stored in `results/trinity_de_novo`, is assembled without a reference genome.

### 5. Post-Assembly Processing and Analysis
**Tool Used**: `TrinityStats.pl`
- **Description**: After assembling the transcriptome, we analyze the quality and statistics of the assemblies using `TrinityStats.pl`. This script provides N50 and other metrics to evaluate the assembly quality.
- **Results**: `trinity-32683828-trinity_guided_stats.txt` for the reference-guided assembly. `trinity-32683828-trinity_de_novo_stats.txt` for the de novo assembly.

## Scripts

1. **mergeAll.sh**: Merges individual BAM files into a single BAM file for reference-guided assembly.
2. **runTrinity.sh**: Runs the reference-guided transcriptome assembly with Trinity.
3. **trinityDeNovo.sh**: Performs de novo assembly using Trinity.
4. **analyzeTrinity.sh**: Analyzes assembly statistics for the reference-guided assembly.
5. **analyzeTrinityDeNovo.sh**: Analyzes assembly statistics for the de novo assembly.

## Notes

- Troubleshooting Trinity Runs: If errors occur during Trinity runs, delete the output directories before re-running the scripts to avoid using cached data that may cause the same error.
- N50 Metric: N50 is a commonly used metric to evaluate assembly quality. It represents the length at which 50% of the total assembled bases are contained in contigs of at least that length.
