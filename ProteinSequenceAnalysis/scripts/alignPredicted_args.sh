#!usr/bin/env bash
# alignPredicted_args.sh
# Usage: bash scripts/alignPredicted_args.sh $FINAL_PROTEINS $SWISSPROT_DB \
#  1>results/alignPredicted.txt \
#  2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-alignPredicted_args.err

blastp -query $1 \
    -db $2 \
    -max_target_seqs 5 \
    -outfmt 6 -evalue 1e-10 -num_threads 4 
