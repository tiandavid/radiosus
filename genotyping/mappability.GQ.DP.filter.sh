#!/bin/bash
#SBATCH --job-name=mappability.GQ20.min3reads
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --account=co_fishes
#SBATCH -p savio3

FILT_VCF=/global/scratch/users/davidtian/radiosus_proj/filtered_VCFs
source activate bcftools
bcftools view -T \
/global/scratch/users/davidtian/Paper3_big_one/mapping_mask/MIO.k150.chrom.genmap.pos \
-Oz \
--threads 32 \
$FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.vcf.gz > $FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.vcf.gz

#min GQ20
bcftools filter -i 'FMT/GQ>=20' -S . --threads 32 -O z -o $FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.vcf.gz $FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.vcf.gz

#min3reads
bcftools filter -i 'FMT/DP>=3' -S . --threads 32 -O z -o $FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.vcf.gz $FILT_VCF/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.vcf.gz
