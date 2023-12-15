#!/usr/bin/env bash
# sortAll.sh
# Usage: bash scripts/sortAll.sh 1>results/logs/sortAll.log 2>results/logs/sortAll.err &

# Initialize variable to contain the directory of sam files 
fastqPath="results/sam/"

# Initialize variable to contain the suffix for sam and bam files
samSuffix=".sam"
bamSuffix=".sorted.bam"
sortOutPath="results/bam/"  
 
# Create needed folders
mkdir -p $sortOutPath

# trimAll will loop through all files and trim them
function sortAll {
    #Loop through all the SAM files in $fastqPath
    for files in $fastqPath*$samSuffix
    do
        #Remove the path from the filename and assign to pathRemoved
        pathRemoved="${files/$fastqPath/}"
        #Remove the sam suffix from $pathRemoved and assign to suffixRemoved
        sampleName="${pathRemoved/$samSuffix/}"
        #Print $sampleName to see what it contains after removing the path
        echo $sampleName
        samtools sort \
        $fastqPath$sampleName$samSuffix \
        -o $sortOutPath$sampleName$bamSuffix 
    done
}
sortAll