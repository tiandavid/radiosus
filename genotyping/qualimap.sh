#!/bin/bash

IND=$1 
DHP_MARK_DUP_FOLDER=$2 
MIO_MARK_DUP_FOLDER=$3
BAMQC_FOLDER=$4

qualimap bamqc -nt 24 --java-mem-size=60G -bam $MIO_MARK_DUP_FOLDER/${IND}.MIOref.markdup.bam -outdir $BAMQC_FOLDER/final_qualimap/${IND}.MIOref.markdup.qualimap_results -oc $BAMQC_FOLDER/final_qualimap/${IND}.MIOref.markdup.qualimap.coverage.txt
echo "Done with qualimap for $IND"
