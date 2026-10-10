#!/bin/bash

source activate qualimap 

INDS_ALL=()
MIO_MARK_DUP_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/MIO_markdup_bams
BAMQC_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/bam_qc/
#fc_fishes or co_rosalind
for IND in ${INDS_ALL[@]}; do sbatch --job-name=bamqc --output=R-%x.${IND}.%j.out --error=R-%x.${IND}.%j.err --account=ac_fishes --partition savio2 --nodes=1 --ntasks=1 --cpus-per-task=24 --mem=60G --time 03-00:00 --mail-type=END,FAIL --mail-user=davidtian@berkeley.edu --wrap "/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/scripts/qualimap.sh $IND $DHP_MARK_DUP_FOLDER $MIO_MARK_DUP_FOLDER $BAMQC_FOLDER"; done
