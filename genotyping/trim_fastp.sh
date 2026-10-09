#!/bin/bash
IND=$1 
RAW_FOLDER=$2 
TRIM_FOLDER=$3 

echo "trimming adapters for: $IND"
#different versions of fastp command depending on fastq file name stucture
/global/scratch/users/davidtian/download_software/fastp \
--in1 $RAW_FOLDER/${IND}_R1*fastq.gz --out1 $TRIM_FOLDER/${IND}_R1_trimmed.fq.gz \
--in2 $RAW_FOLDER/${IND}_R2*fastq.gz --out2 $TRIM_FOLDER/${IND}_R2_trimmed.fq.gz \
--unpaired1 $TRIM_FOLDER/${IND}_unpaired.fq.gz --unpaired2 $TRIM_FOLDER/${IND}_unpaired.fq.gz \
-j $TRIM_FOLDER/${IND}.json -h $TRIM_FOLDER/${IND}.html \
--thread 20

echo "Done with script."
