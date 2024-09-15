#!/usr/bin/env bash
# indexAll.sh
# Usage: bash scripts/indextAll.sh 1>results/logs/indexAll.log 2>results/logs/indexAll.err &

# Initialize variable to contain the directory of un-trimmed fastq files 
fastqPath="results/bam/"

# Initialize variable to contain the suffix for paired reads
sortedbamSuffix=".sorted.bam"
 
# Create needed folders
# mkdir -p $indexOutPath

# trimAll will loop through all files and trim them
function indexAll {
    #Loop through all the left-read fastq files in $fastqPath
    for files in $fastqPath*$sortedbamSuffix
    do
        #Remove the path from the filename and assign to pathRemoved
        pathRemoved="${files/$fastqPath/}"
        #Remove the left-read suffix from $pathRemoved and assign to suffixRemoved
        sampleName="${pathRemoved/$sortedbamSuffix/}"
        #Print $sampleName to see what it contains after removing the path
        echo $sampleName
        samtools index \
        $fastqPath$sampleName$sortedbamSuffix 
    done
}    
indexAll