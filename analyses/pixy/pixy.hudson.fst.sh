#!/bin/bash
#SBATCH --job-name=pixy.hudson.fst
#SBATCH --output=R-%x.%j.out
#SBATCH --error=R-%x.%j.err
#SBATCH --time=72:00:00
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=32
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --mail-type=END,FAIL
#SBATCH --account=co_fishes
#SBATCH -p savio3

source activate pixy2

pixy --stats fst \
--vcf /global/scratch/users/davidtian/radiosus_proj/filtered_VCFs/CRAD.filtered.allsites.vcf.gz \
--populations CRAD_WMRSvsW368_popfile.txt \
--window_size 250000 \
--n_cores 32 \
--fst_type hudson \
--fst_components \
--output_folder output \
--output_prefix pixy_output_WMRSvsW368_250kb_win_hudson
