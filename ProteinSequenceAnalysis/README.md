## module-09-penghy27  
Author: penghy27 (Hsiao-Yu Peng)  
Date: November 30th, 2022  
Purpose: Running Transdecoder,  a program to make protein predictions, which identifies candidate coding regions within transcriptome. Then we can use `blastp` to align our predicted proteins to the BLAST protein database(s).   
Outline: This work is executed on Discovery. TransDecoder protein prediction is a four-step process. The steps mainly include:  
1. `TransDecoder.LongOrfs` finds the longest open reading frames and translates them to amino acid (protein) sequences.
2. `blastp` aligns the long ORFs to SwissProt to identify similar proteins that could guide the prediction process.
3. `hmmscan` uses a Hidden Markov Model (HMM) to find protein domains to guide the prediction process.
4. `TransDecoder.Predict` takes in the open reading frames, the BLAST output, and the domain information to refine the protein predictions and produce a protein fasta file (*.pep).
  
TransDecoder recognizes likely coding sequences based on the following criteria:

- A minimum length open reading frame (ORF) in a transcript sequence.  
- A log-likelihood score similar to what is computed by the GeneID Links to an external site.software is greater than 0.  
- The above coding score is greatest when the ORF is scored in the first reading frame as compared to scores in the other 2 forward reading frames.  
- If a candidate ORF is found fully encapsulated by the coordinates of another candidate ORF, the longer one is reported. However, a single transcript can report multiple ORFs (allowing for operons, chimeras, etc.).  
- A Position-Specific Scoring Matrix (PSSM) is computed, trained, and used to refine the start codon prediction.  
  
  
## Methods
### 1. loading our Anaconda environment
```
module load anaconda3/2021.11
source activate BINF-12-2021
```
### 2. extract the long open reading frames on transcriptome
```
#!/usr/bin/env bash
# longOrfs.sh
# Usage: bash scripts/longOrfs.sh 1>results/logs/longOrfs.log 2>results/logs/longOrfs.err

TransDecoder.LongOrfs \
-t data/trinity_de_novo/Trinity.fasta \       # -t: input data
-O results/trinity_de_novo.transdecoder_dir   # -O: output to file
```

### 3. identify predicted protein sequences against SwissProt.

```
#!/usr/bin/env bash
# blastPep.sh
# Usage: bash scripts/blastPep.sh 1>results/blastPep.outfmt6 2>results/logs/blastPep.err

# here, you are using many sequences; each will be run and compared to swissprot db
# let's make sure to run with -outfmt 6.  *NOTICE we are now using blastp*
blastp -query results/trinity_de_novo.transdecoder_dir/longest_orfs.pep  \
    -db /work/courses/BINF6308/inputFiles/blastDB/swissprot \  # -db: database, here is swillprot.
    -max_target_seqs 1 \         # max_target_seqs: maximum number of aligned sequences to keep
    -outfmt 6 -evalue 1e-5 -num_threads 4 # outfmt: formatting option   , #evalue: expected value threshold for saving hits, # num_threads: number of threads (CPU) to use in the BLAST search
```

### 4. Run hmmscan to find protein domains
The idea is to take the protein sequences found in the ORFs (open reading frames) and search for those against the profile-HMM database.  
```  
#!/usr/bin/env bash
# pfamScan.sh
# Usage: bash scripts/pfamScan.sh 1>results/logs/pfamScan.log 2>results/logs/pfamScan.err

hmmscan --cpu 4 --domtblout results/pfam.domtblout \  # domtblout: save parseable table of per-domain hits to file
    /work/courses/BINF6308/inputFiles/SampleDataFiles/Pfam-A.hmm \
    results/trinity_de_novo.transdecoder_dir/longest_orfs.pep
```

### 5. Predict Protein
The `TransDecoder.Predict` program predicts the likely coding regions from the ORFs identified by `Transdecoder.LongOrfs`.  
```
#!/usr/bin/env bash
# predictProteins.sh
# Usage: bash scripts/predictProteins.sh 1>results/logs/predictProteins.log 2>results/logs/predictProteins.err

TransDecoder.Predict \
    -t data/trinity_de_novo/Trinity.fasta \
    -O results/trinity_de_novo.transdecoder_dir \
    --retain_pfam_hits results/pfam.domtblout \
    --retain_blastp_hits results/blastPep.outfmt6
```
  
From the scripts above, we can write a sbatch script ```sbatch_transdecoder.sh```  to contain all steps that running TransDecoder. Here we create the final `alignPredicted_args.sh` script to align the output of `predictProteins_args.sh` to the SwissProt BLAST DB.   

### Run sbatch_transdecoder.sh  
```sbatch sbatch_transdecoder.sh```  
  
