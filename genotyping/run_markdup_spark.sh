#!/bin/bash

INDS_ALL=()
DHP_BAM_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/DHP_bams
DHP_MARK_DUP_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/DHP_markdup_bams
MIO_BAM_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/MIO_bams
MIO_MARK_DUP_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/MIO_markdup_bams

#fc_fishes or co_rosalind
for IND in ${INDS_ALL[@]}; do sbatch --job-name=mdup_spark --output=R-%x.${IND}.%j.out --error=R-%x.${IND}.%j.err --account=ac_fishes --partition savio3 --nodes=1 --ntasks=1 --cpus-per-task=32 --time 03-00:00 --mem=80G --mail-type=END,FAIL --mail-user=davidtian@berkeley.edu  --wrap "/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/scripts/markdup_spark.sh $IND $DHP_BAM_FOLDER $DHP_MARK_DUP_FOLDER $MIO_BAM_FOLDER $MIO_MARK_DUP_FOLDER"; done
