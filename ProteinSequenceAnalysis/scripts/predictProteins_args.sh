#!/usr/bin/env bash
# predictedProtein_args.sh
# Usage: bash scripts/predictProteins.sh $TRANSCRIPTOME $TRANSDECODER_DIR $DOMTBLOUT $OUTFMT 1>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-predictProteins_args.log \
# 2>results/logs/$SLURM_JOB_NAME-$SLURM_JOB_ID-predictProteins_args.err

TransDecoder.Predict \
    -t $1 \
    -O $2 \
    --retain_pfam_hits $3 \
    --retain_blastp_hits $4

