#!/bin/bash
#SBATCH --job-name=GDBimport
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --time=3-00:00
#SBATCH --array=1-24
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=24
#SBATCH --mem=124G
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --account=co_fishes
#SBATCH -p savio2_bigmem

module load java/22.0.1
RAW_VARIANTS_FOLDER=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/MIO_GATK_raw_variants

id=$SLURM_ARRAY_TASK_ID
scaff=$(sed "${id}q;d" MIO.chrom.chrs.list)

if [ $id == 25 ]
then
	scaff=MIO.chrom.scaffs.list
else
	scaff=$(echo $scaff)
fi

/global/scratch/users/davidtian/download_software/gatk-4.5.0.0/gatk \
--java-options "-Xmx4g -Xms4g" \
GenomicsDBImport \
-L ${scaff} \
-V $RAW_VARIANTS_FOLDER/C_radiosus_W368-2.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/C_radiosus_W368-8.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-10.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-11.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-2.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-3.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-4.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-5.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-6.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-7.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-8.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CRAD_18-9.MIOref.vcf.gz \
-V $RAW_VARIANTS_FOLDER/CYPRAD18_1.MIOref.vcf.gz \
--genomicsdb-workspace-path /global/scratch/users/davidtian/radiosus_proj/GATK_genomicDB/database_${scaff} \
--tmp-dir /global/scratch/users/davidtian/radiosus_proj/GATK_genomicDB/tmp
