#!/bin/bash

IND=$1
REFERENCE=$2
MIO_MARK_DUP_FOLDER=$3
MIO_RAW_VARIANTS_FOLDER=$4

echo "$IND"
echo "$REFERENCE"
echo "$MIO_MARK_DUP_FOLDER"
echo "$MIO_RAW_VARIANTS_FOLDER"

#/global/scratch/users/davidtian/download_software/gatk-4.5.0.0/gatk \
#--java-options "-Xmx32G" HaplotypeCaller \
#-R $REFERENCE/DHP.FINAL.chrom.fasta \
#-I $DHP_MARK_DUP_FOLDER/$IND.DHPref.markdup.bam \
#-O $DHP_RAW_VARIANTS_FOLDER/$IND.DHPref.vcf.gz \
#-ERC GVCF
#echo "Done calling variants against DHPref for $IND"

/global/scratch/users/davidtian/download_software/gatk-4.5.0.0/gatk \
--java-options "-Xmx32G" HaplotypeCaller \
-R $REFERENCE/MIO.FINAL.chrom.fasta \
-I $MIO_MARK_DUP_FOLDER/$IND.MIOref.markdup.bam \
-O $MIO_RAW_VARIANTS_FOLDER/$IND.MIOref.vcf.gz \
-ERC GVCF
echo "Done calling variants against DHPref for $IND"
