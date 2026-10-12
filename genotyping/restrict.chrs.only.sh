#!/bin/bash
#SBATCH --job-name=invariant.chrs.only
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

bcftools index CRAD.invariant.k150mappable.RGQ20.min3reads.vcf.gz

bcftools view --threads 32 -R /global/scratch/users/davidtian/Paper3_big_one/reference_asm/MIO.FINAL.chrom.bed -O z -o CRAD.invariant.chrs.only.k150mappable.RGQ20.min3reads.vcf.gz CRAD.invariant.k150mappable.RGQ20.min3reads.vcf.gz
