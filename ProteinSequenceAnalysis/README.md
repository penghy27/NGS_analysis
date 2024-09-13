# module-09-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: November 30th, 2022  

# Transcriptome Annotation Using BLAST and TransDecoder

## Overview

This project involves the annotation of transcriptomes assembled using Trinity by leveraging BLAST and TransDecoder tools. Starting from RNA-seq data, the transcriptomes were assembled through both reference-guided and de novo assembly approaches. Subsequently, we annotated the assembled transcripts by aligning them to known protein databases and predicted coding sequences. The process includes building custom BLAST databases, running BLAST queries, and using TransDecoder to predict proteins from the assembled transcripts.

## Methods

### 1. Data Preparation
We used RNA-seq data stored in the `data/trinity_de_novo/` directory, which contains previously assembled transcriptomes using Trinity.

### 2. BLAST (Basic Local Alignment Search Tool)
BLAST is a powerful tool to find local alignments between sequences and a sequence database. It allows for rapid searching and alignment based on initial "words" of size "W" that score above a threshold "T." We performed the following steps using BLAST:

- **BLAST Databases**: We utilized pre-built databases such as SwissProt and bacteria_NCBI_ref to annotate transcripts. We also explored building custom BLAST databases using `makeblastdb` from nucleotide or protein FASTA files.
- **Running BLAST**: The BLAST suite was employed to perform nucleotide-to-protein sequence alignment using **blastx**, aligning assembled mRNA sequences to protein databases to identify similar sequences. The **bit score** was used as a key metric for evaluating alignment significance.
- **Output Formats**: Different BLAST output formats were used, including the verbose output for detailed analysis and tabular format (using -outfmt 6) for summarizing and analyzing alignments.

### 3. TransDecoder
TransDecoder is a tool designed to identify likely coding sequences from transcriptome assemblies. It processes assembled transcripts by predicting protein-coding regions based on the following criteria:

- **Identifying Long ORFs**: `TransDecoder.LongOrfs` was used to find the longest open reading frames (ORFs) and translate them into amino acid sequences.
- **Protein Alignment with BLAST** `blastp`: We aligned the predicted protein sequences to the SwissProt database using blastp to guide the prediction process.
- **Protein Domain Search with HMMER (hmmscan)**: `hmmscan` identifies protein domains by comparing predicted protein sequences against protein profile HMMs (Hidden Markov Model).
- **Protein Prediction**: The final step involved `TransDecoder.Predict`, which refines protein predictions using BLAST and HMMER results, generating a protein FASTA file (`*.pep`).

### 4. Shell Scripting and Command-Line Tools
The entire pipeline is automated using shell scripts, making it adaptable for bioinformatics pipelines. The scripts automate processes such as extracting sequences, running BLAST queries, and running TransDecoder commands for protein prediction.

## Scripts
- `longOrfs_args.sh`: This script identifies long open reading frames (ORFs) in the input transcriptome file using TransDecoder.
- `blastpep_args`: Run a BLAST protein search (`blastp`) on a set of query sequences against the SwissProt database, guide the prediction process.
- `pfamScan_args.sh`:  Run hmmscan, a tool for searching protein sequences against a database of hidden Markov models (HMMs).
- `predictProteins_args.sh`: Run TransDecoder.Predict, a tool for predicting protein-coding regions in transcripts.
- `alignPredicted_args.sh`: Align the final predicted proteins to the SwissProt BLAST DB.

