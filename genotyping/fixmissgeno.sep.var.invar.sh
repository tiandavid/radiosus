#!/bin/bash
#SBATCH --job-name=sep.var.invar
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --time=5-00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --account=co_fishes
#SBATCH -p savio3

#bcftools has vcftools in env
source activate bcftools 

# fix missing genotypes for both 
bcftools +setGT --threads 32 CRAD.DHPref.allsites.joint.gt.RAW.vcf.gz -- -t q -n "./." -e 'FMT/DP>=1' > CRAD.fixmissgeno.RAW.vcf
bgzip CRAD.fixmissgeno.RAW.vcf

# create a VCF containing only invariant sites
vcftools --gzvcf CRAD.fixmissgeno.RAW.vcf.gz \
--max-maf 0 \
--recode --stdout | bgzip -c > CRAD.invariant.RAW.vcf.gz

# create a filtered VCF containing only variant sites
vcftools --gzvcf CRAD.fixmissgeno.RAW.vcf.gz \
--mac 1 \
--recode --stdout | bgzip -c > CRAD.variant.RAW.vcf.gz

# index both vcfs
bcftools index CRAD.invariant.RAW.vcf.gz
bcftools index CRAD.variant.RAW.vcf.gz
