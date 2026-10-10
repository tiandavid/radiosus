#!/bin/bash

source activate bwa
INDS_ALL=()
REFERENCE=/global/scratch/users/davidtian/Paper3_big_one/reference_asm
FASTQ_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/fastp_trimmed_fastqs
DHP_BAM_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/DHP_bams
MIO_BAM_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/MIO_bams

for IND in ${INDS_ALL[@]}; do sbatch --job-name=bwa_mem --output=R-%x.${IND}.%j.out --error=R-%x.${IND}.%j.err --account=ac_fishes --partition savio3 --nodes=1 --ntasks=1 --cpus-per-task=32 --time 03-00:00 --mem=90G --mail-type=FAIL --mail-user=davidtian@berkeley.edu  --wrap "/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/scripts/bwa_mem.sh $IND $REFERENCE $FASTQ_FOLDER $DHP_BAM_FOLDER $MIO_BAM_FOLDER"; done
