#!/bin/bash
#SBATCH --job-name=pixy
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

pixy --stats pi fst dxy watterson_theta tajima_d \
--vcf /global/scratch/users/davidtian/radiosus_proj/filtered_VCFs/CRAD.filtered.allsites.vcf.gz \
--populations CRAD_WMRSvsW368_popfile.txt \
--window_size 250000 \
--n_cores 32 \
--fst_components \
--tajima_components \
--output_folder output \
--output_prefix pixy_output_WMRSvsW368_250kb_win

#pi and watterson's theta and tajima's D regardless of population
pixy --stats pi watterson_theta tajima_d \
--vcf /global/scratch/users/davidtian/radiosus_proj/filtered_VCFs/CRAD.filtered.allsites.vcf.gz \
--populations CRAD_popfile.txt \
--window_size 250000 \
--n_cores 32 \
--tajima_components \
--output_folder output \
--output_prefix pixy_output_CRAD_250kb_win
