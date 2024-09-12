# # module-07-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: November 20th, 2022  
Purpose: Using Trinity for both reference-guided and de novo assemblies.  
Outline: This work is executed on Discovery, and we will do both reference-guided and de novo assemblies of 24 RNA reads of sea anemones by using Trinity. The steps mainly include:   
1. Request a computing node (sbatch) On Discovery to run the shell scripts
2. Set up Anaconda environment and load the modules we use 
3. Merge all RNA sequence (mergeAll.sh)  
4. Assemble the merged bam file into a transcriptome (runTrinity.sh) 
5. Check assembly statistics (analyzeTrinity.sh)
6. Run de-novo assembly (trinityDeNovo.sh) 
7. Check de novo assembly statistics (analyzeTrinityDeNovo.sh).  

From the results, N50 of all transcript contigs changed from 570 at reference-guided to 604 at de novo assemblies. For only logest isoform per 'GENE',
contig N50 changed from 513 at reference-guided to 512 at de novo assemblies.  

					  			| reference-guided assemblies | de novo assemblies  |
All transcript contigs			| Contig N50: 570			  |  Contig N50: 604    |
ONLY LONGEST ISOFORM per 'GENE' |  Contig N50: 513			  |  Contig N50: 512    |


## Methods
```
sbatch sbatch_trinity.sh
```

```
#!/usr/bin/bash
#SBATCH --partition=short				# choose from debug, express, or short
#SBATCH --job-name=trinity			
#SBATCH --time=20:00:00					# the code pieces should run in far less than 1 hour
#SBATCH -N 1							# node requested
#SBATCH -n 4							# task per node requested
#SBATCH --mem=10Gb
#SBATCH --exclusive
#SBATCH --output="batch-%x-%j.output"	# where to direct standard output; will be batch-jobname-jobID.output
#SBATCH --mail-type=All
#SBATCH --mail-user=peng.hsi@northeastern.edu  # send you email messages as your job queues, runs, and either errors out or completes.

# Usage: sbatch /scripts/sbatch_trinity.sh
# Assumes input data is in /home/peng.hsi/AiptasiaRNASeq/data/ 

echo "Starting our analysis $(data)"

echo "Loading our BINF6380 Anaconda environment, which includes Trinity."
module load anaconda3/2021.11
source activate BINF-12-2021
echo "Loading samtools."
module load samtools/1.10

echo "Make directory for data files"
mkdir -p data/

# part of a bigger sbatch script (e.g., #sbatch lines above)
echo "Moving trimmed FASTQ data to the working directory"
cp -r /scratch/peng.hsi/module-08-penghy27/data/AiptasiaRNASeq/data/trimmed/ data/trimmed
echo "Moving alignment files to working directory"
cp -r /scratch/peng.hsi/module-08-penghy27/data/AiptasiaRNASeq/data/bam/ data/bam
cp -r /scratch/peng.hsi/module-08-penghy27/data/AiptasiaRNASeq/data/sam/ data/sam

echo "Make directory for log files"
mkdir -p results/logs/

echo "Starting Guided Assembly $(date)"
echo "Merge all BAM alignment files $(date)"
bash scripts/mergeAll.sh 1>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-mergeAll.log 2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-mergeAll.err

echo "Assemble the Guided Transcriptome $(date)"
bash scripts/runTrinity.sh 1>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-runTrinity.log 2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-runTrinity.err

echo "Analyze the Guided Transcriptome $(date)"
bash scripts/analyzeTrinity.sh 1>results/$SLURM_JOB_NAME-$SLURM_JOB_ID-trinity_guided_stats.txt 2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-analyzeTrinity.err

echo "Guided Assembly complete $(date)"


echo "Starting De Novvo Assembly $(date)"
echo "Assemble the De Novo Transcriptome $(date)"
bash scripts/trinityDeNovo.sh 1>results/$SLURM_JOB_NAME-$SLURM_JOB_ID-trinity_de_novo_stats.txt 2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-analyzeTrinityDeNovo.err

echo "Analyze the De Novo Transcriptome $(date)"
bash scripts/analyzeTrinityDeNovo.sh 1>results/$SLURM_JOB_NAME-$SLURM_JOB_ID-trinity_de_novo_stats.txt 2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-analyzeTrinityDeNovo.err

echo "De Novo Assembly complete $(date)"

echo "Moving key files back to /home"
cp -r results/trinity_guided /home/peng.hsi/AiptasiaRNASeq/data/trinity_guided
cp -r results/trinity_de_novo /home/peng.hsi/AiptasiaRNASeq/data/trinity_de_novo
cp results/trinity*stats.txt /home/peng.hsi/AiptasiaRNASeq/data/

echo "Assemlies complete $(date)"
```