#!/bin/bash

IND=$1 
MIO_BAM_FOLDER=$2
MIO_MARK_DUP_FOLDER=$3

echo "$IND"
echo "$MIO_BAM_FOLDER"
echo "$MIO_MARK_DUP_FOLDER"

#MIOref
/global/scratch/users/davidtian/download_software/gatk-4.5.0.0/gatk \
MarkDuplicatesSpark \
-I $MIO_BAM_FOLDER/${IND}.MIOref.bam -O $MIO_MARK_DUP_FOLDER/${IND}.MIOref.markdup.bam -M $MIO_MARK_DUP_FOLDER/${IND}.MIOref.markdup_metrics.txt
echo "Done marking MIOref duplicates for $IND"