```
#!/usr/bin/bash
#SBATCH --partition=short               # choose from debug, express, or short
#SBATCH --job-name=transdecoder
#SBATCH --time=20:00:00                 
#SBATCH -N 1                            # nodes requested
#SBATCH -n 4                            # task per node requested
#SBATCH --mem=10Gb
#SBATCH --exclusive
#SBATCH --output="batch-%x-%j.output"   # where to direct standard output; will be batch-jobname-jobID.output
#SBATCH --mail-type=ALL
#SBATCH --mail-user=peng.hsi@northeastern.edu # Update to your user name!

# Usage: sbatch sbatch_transdecoder.sh
# Assumes input data is in /home/peng.hsi/AiptasiaRNASeq/data/ 

echo "Starting our analysis $(date)" 
echo 

# define key constants
TRANSCRIPTOME=data/trinity_de_novo/Trinity.fasta
SWISSPROT_DB=/work/courses/BINF6308/inputFiles/blastDB/swissprot 
TRANSDECODER_DIR=results/trinity_de_novo.transdecoder_dir
LONGEST_ORFS=$TRANSDECODER_DIR/longest_orfs.pep
OUTFMT=results/blastPep_args.outfmt6
DOMTBLOUT=results/pfam.domtblout
PFAMA_PATH=/work/courses/BINF6308/inputFiles/SampleDataFiles/Pfam-A.hmm
PREDICTED_PROTEIN_PATH=results/predictedProteins
FINAL_PROTEINS=$PREDICTED_PROTEIN_PATH/*transdecoder.pep
USER=peng.hsi

# record these key constants to our batch*.output file by echoing them:
echo "Key parameters"
echo "TRANSCRIPTOME: $TRANSCRIPTOME"
echo "SWISSPROT_DB: $SWISSPROT_DB"
echo "TRANSDECODER_DIR: $TRANSDECODER_DIR"
echo "LONGEST_ORFS: $LONGEST_ORFS"
echo "OUTFMT: $OUTFMT"
echo "DOMTBLOUT: $DOMTBLOUT"
echo "PFAMA_PATH: $PFAMA_PATH"
echo "PREDICTED_PROTEIN_PATH: $PREDICTED_PROTEIN_PATH"
echo "FINAL_PROTEINS: $FINAL_PROTEINS"
echo
echo


echo "Loading our BINF6308 Anaconda environment."
module load anaconda3/2021.11
source activate BINF-12-2021

echo "Make directory for data files"
mkdir -p data/

# part of a bigger sbatch script (e.g., #sbatch lines above)
echo "Moving de novo Trinity transcriptome data to the working directory"
cp -r /home/$USER/AiptasiaRNASeq/data/trinity_de_novo data/trinity_de_novo

echo "Make directory for log files"
mkdir -p results/logs/

echo "Starting ORF prediction pipeline $(date)"
echo "Identify longORFs with TransDecoder.LongOrfs on $TRANSCRIPTOME $(date)"
bash scripts/longOrfs_args.sh $TRANSCRIPTOME $TRANSDECODER_DIR \
  1>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-longOrfs_args.log \
  2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-longOrfs_args.err

echo "BLASTp of longest_orfs.pep against SwissProt BLAST DB at $SWISSPROT_DB $(date)"
bash scripts/blastPep_args.sh $LONGEST_ORFS $SWISSPROT_DB \
  1>$OUTFMT \
  2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-blastPep_args.err

echo "Create pfamScan with hmmscan using the Pfam-A.hmm file found $PFAMA_PATH $(date)"
bash scripts/pfamScan_args.sh $DOMTBLOUT $PFAMA_PATH $LONGEST_ORFS \
  1>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-pfamScan_args.log \
  2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-pfamScan_args.err

echo "Predict protiens with TransDecoder.Predict $(date)"
bash scripts/predictProteins_args.sh $TRANSCRIPTOME $TRANSDECODER_DIR $DOMTBLOUT $OUTFMT \
  1>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-predictProteins_args.log \
  2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-predictProteins_args.err
echo "Copy TransDecoder.Predict outputs to $PREDICTED_PROTEIN_PATH"
mkdir -p $PREDICTED_PROTEIN_PATH
mv *transdecoder* $PREDICTED_PROTEIN_PATH

echo "Align predicted proteins to SwissProt DB $(date)"
bash scripts/alignPredicted_args.sh $FINAL_PROTEINS $SWISSPROT_DB \
  1>results/alignPredicted.txt \
  2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-alignPredicted_args.err

echo "ORF prediction pipeline complete $(date)"

echo "Moving key files back to /home"
cp -r results/ /home/$USER/AiptasiaRNASeq/data/proteinPrediction/

echo "Analysis complete $(date)"
```
