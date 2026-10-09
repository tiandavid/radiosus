#!/bin/bash
#SBATCH --job-name=admix
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --time=4:30:00
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --account=co_fishes
#SBATCH -p savio3

source activate admixture
for K in 1 2 3 4 5 6 7 8 9 10; \
do \
admixture \
--cv \
-j32 \
CRAD.chrs.only.rm.CYPRAD18_1.plink.PCA.indep-pairwise.50_10_0.2.keep.bed $K \
| tee log.CRAD.chrs.only.rm.CYPRAD18_1.K${K}.out;
done

for K in 1 2 3 4 5 6 7 8 9 10; \
do \
admixture \
--cv \
-j32 \
CRAD.chrs.only.rm.CYPRAD18_1.plink.PCA.minAC2.indep-pairwise.50_10_0.2.keep.bed $K \
| tee log.CRAD.chrs.only.rm.CYPRAD18_1.minAC2.K${K}.out;
done
