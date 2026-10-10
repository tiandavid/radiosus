#!/bin/bash

IND=$1
REFERENCE=$2
FASTQ_FOLDER=$3
MIO_BAM_FOLDER=$4

echo "$IND"
echo "$REFERENCE"
echo "$FASTQ_FOLDER"
echo "$MIO_BAM_FOLDER"

echo "Aligning fastq files for: $IND"
header=$(zcat $FASTQ_FOLDER/${IND}_R1_trimmed.fq.gz | head -n 1)
echo "Read Group @RG\tID:$IND\tSM:$IND\tLB:$IND"_lib"\tPL:ILLUMINA"


#mapping unmerged PE reads to MIOref
bwa mem $REFERENCE/MIO.FINAL.chrom.fasta -t 32 -R $(echo "@RG\tID:$IND\tSM:$IND\tLB:$IND"_lib"\tPL:ILLUMINA") $FASTQ_FOLDER/${IND}_R1_trimmed.fq.gz $FASTQ_FOLDER/${IND}_R2_trimmed.fq.gz | samtools view -@ 32 -O BAM -o $MIO_BAM_FOLDER/$IND.MIOref.bam
echo "Done mapping unmerged PE reads to MIO reference."
