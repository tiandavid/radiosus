# Analyses

Population structure
* Convert VCF to plink format, prune, make PCA: plink.PCA.txt
* Run ADMIXTURE: admixture.sh
* Plot PCA in R: PCA_plotting.R (Fig. 1B)

Demographic history / effective population size 
* Run SMC++:
  + Vary distinguished individual and convert VCF to SMC++ format: vcf2smc.v3.sh
  + Run estimate and generate .csv output for plotting: smc.estimate.v3.sh
* Run GONE2 across recombination rates: GONE2.v2.sh
* Plot SMC++ and GONE2 results in R: GONE2_SMC_plotting.R (Fig. 2)
* Run currentNe2: currentNe2.sh

Pixy (pi, fst, theta, tajima's D)
* Run pixy on allsites VCF: pixy.sh and pixy.hudson.fst.sh
* Plot in R: pixy_plotting.R
