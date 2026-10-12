# Outline of genotyping pipeline

Steps 1-4 are identical to the pipeline from: https://github.com/tiandavid/reference_genomes_project/tree/main/genotyping_pipeline

1. Trimming reads:
   * trim_fastp.sh and run_trim_fastp.sh

2. Mapping reads
   * bwa_mem.sh and run_bwa_mem.sh

3. Marking duplicates, assessing quality and coverage
   * markdup_spark.sh and run_markdup_spark.sh
   * qualimap.sh and run_qualimap.sh

4. Calling variants with GATK Haplotype Caller

   * GATK_haplotype_caller.sh and run_GATK_haplotype_caller.sh
  
5. Generate genomics database per chromosome with GenomicsDatabaseImport
   * genomicsDBImport.sh with MIO.chrom.chrs.list and MIO.chrom.scaffs.list

6. Joint genotyping with GATK genotypeGVCFs to produce allsites VCF
  * genotypeGVCFs.allsites.sh

7. Separate invariant sites from allsites and reset missing genotypes to ./. from 0/0 due to recent GATK change
  * fixmissgeno.sep.var.invar.sh
 
8. Filter invariant sites based on mappability, minimum RGQ of 20, and minimum read depth of 3
  * filter.invariant.sh

9. Filtering variant sites 

* Restrict SNPS to biallelic and GATK recommended hard filters
  * GATK.hard.filter.excl.filt.var.sh
 
* Apply genmap mappability mask. min GQ20, min read depth 3 filters
  * mappability.GQ.DP.filter.sh

 
* Filter based on site depth: minimum of 1/3x mean depth, maximum of 2x mean depth
  * vcftools.stats.sh and vcf_metrics.R
  * site.min.max.depth.filter.sh

* Max site missingness of 25% filter
  * DHP.maxmissingness25.sh and MIO.maxmissingness25.sh
 

17. Make chromosome only version of final VCF
  * DHP.restrict.VCF.to.chrs.sh and MIO.restrict.VCF.to.chrs.sh
