#!/bin/bash
#SBATCH --job-name=gone2
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --time=72:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --account=co_fishes
#SBATCH -p savio3

GONE=/global/scratch/users/davidtian/download_software/GONE2/gone2

#rec rate 2.8
for i in {1..50}; do $GONE -r 2.8 CRAD.WMRS.ped -o CRAD.WMRS.r2.8.bootstrap.$i; done

#rec rate 2.3
for i in {1..50}; do $GONE -r 2.3 CRAD.WMRS.ped -o CRAD.WMRS.r2.3.bootstrap.$i; done

#rec rate 3.3
for i in {1..50}; do $GONE -r 3.3 CRAD.WMRS.ped -o CRAD.WMRS.r3.3.bootstrap.$i; done
