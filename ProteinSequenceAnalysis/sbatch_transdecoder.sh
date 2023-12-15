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
