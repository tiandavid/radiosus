#!/bin/bash
#SBATCH --job-name=smc_vcf2smc
#SBATCH --account=co_fishes
#SBATCH --partition=savio3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=10-00:00
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --mail-type=END,FAIL

#i = CRAD individual
#c = chromosome

VCF=/global/scratch/users/davidtian/radiosus_proj/filtered_VCFs/CRAD.biallelic.chrs.only.HARD.FILTER.EXCLUDED.SNPS.k150mappable.GQ20.min3reads.mindepth.maxdepth.maxmiss50.rm.high.ind.miss.rm.alt.asterisk.vcf.gz
for i in {2..11}
do
    for c in {1..24}
    do
        singularity exec smcpp_latest.sif smc++ vcf2smc --cores 32 -d CRAD_18-$i CRAD_18-$i $VCF CRAD_vcf2smc_files/CRAD.d.CRAD_18-$i.Chr$c.smc.txt Chr$c CRAD:CRAD_18-10,CRAD_18-11,CRAD_18-2,CRAD_18-3,CRAD_18-4,CRAD_18-5,CRAD_18-6,CRAD_18-7,CRAD_18-8,CRAD_18-9,C_radiosus_W368-2,C_radiosus_W368-8;
    done
done

for i in {2,8}
do
    for c in {1..24}
    do
        singularity exec smcpp_latest.sif smc++ vcf2smc --cores 32 -d C_radiosus_W368-$i C_radiosus_W368-$i $VCF CRAD_vcf2smc_files/CRAD.d.C_radiosus_W368-$i.Chr$c.smc.txt Chr$c CRAD:CRAD_18-10,CRAD_18-11,CRAD_18-2,CRAD_18-3,CRAD_18-4,CRAD_18-5,CRAD_18-6,CRAD_18-7,CRAD_18-8,CRAD_18-9,C_radiosus_W368-2,C_radiosus_W368-8;
    done
done
