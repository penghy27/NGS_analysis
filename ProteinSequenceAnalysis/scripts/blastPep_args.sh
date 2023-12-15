#!/usr/bin/env bash
# blastPep_args.sh
# Usage: bash scripts/blastPep.sh $LONGEST_ORFS $SWISSPROT_DB 1>$OUTFMT 2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-blastPep_args.err

# here, you are using many sequences; each will be run and compared to swissprot db
# let's make sure to run with -outfmt 6. *NOTICE we are now using blastp*

blastp -query $1 \
    -db $2 \
    -max_target_seqs 1 \
    -outfmt 6 -evalue 1e-5 -num_threads 4
