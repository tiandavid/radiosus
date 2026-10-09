#!/bin/bash
#SBATCH --job-name=bcftools.roh
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

source activate bcftools #v1.16

VCF=/global/scratch/users/davidtian/radiosus_proj/filtered_VCFs/CRAD.biallelic.chrs.only.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.rm.high.ind.miss.rm.alt.asterisk.vcf.gz
VCF_minAC2=/global/scratch/users/davidtian/radiosus_proj/filtered_VCFs/CRAD.biallelic.chrs.only.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.minAC2.rm.high.ind.miss.rm.alt.asterisk.vcf.gz
OUTPUT=/global/scratch/users/davidtian/radiosus_proj/analyses/bcftools_roh/output

# Generate allele frequency files for use with bcftools roh & index
bcftools query -f'%CHROM\t%POS\t%REF,%ALT\t%INFO/AF\n' \
$VCF \
| bgzip -c > $OUTPUT/CRAD.AF.tab.gz
tabix -s1 -b2 -e2 --csi $OUTPUT/CRAD.AF.tab.gz

bcftools query -f'%CHROM\t%POS\t%REF,%ALT\t%INFO/AF\n' \
$VCF_minAC2 \
| bgzip -c > $OUTPUT/CRAD.no.singletons.AF.tab.gz
tabix -s1 -b2 -e2 --csi $OUTPUT/CRAD.no.singletons.AF.tab.gz

# Call ROHs with GT and PL 
bcftools roh \
--GTs-only 20 \
--threads 32 \
-o $OUTPUT/CRAD_GTonly.txt \
--AF-file $OUTPUT/CRAD.AF.tab.gz \
$VCF

bcftools roh \
--threads 32 \
-o $OUTPUT/CRAD_PLonly.txt \
--AF-file $OUTPUT/CRAD.AF.tab.gz \
$VCF

bcftools roh \
--GTs-only 20 \
--threads 32 \
-o $OUTPUT/CRAD_no_singletons_GTonly.txt \
--AF-file $OUTPUT/CRAD.no.singletons.AF.tab.gz \
$VCF_minAC2

bcftools roh \
--threads 32 \
-o $OUTPUT/CRAD_no_singletons_PLonly.txt \
--AF-file $OUTPUT/CRAD.no.singletons.AF.tab.gz \
$VCF_minAC2
 
# Extract information on ROHs (i.e., exclude information on individual sites)
grep "^RG" $OUTPUT/CRAD_GTonly.txt > \
$OUTPUT/CRAD_GTonly_RG_ONLY.txt

grep "^RG" $OUTPUT/CRAD_PLonly.txt > \
$OUTPUT/CRAD_PLonly_RG_ONLY.txt

grep "^RG" $OUTPUT/CRAD_no_singletons_GTonly.txt > \
$OUTPUT/CRAD_no_singletons_GTonly_RG_ONLY.txt

grep "^RG" $OUTPUT/CRAD_no_singletons_PLonly.txt > \
$OUTPUT/CRAD_no_singletons_PLonly_RG_ONLY.txt
