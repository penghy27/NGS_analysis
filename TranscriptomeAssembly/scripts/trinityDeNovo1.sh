#!/usr/bin/env bash
# trinityDeNoVo1.sh
# Usage: bash scripts/trinityDeNovo1.sh

# Get the list of left reads and store as $leftReads
leftReads="$(ls -q data/trimmed/paired/Aip*.R1.fastq)"

# Store echo of $leftReads as $leftReads to get rid of line breaks
leftReads=$(echo $leftReads)

# Replace spaces in the list of reads with comma
leftReads="${leftReads// /,}"
echo $leftReads

# Get the list of right reads and store as $rightReads
rightReads="$(ls -q data/trimmed/paired/Aip*.R2.fastq)"

# Store echo of $rightReads as $rightReads to get rid of line breaks
rightReads=$(echo $rightReads)

# Replace spaces in the list of reads with comma
rightReads="${rightReads// /,}"
echo $rightReads