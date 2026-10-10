#!/bin/bash
#SBATCH --job-name=genotypeGVCFs
#SBATCH --output=R-%x.%A_%a.out
#SBATCH --error=R-%x.%A_%a.err
#SBATCH --time=72:00:00
#SBATCH --array=11-24
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --account=co_fishes
#SBATCH -p savio3

module load java/22.0.1
gDBImport_FOLDER=/global/scratch/users/davidtian/radiosus_proj/GATK_genomicDB

id=$SLURM_ARRAY_TASK_ID
scaff=$(sed "${id}q;d" MIO.chrom.chrs.list)

if [ $id == 25 ]
then
	scaff=MIO.chrom.scaffs.list
else
	scaff=$(echo $scaff)
fi
echo "Conducting Joint Genotyping for Chr $id"

/global/scratch/users/davidtian/download_software/gatk-4.5.0.0/gatk \
--java-options "-Xmx16g -Xms16g" \
GenotypeGVCFs \
-R /global/scratch/users/davidtian/Paper3_big_one/reference_asm/MIO.FINAL.chrom.fasta \
-V gendb://$gDBImport_FOLDER/database_${scaff} \
-all-sites -L ${scaff} \
-O /global/scratch/users/davidtian/radiosus_proj/GATK_genotypeGVCFs/${scaff}.allsites.joint.gt.vcf.gz \
--tmp-dir /global/scratch/users/davidtian/radiosus_proj/GATK_genotypeGVCFs/tmp
