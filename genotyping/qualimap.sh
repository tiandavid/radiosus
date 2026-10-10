#!/bin/bash

IND=$1 
MIO_MARK_DUP_FOLDER=$2
BAMQC_FOLDER=$3

qualimap bamqc -nt 24 --java-mem-size=60G -bam $MIO_MARK_DUP_FOLDER/${IND}.MIOref.markdup.bam -outdir $BAMQC_FOLDER/final_qualimap/${IND}.MIOref.markdup.qualimap_results -oc $BAMQC_FOLDER/final_qualimap/${IND}.MIOref.markdup.qualimap.coverage.txt
echo "Done with qualimap for $IND"
