#!/bin/bash

INDS_ALL=()
#RAW_FOLDER=/clusterfs/fishes/david/genomes/M004347
RAW_FOLDER=/clusterfs/fishes/david/genomes/death_valley_genomes
#RAW_FOLDER=/clusterfs/fishes/david/scratch/Paper1_DHP/C_diabolis/CDia_raw_fastq
#RAW_FOLDER=/clusterfs/fishes/david/genomes/M004352
TRIM_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/fastp_trimmed_fastqs

for IND in ${INDS_ALL[@]}; do sbatch --account=co_rosalind --job-name=trim -p savio2 -t 8:00:00 --nodes=1 --output=R-%x.${IND}.%j.out --error=R-%x.${IND}.%j.err --ntasks=1 --cpus-per-task=20 --wrap "/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/scripts/trim.fastp.sh $IND $RAW_FOLDER $TRIM_FOLDER"; done
