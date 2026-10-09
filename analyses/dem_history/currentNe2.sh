#!/bin/bash
#SBATCH --job-name=currentNe2
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --time=20-00:00
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --account=co_fishes
#SBATCH -p savio3

currentNe2=/global/scratch/users/davidtian/Paper3_big_one/FINAL_RUN/analyses/currentNe2/currentNe2/currentne2

$currentNe2 -r 2.8 CRAD.WMRS.n10.yr1994.vcf -o CRAD.WMRS.n10.yr1994.currentNe2.r2.8_max
$currentNe2 CRAD.WMRS.n10.yr1994.vcf 24 -o CRAD.WMRS.n10.yr1994.currentNe2.chr24_max
