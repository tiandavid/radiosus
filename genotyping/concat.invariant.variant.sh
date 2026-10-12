#!/bin/bash
#SBATCH --job-name=concat.invariant.variant
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

#index both vcfs using tabix
tabix CRAD.biallelic.chrs.only.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.rm.high.ind.miss.rm.alt.asterisk.vcf.gz
tabix CRAD.invariant.chrs.only.k150mappable.RGQ20.min3reads.rm.high.ind.miss.vcf.gz

#combine the two VCFs using bcftools concat
bcftools concat \
--threads 32 \
--allow-overlaps \
CRAD.biallelic.chrs.only.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.rm.high.ind.miss.rm.alt.asterisk.vcf.gz \
CRAD.invariant.chrs.only.k150mappable.RGQ20.min3reads.rm.high.ind.miss.vcf.gz \
-O z -o CRAD.filtered.allsites.vcf.gz
