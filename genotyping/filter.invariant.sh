#!/bin/bash
#SBATCH --job-name=filter.invar
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --account=co_fishes
#SBATCH -p savio3

RAW_VCFS=/global/scratch/users/davidtian/radiosus_proj/GATK_genotypeGVCFs
FILTERED_VCFS=/global/scratch/users/davidtian/radiosus_proj/filtered_VCFs
source activate bcftools

#apply mappability
bcftools view -T \
/global/scratch/users/davidtian/Paper3_big_one/mapping_mask/MIO.k150.chrom.genmap.pos \
-Oz \
--threads 32 \
$RAW_VCFS/CRAD.invariant.RAW.vcf.gz > $FILTERED_VCFS/CRAD.invariant.k150mappable.vcf.gz

#RGQ20 filter
bcftools filter -i 'FMT/RGQ>=20' -S . --threads 32 -Oz -o $FILTERED_VCFS/CRAD.invariant.k150mappable.RGQ20.vcf.gz $FILTERED_VCFS/CRAD.invariant.k150mappable.vcf.gz

#min3reads filter
bcftools filter -i 'FMT/DP>=3' -S . --threads 32 -O z -o $FILTERED_VCFS/CRAD.invariant.k150mappable.RGQ20.min3reads.vcf.gz $FILTERED_VCFS/CRAD.invariant.k150mappable.RGQ20.vcf.gz
