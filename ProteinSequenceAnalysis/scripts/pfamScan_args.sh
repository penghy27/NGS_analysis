#!/usr/bin/env bash
# pfamScan_args.sh
# Usage: bash scripts/pfamScan.sh $DOMTBLOUT $PFAMA_PATH $LONGEST_ORFS  1>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-predictProteins_args.log \
#  2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-predictProteins_args.err

hmmscan --cpu 4 --domtblout $1 \
    $2 \
    $3
