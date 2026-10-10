#!/bin/bash

INDS_ALL=()
REFERENCE=/global/scratch/users/davidtian/Paper3_big_one/reference_asm
MIO_MARK_DUP_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/MIO_markdup_bams
MIO_RAW_VARIANTS_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/MIO_GATK_raw_variants

#fc_fishes or co_rosalind
for IND in ${INDS_ALL[@]}; do sbatch --job-name=GATKhapcal --output=R-%x.${IND}.%j.out --error=R-%x.${IND}.%j.err --account=fc_fishes --partition savio2_htc --nodes=1 --ntasks=1 --cpus-per-task=4 --time 3-00:00 --mail-type=END,FAIL --mail-user=davidtian@berkeley.edu  --wrap "/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/scripts/GATK_haplotype_caller.sh $IND $REFERENCE $MIO_MARK_DUP_FOLDER $MIO_RAW_VARIANTS_FOLDER"; done
