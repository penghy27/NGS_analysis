# module-06-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: November 7th, 2022  
Purpose: Assemble the Rhodobacter spheroides genome

## Methods  
### 1. Requesting a interactive job via slurm  
We use Discovery high-computing platform to run genome assembly. We will use the following option when testing our scripts and other interactive analysis pieces.
```
srun \
  --partition=short \  # choose from debug, express, and short  
  --pty \  # direct input and output back to your user shell (terminal)  
  --export=ALL \  # export the entire environment at the end of a job  
  --nodes=1 \  # nodes to reserve  
  --ntasks=1 \  # tasks per node to reserve  
  --mem=10Gb \  # memory to reserve  
  --time=00:20:00 \  # time limit in hh:mm:ss MUST be at or below timelimit of the partition  
  /bin/bash # we will use a bash command  
 
exit  # when ready to release the resource 
```

### 2. Set up Anaconda environment  
In this class, BINF6308, we will use a custom Anaconda environment (including Python and some of its libraries like BioPython). Access these directly by running:
```
module load anaconda3/2021.11  
source activate BINF-12-2021  
```

### 3. Obtaining NGS Data  
Publication of a genome paper generally requires making the raw sequencing data publicly available, and the NCBI Sequence Read Archive (https://www.ncbi.nlm.nih.gov/sra), or SRA, is the repository most often used for this purpose. We'll use the SRA to retrieve sequence data, then use one of the bacterial genomeassemblers to assemble the reads into a genome. The command-line utility to retrieve sequence data in FASTQ format from the SRA is ```fasterq-dump```.  

```bash getNGS.sh```  
```
#!/usr/bin/env bash  
# getNGS.sh 

# Retrieve the Rhodobacter spheroides NGS reads.
fasterq-dump --split-3 SRR522244  # --split-3: writes single reads in special file
```

### 4. Quality Trimming with Trimmomatic    
The purpose of trimming in genome assembly is to remove low-quality of DNA reads. In addition, it also removes any adapter sequences from the reads. Sometimes during library preparation, extra copies of adapters get attached to thebeginning or end of the cDNA fragments. These adapter sequences may be left over after the DNA fragments are amplified, and they can interfere with genome assembly if they are not removed.  We will use Trimmomatic as a trimmer in this class.  
  
```bash trim.sh```  
```
#!/usr/bin/env bash  
# trim.sh  
PATH_TO_TRIMMOMATIC="/shared/centos7/anaconda3/2021.11/envs/BINF-12-2021/pkgs/trimmomatic-0.39-hdfd78af_2/share/trimmomatic-0.39-2"  
function trim {  
    trimmomatic PE \  # PE indiates we have paired-end reads    
    -threads 1 -phred33 \  # -threads indicates how many server threads to use for this job. -phred33 indicates the quality encoding method used for the reads.   
    ../data/SRR522244_1.fastq \  
    ../data/SRR522244_2.fastq \  
    ../data/trimmed/paired/Rhodo.R1.paired.fastq \  
    ../data/trimmed/unpaired/Rhodo.R1.unpaired.fastq \  
    ../data/trimmed/paired/Rhodo.R2.paired.fastq \  
    ../data/trimmed/unpaired/Rhodo.R2.unpaired.fastq \  
    HEADCROP:0 \  
    ILLUMINACLIP:$PATH_TO_TRIMMOMATIC/adapters/TruSeq3-PE.fa:2:30:10 \  
    LEADING:20 TRAILING:20 SLIDINGWINDOW:4:30 MINLEN:36  
}  
trim  
```

### 5. Genome assembly  
We'll use the SPAdes assembler, so run ```spades.py``` without any parameters to see the SPAdes help menu. Based on the output of ```spades.py```(help), write a shell script to assemble the Rhodobacter genome using just the quality-trimmedreads in ```data/trimmed/paired```. Specify rhodo as the output directory.  
  
```bash runSpades.sh```  
```
#!/usr/bin/enn bash
# runSpades.sh

mkdir -p "../results/rhodo/"

 function Spades {  
     spades.py \  
     -1 ../data/trimmed/paired/Rhodo.R1.paired.fastq \  # -1: file with forward paired-end reads  
     -2 ../data/trimmed/paired/Rhodo.R2.paired.fastq \  # -2: file with reverse paired-end reads  
     -o ../results/rhodo  # -o: directory to store all the resulting files  
}

Spades # runs the fuction Spades
```

### 6. Checking the quality of your assembly with QUAST  
After the assembly finishes, use ```quast.py``` to run a basic analysis report for your genome and determine the N50 for your assembly.  
  
```bash runQuast.sh```  
```
#!/urs/bin/env bash  
# runQuast.sh  

 function Quast {  
     quast.py ../results/rhodo/contigs.fasta  
 }  
  
Quast  
```

## Analysis
### Conclusion:
The assembly was a bit good for two reasons. First, the analysis shows N50 is 25496 bp while the total length is about 4.5 million bp. The length of N50 is long so we assume it will contain more complete information. In addition, the number of contigs which is longer than 25000 bp was 54. It means the these contigs are not short pieces which might not interfere with more gaps.
 

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
