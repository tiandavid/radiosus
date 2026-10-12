#!/bin/bash
#SBATCH --job-name=filter.var
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

module load java/22.0.1
gatk=/global/scratch/users/davidtian/download_software/gatk-4.5.0.0/gatk
REF=/global/scratch/users/davidtian/Paper3_big_one/reference_asm/MIO.FINAL.chrom.fasta
RAW=/global/scratch/users/davidtian/radiosus_proj/GATK_genotypeGVCFs
FILT=/global/scratch/users/davidtian/radiosus_proj/filtered_VCFs

$gatk IndexFeatureFile -I CRAD.variant.RAW.vcf.gz

# Now we will select variants, and conduct hard filtering with GATK.
echo "Pulling out SNPs"
$gatk SelectVariants \
-V $RAW/CRAD.variant.RAW.vcf.gz \
-select-type SNP \
--restrict-alleles-to BIALLELIC \
-O $FILT/CRAD.biallelic.RAW.SNPS.vcf.gz >& CRAD.biallelic.RAW.SNPS.out

echo "Pulling out INDELs"
$gatk SelectVariants \
-V $RAW/CRAD.variant.RAW.vcf.gz \
-select-type INDEL \
-O $FILT/CRAD.RAW.INDELs.vcf.gz >& $CRAD.RAW.INDELs.out

echo "Hard filtering SNPs"
# Hard filter the SNPs
$gatk VariantFiltration \
-R $REF \
-V $FILT/CRAD.biallelic.RAW.SNPS.vcf.gz \
-O $FILT/CRAD.biallelic.HARD.FILTERED.SNPS.vcf.gz \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "QUAL < 30.0" --filter-name "QUAL30" \
-filter "SOR > 3.0" --filter-name "SOR3" \
-filter "FS > 60.0" --filter-name "FS60" \
-filter "MQ < 40.0" --filter-name "MQ40" \
-filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
-filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" >& CRAD.biallelic.HARD.FILTERED.SNPS.out

echo "Hard filtering INDELs"
# Hard filter the indels
$gatk VariantFiltration \
-R $REF \
-V $FILT/CRAD.RAW.INDELs.vcf.gz \
-O $FILT/CRAD.HARD.FILTERED.INDELs.vcf.gz \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "QUAL < 30.0" --filter-name "QUAL30" \
-filter "FS > 200.0" --filter-name "FS200" \
-filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" >& CRAD.HARD.FILTERED.INDELs.out

# Excluding hard filtered variants (leaving only passing ones)

echo "Excluding hard filtered SNPs"
$gatk SelectVariants \
--exclude-filtered \
-V $FILT/CRAD.biallelic.HARD.FILTERED.SNPS.vcf.gz \
-O $FILT/CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.vcf.gz >& CRAD.biallelic.HARD.FILTER.EXCLUDED.SNPS.out

echo "Excluding hard filtered INDELs"
$gatk SelectVariants \
--exclude-filtered \
-V $FILT/CRAD.HARD.FILTERED.INDELs.vcf.gz \
-O $FILT/CRAD.HARD.FILTER.EXCLUDED.INDELs.vcf.gz >& CRAD.HARD.FILTER.EXCLUDED.INDELs.out
