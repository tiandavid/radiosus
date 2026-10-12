#!/bin/bash
#SBATCH --job-name=vcftools_stats
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH -p savio3
#SBATCH --account=co_fishes

source activate bcftools

VCF=/global/scratch/users/davidtian/radiosus_proj/filtered_VCFs/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.vcf.gz
OUT=CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads

#calculate AF
vcftools --gzvcf $VCF --freq2 --out $OUT

#calculate mean depth per indivdiual
vcftools --gzvcf $VCF --depth --out $OUT

#calculate mean depth per site
vcftools --gzvcf $VCF --site-mean-depth --out $OUT

#calculate site quality
vcftools --gzvcf $VCF --site-quality --out $OUT

#calcualte proportion of missing data per individual
vcftools --gzvcf $VCF --missing-indv --out $OUT

#calculate proportion of missing data per site
vcftools --gzvcf $VCF --missing-site --out $OUT

#calculate heterozygosity and inbreeding coefficient per individual
vcftools --gzvcf $VCF --het --out $OUT

#calculate depth per site summed across individuals
vcftools --gzvcf $VCF --site-depth --out $OUT
