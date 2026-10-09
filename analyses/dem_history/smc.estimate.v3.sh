#!/bin/bash
#SBATCH --job-name=smc_estimate
#SBATCH --account=co_fishes
#SBATCH --partition=savio3
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=10-00:00
#SBATCH --mail-user=davidtian@berkeley.edu
#SBATCH --mail-type=END,FAIL

singularity exec smcpp_latest.sif smc++ estimate --cores 32 --base CRAD_piecewise_V3 --outdir CRAD_popsize_output/ 8.09e-9 CRAD_vcf2smc_files/CRAD.d.*Chr*.smc.txt
singularity exec smcpp_latest.sif smc++ estimate --cores 32 --base CRAD_spline_cubic_V3 --spline cubic --outdir CRAD_popsize_output/ 8.09e-9 CRAD_vcf2smc_files/CRAD.d.*Chr*.smc.txt
singularity exec smcpp_latest.sif smc++ estimate --cores 32 --base CRAD_spline_pchip_V3 --spline pchip --outdir CRAD_popsize_output/ 8.09e-9 CRAD_vcf2smc_files/CRAD.d.*Chr*.smc.txt

#create csv
singularity exec smcpp_latest.sif smc++ plot CRAD.piecewise.V3.plot.pdf -g 1 CRAD_popsize_output/CRAD_piecewise_V3.final.json -c 
singularity exec smcpp_latest.sif smc++ plot CRAD.spline.cubic.V3.plot.pdf -g 1 CRAD_popsize_output/CRAD_spline_cubic_V3.final.json -c
singularity exec smcpp_latest.sif smc++ plot CRAD.spline.pchip.V3.plot.pdf -g 1 CRAD_popsize_output/CRAD_spline_pchip_V3.final.json -c
