#!/bin/bash
#remove high miss ind
bcftools view -s ^CYPRAD18_1 -O z -o CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.rm.high.ind.miss.vcf.gz CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.vcf.gz
#chr only 
bcftools view --threads 32 -R /global/scratch/users/davidtian/Paper3_big_one/reference_asm/MIO.FINAL.chrom.bed -O z -o CRAD.biallelic.chrs.only.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.rm.high.ind.miss.vcf.gz CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.rm.high.ind.miss.vcf.gz
