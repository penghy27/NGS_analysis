#!/bin/bash
#SBATCH --partition=short               # choose from debug, express, or short
#SBATCH --job-name=assembleGenome
#SBATCH --time=04:00:00                 # the code pieces should run in far less than 4 hours
#SBATCH -N 1                            # nodes requested
#SBATCH -n 1                            # task per node requested
#SBATCH --output="batch-%x-%j.output"   # where to direct standard output; will be batch-jobname-jobID.output

echo "Starting our analysis $(date)"  

ORGANISM="Rhodo"  # in future, we will define this as part of a config file
SRR_ID=SRR522244  # in future, we will define this as part of a config file

echo "$ORGANISM SRR reads to process: $SRR_ID"

echo "Loading our BINF6308 Anaconda environment."
module load anaconda3/2021.11
source activate BINF-12-2021

echo "Downloading $SRR_ID reads $(date)"
bash getNGS.sh

echo "Trimming $SRR_ID reads $(date)"
bash trim.sh

echo "Assembling genome from trimmed $SRR_ID reads $(date)"
bash runSpades.sh

echo "Analyzing genome assembly $(date)"
bash runQuast.sh

echo "Assembly and analysis complete $(date)"