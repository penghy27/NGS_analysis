# module-07-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: November 14th, 2022  
Purpose: Aligning RNA sequences reads of sea anemones (*Aiptasia pallida*) to a Reference  

The following is working on Discovery. Running this alignment in /scratch/username/ with a computing node.

## Overview  
In module-06-penghy27, we built a draft genome with DNAseq data. Once we have a genome in hand, it can become a reference to align reads. Here we will use GSNAP - a splice-aware aligner - to align RNAseq reads to reference genomes. When working with Eukaryotic RNAseq data, we have to account for splice junctions (where an intronic sequence in the reference has been removed (through splicing) in the RNA. These prominent gaps are expected (not errors) and must be accounted for by the aligner. We will use the Aiptasia data to demo this.  

## Methods  
### 1. Requesting a interactive session  
We use Discovery high-computing platform to run genome assembly. We will use the following option when testing our scripts and other interactive analysis pieces.  

```srun --partition=short --pty --export=ALL --nodes=1 --ntasks=1 --mem=10Gb --time=02:00:00 /bin/bash```

### 2. Set up Anaconda environment and load the modules we use:  
We will use a custom Anaconda environment in this class. Access these directly by running:  

```
module load anaconda3/2021.11
source activate BINF-12-2021
module load gsnap/2021-12-17
module load samtools/1.10
```  

### 3. input files on Discovery  
Let's copy these to our working area on ```scratch/```; because there are a lot of files, let's put them into a subfolder in ```data/```called ```rawreads/```.  

```
cd /scratch/peng.hsi/module-07-penghy27/data/   
mkdir rawreads/
echo "Stores raw FASTQ reads for analysis. Not git tracked."> rawreads/README.md
cd rawreads/
cp /work/courses/BINF6308/AiptasiaMiSeq/fastq/*.fastq .
```

### 4. Trimming Aiptasia Reads  
We'll use Trimmomatic which is one of the most popular transcriptome assemblers (Trinity).  

```bash scripts/AipTrim.sh 1>results/logs/AipTrim.log 2>results/logs/AipTrim.err &```
```
#!/usr/bin/env bash
# AipTrim.sh
# Usage: bash scripts/AipTrim.sh 1>results/logs/AipTrim.log 2>results/logs/AipTrim.err &

mkdir -p data/trimmed/

# path to the Trimmomatic program folder within our environment that contains the Illumina adapters
# this is only for Discovery - local systems will typically have a path like: /usr/local/programs/Trimmomatic-0.39-2/
PATH_TO_TRIMMOMATIC="/shared/centos7/anaconda3/2021.11/envs/BINF-12-2021/pkgs/trimmomatic-0.39-hdfd78af_2/share/trimmomatic-0.39-2"
function trim {
    trimmomatic PE \
    -threads 1 -phred33 \   # -threads indicates how many server threads to use for this job. -phred33 indicates the quality encoding method used for the reads.   
    data/rawreads/Aip02.R1.fastq \
    data/rawreads/Aip02.R2.fastq  \
    data/trimmed/Aip02.R1.paired.fastq \
    data/trimmed/Aip02.R1.unpaired.fastq \
    data/trimmed/Aip02.R2.paired.fastq \
    data/trimmed/Aip02.R2.unpaired.fastq \
    HEADCROP:0 \
    ILLUMINACLIP:$PATH_TO_TRIMMOMATIC/adapters/TruSeq3-PE.fa:2:30:10 \
    LEADING:20 TRAILING:20 SLIDINGWINDOW:4:30 MINLEN:36
}
trim
```

### 5. Build GMAP Database  
This script is the shell script to build a GMAP database from the Aiptasia genome. GSNAP will use this database to perform the alignment of the RNA-Seq reads. The GMAP database is indexed and optimized to allow much faster alignment than possible if the alignment were directly against the FASTA file.  

```bash scripts/AipBuild.sh 1>results/logs/AipBuild.log 2>results/logs/AipBuild.err &```  
```
#!/usr/bin/env bash
# AipBuild.sh
# Usage: bash scripts/AipBuild.sh 1>results/logs/AipBuild.log 2>results/logs/AipBuild.err &

gmap_build -D data \  # –D indicates the directory in which to build the database.
-d AiptasiaGmapDb \   # –d indicates the name of the database.
/work/courses/BINF6308/AiptasiaMiSeq/\
GCA_001417965.1_Aiptasia_genome_1.1_genomic.fna
```

### 6. Align with GSNAP  
The basic steps for running GSNAP are to:
- Quality trim the reads
- Build an index of the reference genome using the ```gmap_build``` command
- Build a database of the known introns from the GFF3 file using the ```iit_store```command
- Run the alignment using the ```gsnap``` command.  
  
```alignReads.sh``` aligns the sample Aip02 reads against the GMAP database. Monitor it using ```top```. ```gsnap``` writes the sam alignment information directly to STDOUT, so we redirect it to ```Aip02.sam``` with ```1>```.  
Note: Because we do not currently have a reference of acceptor/donor pairs for splice sites, we are running ```gsnap``` with the ```-N 1```flag to encourage it to look for novel splice sites.

```bash scripts/alignReads.sh 1>results/logs/alignReads.log 2>results/logs/alignReads.err &```  

```
#!/usr/bin/env bash
# alignReads.sh
# Usage: bash scripts/alignReads.sh 1>results/logs/alignReads.log 2>results/logs/alignReads.err &

function alignReads {
    gsnap \   # gsnap writes the sam alignment information directly to STDOUT
    -A sam \  # -A tells gsnap to produce the sam alignment format.
    -D data \   # –D indicates the directory in which to build the database.
    -d AiptasiaGmapDb \  # –d' indicates the name of the database.
    -N 1 \    # -N 1 flag to encourage it to look for novel splice sites.
    data/trimmed/Aip02.R1.paired.fastq \
    data/trimmed/Aip02.R2.paired.fastq \
    1>results/Aip02.sam  # redirect the output to Aip02.sam with 1>
}
alignReads
```

### 7.samtools sort  
Most assemblers require SAM files to be sorted and in BAM format - the binary version of SAM. To convert a SAM file to a sorted BAM file, we can use the ```samtools```
utility. ```sortAlign.sh``` convert ```Aip02.sam``` to a sorted BAM version.  
  
```bash scripts/sortAlign.sh 1>results/logs/Aip02.sort.log 2>results/logs/Aip02.sort.err &```
```
#!/usr/bin/env bash
# sortAlign.sh
# Usage: bash scripts/sortAlign.sh 1>results/logs/Aip02.sort.log 2>results/logs/Aip02.sort.err &

samtools sort \  # use samtools utility to sort sam files.
results/Aip02.sam \
-o results/Aip02.sorted.bam \
```

### 8. index sorted.bam files  
In genome assembly, sorted BAM (Binary Alignment/Map) files are often indexed to facilitate efficient access to the data they contain.  

```bash scripts/indexSam.sh 1>results/logs/Aip02.index.log 2>results/logs/Aip02.index.err &```
```
#!/usr/bin/env bash
# indexSam.sh
# Usage: bash scripts/indexSam.sh 1>results/logs/Aip02.index.log 2>results/logs/Aip02.index.err &

samtools index \
results/Aip02.sorted.bam \
````

So far, what has been done is for one-pair reads in the directory. Let's align all files, sort and index the results.  
### 9. Align all samples   
```bash scripts/alignAll.sh 1>results/logs/alignAll.log 2>results/logs/alignAll.err &```
```
#!/usr/bin/env bash
# alignAll.sh
# Usage: bash scripts/alignAll.sh 1>results/logs/alignAll.log 2>results/logs/alignAll.err &

#Initialize variable to contain the directory of un-trimmed fastq files 
fastqPath="data/trimmed/paired/"
#Initialize variable to contain the suffix for the left reads
leftSuffix=".R1.fastq"
rightSuffix=".R2.fastq"
samSuffix=".sam"
alignOutPath="results/sam/"

# Create needed folders
mkdir -p $alignOutPath

# alignAll will loop through all files
function alignAll {
    #Loop through all the left-read fastq files in $fastqPath
    for leftInFile in $fastqPath*$leftSuffix
    do
        #Remove the path from the filename and assign to pathRemoved
        pathRemoved="${leftInFile/$fastqPath/}"
        #Remove the left-read suffix from $pathRemoved and assign to suffixRemoved
        sampleName="${pathRemoved/$leftSuffix/}"
        #Print $sampleName to see what it contains after removing the path
        echo $sampleName
        gsnap \
        -A sam \
        -D data \
        -d AiptasiaGmapDb \
        -N 1 \
        $fastqPath$sampleName$leftSuffix \
        $fastqPath$sampleName$rightSuffix \
        1> $alignOutPath$sampleName$samSuffix
    done  
}
alignAll
```

### 10. Sort all sam files
```bash scripts/sortAll.sh 1>results/logs/sortAll.log 2>results/logs/sortAll.err &```
```
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
```

### 11. Index all sorted.bam files
```bash scripts/indexAll.sh 1>results/logs/indexAll.log 2>results/logs/indexAll.err &```
```
#!/usr/bin/env bash
# indexAll.sh
# Usage: bash scripts/indexAll.sh 1>results/logs/indexAll.log 2>results/logs/indexAll.err &

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
```
  
## Reference
- Lamolle, G., Musto, H. Why Prokaryotes Genomes Lack Genes with Introns Processed by Spliceosomes?. J Mol Evol 86, 611–612 (2018). https://doi.org/10.1007/s00239-018-9874-4  
- Baruzzo, G., Hayer, K. E., Kim, E. J., Di Camillo, B., FitzGerald, G. A., & Grant, G. R. (2017). Simulation-based comprehensive benchmarking of RNA-seq aligners. Nature Methods, 14(2), 135–139. https://doi.org/10.1038/nmeth.4106  

