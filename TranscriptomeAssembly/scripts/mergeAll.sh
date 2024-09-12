#!/usr/bin/env bash
# mergeAll.sh
# Usage: bash scripts/mergeAll.sh 1>results/logs/mergeAll.log 2>results/logs/mergeAll.err

# List the files with ls and redirect (>) the output to bamIn.txt
ls data/bam/Aip*.sorted.bam > data/bam/bamIn.txt

# Merge the files using bamIn.txt with the -b option
samtools merge -b data/bam/bamIn.txt -f data/bam/AipAll.bam

