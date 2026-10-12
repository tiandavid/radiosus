#!/bin/bash
#SBATCH --job-name=filt_depth
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

FILT_VCF=/global/scratch/users/davidtian/radiosus_proj/filtered_VCFs
source activate bcftools
#min 1/3x mean, max 2x mean

#fill INFO fields first
bcftools +fill-tags \
-O z -o $FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.INFO.vcf.gz \
$FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.vcf.gz \
-- -t AC,AF,AN

bcftools view -e 'sum(FORMAT/DP)<65 || sum(FORMAT/DP)>391' \
--threads 32 \
-O z -o $FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.vcf.gz \
$FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.INFO.vcf.gz
