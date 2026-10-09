library(data.table)
library(tidyverse)
library(viridis)
library(PNWColors)
library(ggplot2)
library(patchwork)

# Convert a set of pixy output files to a single long-format data frame.
# Handles both single-population stats (pi, watterson_theta, tajima_d) and
# pairwise stats (dxy, fst).
pixy_to_long <- function(pixy_files) {
  
  single_pop_stats <- c("pi", "watterson_theta", "tajima_d")
  pixy_df <- list()
  
  for (i in seq_along(pixy_files)) {
    
    # Extract the suffix from filenames like "pixy_watterson_theta.txt"
    #stat_file_type <- sub("^pixy_output_WMRSvsW368_50kb_win_", "", 
    #                     sub("\\.txt$", "", basename(pixy_files[i])))
    stat_file_type <- sub("^pixy_output_CRAD_50kb_win_", "",  #this is hard coded 
                          sub("\\.txt$", "", basename(pixy_files[i])))
    
    df <- read_delim(pixy_files[i], delim = "\t")
    
    if (stat_file_type %in% single_pop_stats) {
      df <- df %>%
        mutate(across(everything(), as.character)) %>%  # <-- fix
        gather(-pop, -window_pos_1, -window_pos_2, -chromosome,
               key = "statistic", value = "value") %>%
        rename(pop1 = pop) %>%
        mutate(pop2 = NA)
    } else {
      df <- df %>%
        mutate(across(everything(), as.character)) %>%  # <-- fix
        gather(-pop1, -pop2, -window_pos_1, -window_pos_2, -chromosome,
               key = "statistic", value = "value")
    }
    
    pixy_df[[i]] <- df
  }
  
  bind_rows(pixy_df) %>%
    mutate( #fix
      window_pos_1 = as.numeric(window_pos_1), #fix
      window_pos_2 = as.numeric(window_pos_2),#fix
      value = suppressWarnings(as.numeric(value))  # tajima_d_s_counts becomes NA, that's fine
    ) %>%
    arrange(pop1, pop2, chromosome, window_pos_1, statistic)
} #this version is hardcoded input 


pixy_to_long <- function(pixy_files) {
  
  pixy_df <- list()
  
  for (i in seq_along(pixy_files)) {
    
    df <- read_delim(pixy_files[i], delim = "\t")
    
    if ("pop" %in% names(df)) {
      df <- df %>%
        mutate(across(everything(), as.character)) %>%
        gather(-pop, -window_pos_1, -window_pos_2, -chromosome,
               key = "statistic", value = "value") %>%
        rename(pop1 = pop) %>%
        mutate(pop2 = NA)
    } else {
      df <- df %>%
        mutate(across(everything(), as.character)) %>%
        gather(-pop1, -pop2, -window_pos_1, -window_pos_2, -chromosome,
               key = "statistic", value = "value")
    }
    
    pixy_df[[i]] <- df
  }
  
  bind_rows(pixy_df) %>%
    mutate(
      window_pos_1 = as.numeric(window_pos_1),
      window_pos_2 = as.numeric(window_pos_2),
      value = suppressWarnings(as.numeric(value))
    ) %>%
    arrange(pop1, pop2, chromosome, window_pos_1, statistic)
}



#tajimas D functions for post hoc aggregation
parse_tajima_d_s_counts <- function(value) {
  if (length(value) == 0 || is.na(value)) {
    return(setNames(numeric(), character()))
  }
  
  value <- as.character(value)
  if (value == "" || value == "NA") {
    return(setNames(numeric(), character()))
  }
  
  counts <- setNames(numeric(), character())
  for (item in strsplit(value, ",", fixed = TRUE)[[1]]) {
    pair <- strsplit(item, ":", fixed = TRUE)[[1]]
    n <- pair[1]
    old <- counts[n]
    if (is.na(old)) {
      old <- 0
    }
    counts[n] <- old + as.numeric(pair[2])
  }
  counts
}

combine_tajima_d_s_counts <- function(values) {
  total <- setNames(numeric(), character())
  for (value in values) {
    counts <- parse_tajima_d_s_counts(value)
    for (n in names(counts)) {
      old <- total[n]
      if (is.na(old)) {
        old <- 0
      }
      total[n] <- old + counts[n]
    }
  }
  total
}

calc_tajima_d_stdev <- function(s_counts) {
  stdev <- 0
  for (n_name in names(s_counts)) {
    n <- as.integer(n_name)
    s <- as.numeric(s_counts[n_name])
    if (is.na(n) || n < 2 || s <= 0) {
      next
    }
    
    i <- seq_len(n - 1)
    a1 <- sum(1 / i)
    a2 <- sum(1 / (i^2))
    b1 <- (n + 1) / (3 * (n - 1))
    b2 <- 2 * (n^2 + n + 3) / (9 * n * (n - 1))
    c1 <- b1 - (1 / a1)
    c2 <- b2 - ((n + 2) / (a1 * n)) + (a2 / (a1^2))
    e1 <- c1 / a1
    e2 <- c2 / (a1^2 + a2)
    
    stdev <- stdev + sqrt((e1 * s) + (e2 * s * (s - 1)))
  }
  stdev
}

aggregate_tajima_d <- function(rows) {
  raw_pi <- sum(rows$raw_pi, na.rm = TRUE)
  raw_watterson_theta <- sum(rows$raw_watterson_theta, na.rm = TRUE)
  s_counts <- combine_tajima_d_s_counts(rows$tajima_d_s_counts)
  tajima_d_stdev <- calc_tajima_d_stdev(s_counts)
  tajima_d <- if (tajima_d_stdev <= 0) {
    NA_real_
  } else {
    (raw_pi - raw_watterson_theta) / tajima_d_stdev
  }
  
  data.frame(
    tajima_d = tajima_d,
    no_sites = sum(rows$no_sites, na.rm = TRUE),
    raw_pi = raw_pi,
    raw_watterson_theta = raw_watterson_theta,
    tajima_d_stdev = tajima_d_stdev
  )
}


pixy_folder <- "CRAD_250kb_output"

pixy_files <- list.files(pixy_folder, full.names = TRUE)
pixy_df <- pixy_to_long(pixy_files)

#genome wide 
# create a custom labeller for special characters in the pixy summary stats
pixy_labeller <- as_labeller(c(avg_pi              = "pi",
                               avg_dxy             = "D[XY]",
                               avg_wc_fst          = "F[ST]",
                               avg_hudson_fst      = "F[ST]",
                               avg_watterson_theta = "theta[W]",
                               tajima_d            = "Tajima*minute*s~D"),
                             default = label_parsed)

pixy_df <- pixy_df %>%
  filter(!startsWith(chromosome, "Sca"))

# plotting summary statistics across all chromosomes
pixy_df %>%
  mutate(chrom_color_group = case_when(
    as.numeric(sub("Chr", "", chromosome)) %% 2 != 0 ~ "odd",
    TRUE ~ "even"
  )) %>%
  mutate(chromosome = factor(chromosome, levels = paste0("Chr", 1:24))) %>%
  filter(statistic %in% c("avg_pi",
                          #"avg_dxy", 
                          #"avg_wc_fst",
                          "avg_watterson_theta",
                          "tajima_d"
  )) %>%
  ggplot(aes(x = (window_pos_1 + window_pos_2)/2, y = value, color = chrom_color_group))+
  geom_point(size = 1.2, alpha = 0.5, stroke = 0)+
  facet_grid(statistic ~ chromosome,
             scales = "free_y", switch = "x", space = "free_x",
             labeller = labeller(statistic = pixy_labeller,
                                 value = label_value,
                                 chromosome = function(x) sub("Chr", "", x))
  )+
  xlab("Chromosome")+
  ylab("Statistic Value")+
  scale_color_manual(values = c("grey50", "black"))+
  theme_classic()+
  theme(axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.text.y = element_text(size = 12),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        panel.spacing = unit(0.1, "cm"),
        strip.background = element_blank(),
        strip.placement = "outside",
        strip.text.x = element_text(size = 12),
        #strip.text.y = element_blank(),
        strip.text.y = element_text(size = 14),
        legend.position = "none")


#sanity checks
pixy_df %>%
  filter(statistic == "tajima_d") %>%
  filter(is.na(value) | !(chromosome %in% paste0("Chr", 1:24))) %>%
  count(chromosome, is.na(value)) #23

pixy_df %>%
  filter(statistic == "tajima_d") %>%
  filter(!(chromosome %in% paste0("Chr", 1:24))) %>%
  count(chromosome) #0

pixy_df %>%
  filter(statistic == "tajima_d") %>%
  filter(is.na(window_pos_1) | is.na(window_pos_2)) #0

pixy_df %>%
  filter(statistic == "tajima_d") %>%
  filter(is.infinite(value)) #0

df_check <- pixy_df %>%
  mutate(chromosome = factor(chromosome, levels = paste0("Chr", 1:24))) %>%
  filter(statistic == "tajima_d")

nrow(df_check)
nrow(df_check %>% filter(!is.na(chromosome)))
nrow(df_check %>% filter(!is.na(value)))
nrow(df_check %>% filter(!is.na((window_pos_1 + window_pos_2)/2)))

#CRAD WMRS vs W368
#Post-hoc aggregating
#WC Fst
pixy_CRAD_WMRSvsW368_fst <- read.table("CRAD_WMRSvsW368_250kb_output/pixy_output_WMRSvsW368_250kb_win_fst.txt", header = TRUE, sep = "\t")
CRAD_WMRSvsW368_fst <- sum(pixy_CRAD_WMRSvsW368_fst$wc_fst_a) / (sum(pixy_CRAD_WMRSvsW368_fst$wc_fst_a) + sum(pixy_CRAD_WMRSvsW368_fst$wc_fst_b) + sum(pixy_CRAD_WMRSvsW368_fst$wc_fst_c))
CRAD_WMRSvsW368_fst #Fst = 0.05499644


#Hudson Fst 
pixy_CRAD_WMRSvsW368_hudson_fst <- read.table("CRAD_WMRSvsW368_250kb_output/pixy_output_WMRSvsW368_250kb_win_hudson_fst.txt", header = TRUE, sep = "\t")
CRAD_WMRSvsW368_hudson_fst <- sum(pixy_CRAD_WMRSvsW368_hudson_fst$hudson_fst_num) / sum(pixy_CRAD_WMRSvsW368_hudson_fst$hudson_fst_den) 
CRAD_WMRSvsW368_hudson_fst #-0.0002486083
  
#Dxy
pixy_CRAD_WMRSvsW368_dxy <- read.table("CRAD_WMRSvsW368_500kb_output/pixy_output_WMRSvsW368_500kb_win_dxy.txt", header = TRUE, sep = "\t")
CRAD_WMRSvsW368_dxy <- sum(pixy_CRAD_WMRSvsW368_dxy$count_diffs, na.rm = TRUE) / sum(pixy_CRAD_WMRSvsW368_dxy$count_comparisons, na.rm = TRUE)
CRAD_WMRSvsW368_dxy #Dxy = 0.0005885096

#pi 
pixy_CRAD_WMRSvsW368_pi <- read.table("CRAD_WMRSvsW368_500kb_output/pixy_output_WMRSvsW368_500kb_win_pi.txt", header = TRUE, sep = "\t")

pixy_WMRS_pi <- pixy_CRAD_WMRSvsW368_pi %>% filter(pop == "WMRS")
WMRS_pi <- sum(pixy_WMRS_pi$count_diffs, na.rm = TRUE) / sum(pixy_WMRS_pi$count_comparisons, na.rm = TRUE)
WMRS_pi #0.0005417125

pixy_W368_pi <- pixy_CRAD_WMRSvsW368_pi %>% filter(pop == "W368")
W368_pi <- sum(pixy_W368_pi$count_diffs, na.rm = TRUE) / sum(pixy_W368_pi$count_comparisons, na.rm = TRUE)
W368_pi #0.0006205249

#wattersons theta
pixy_CRAD_WMRSvsW368_theta <- read.table("CRAD_WMRSvsW368_500kb_output/pixy_output_WMRSvsW368_500kb_win_watterson_theta.txt", header = TRUE, sep = "\t")

pixy_WMRS_theta <- pixy_CRAD_WMRSvsW368_theta %>% filter(pop == "WMRS")
WMRS_theta <- sum(pixy_WMRS_theta$raw_watterson_theta, na.rm = TRUE) / sum(pixy_WMRS_theta$no_sites, na.rm = TRUE)
WMRS_theta #0.0005747983

pixy_W368_theta <- pixy_CRAD_WMRSvsW368_theta %>% filter(pop == "W368")
W368_theta <- sum(pixy_W368_theta$raw_watterson_theta, na.rm = TRUE) / sum(pixy_W368_theta$no_sites, na.rm = TRUE)
W368_theta #0.0009697276

#tajimaD
pixy_CRAD_WMRSvsW368_tajimaD <- read.table("CRAD_WMRSvsW368_500kb_output/pixy_output_WMRSvsW368_500kb_win_tajima_d.txt", header = TRUE, sep = "\t")

pixy_WMRS_tajimaD <- pixy_CRAD_WMRSvsW368_tajimaD %>% filter(pop == "WMRS")
aggregate_tajima_d(pixy_WMRS_tajimaD)
#output
#    tajima_d  no_sites   raw_pi raw_watterson_theta tajima_d_stdev
#1 0.1426195 870585845 517026.7            500411.3       116501.7

(sum(raw_pi) - sum(raw_watterson_theta)) / recomputed_tajima_d_stdev
tajD <- (517026.7-500411.3)/116501.7
tajD #0.1426194


pixy_W368_tajimaD <- pixy_CRAD_WMRSvsW368_tajimaD %>% filter(pop == "W368")

aggregate_tajima_d(pixy_W368_tajimaD)
#output
#     tajima_d  no_sites   raw_pi raw_watterson_theta tajima_d_stdev
#1 -4.999804 839329851 562855.7            813921.4       50215.11

(sum(raw_pi) - sum(raw_watterson_theta)) / recomputed_tajima_d_stdev
tajD <- (562855.7-813921.4)/50215.11
tajD #-4.999804



##################################################################################################################
#CRAD overall
#Post-hoc aggregating
#pi
pixy_CRAD_pi <- read.table("CRAD_250kb_output/pixy_output_CRAD_250kb_win_pi.txt", header = TRUE, sep = "\t")

CRAD_pi <- sum(pixy_CRAD_pi$count_diffs, na.rm = TRUE) / sum(pixy_CRAD_pi$count_comparisons, na.rm = TRUE)
CRAD_pi #0.0005559766


#wattersons theta
pixy_CRAD_theta <- read.table("CRAD_500kb_output/pixy_output_CRAD_500kb_win_watterson_theta.txt", header = TRUE, sep = "\t")
CRAD_theta <- sum(pixy_CRAD_theta$raw_watterson_theta, na.rm = TRUE) / sum(pixy_CRAD_theta$no_sites, na.rm = TRUE)
CRAD_theta #0.000568725


#tajimaD
pixy_CRAD_tajimaD <- read.table("CRAD_250kb_output/pixy_output_CRAD_250kb_win_tajima_d.txt", header = TRUE, sep = "\t")
aggregate_tajima_d(pixy_CRAD_tajimaD)
#output
#   tajima_d  no_sites   raw_pi raw_watterson_theta tajima_d_stdev
#1 0.2640691 871139332 526912.3            495438.7         119187

(sum(raw_pi) - sum(raw_watterson_theta)) / recomputed_tajima_d_stdev
tajD <- (526912.3-495438.7)/119187
tajD #0.2640691

########################################################################################################
#outliers
#250kb
#Fst###########################################################
pixy_CRAD_WMRSvsW368_fst_250kb <- read.table("CRAD_WMRSvsW368_250kb_output/pixy_output_WMRSvsW368_250kb_win_fst.txt", header = TRUE, sep = "\t")

pixy_CRAD_WMRSvsW368_fst_250kb %>% filter(avg_wc_fst > 0.4) 
write_tsv(pixy_CRAD_WMRSvsW368_fst_250kb , "pixy_CRAD_WMRSvsW368_fst_0.4min_250kb.tsv")
#15 windows

pixy_CRAD_WMRSvsW368_fst_50kb <- read.table("CRAD_WMRSvsW368_50kb_output/pixy_output_WMRSvsW368_50kb_win_fst.txt", header = TRUE, sep = "\t")
pixy_CRAD_WMRSvsW368_fst_50kb %>% filter(avg_wc_fst > 0.7)
#406 windows 
#> 0.5 146 windows 
#> 0.6 52 windows 
#> 0.7 15 windows 

pixy_CRAD_WMRSvsW368_fst_500kb <- read.table("CRAD_WMRSvsW368_500kb_output/pixy_output_WMRSvsW368_500kb_win_fst.txt", header = TRUE, sep = "\t")
pixy_CRAD_WMRSvsW368_fst_500kb %>% filter(avg_wc_fst > 0.4)
#2 windows 

fst_outliers <- pixy_CRAD_WMRSvsW368_fst_250kb %>% 
  filter(avg_wc_fst >= quantile(avg_wc_fst, 0.995, na.rm = TRUE))

write_tsv(fst_outliers, "fst_outliers")

#Dxy###########################################################
pixy_CRAD_WMRSvsW368_dxy_250kb <- read.table("CRAD_WMRSvsW368_250kb_output/pixy_output_WMRSvsW368_250kb_win_Dxy.txt", header = TRUE, sep = "\t")

dxy_outliers <- pixy_CRAD_WMRSvsW368_dxy_250kb %>% 
  filter(avg_dxy >= quantile(avg_dxy, 0.995, na.rm = TRUE))

write_tsv(dxy_outliers, "dxy_outliers")

#pi######################################
pixy_CRAD_pi_250kb <- read.table("CRAD_250kb_output/pixy_output_CRAD_250kb_win_pi.txt", header = TRUE, sep = "\t")
pixy_CRAD_pi_250kb %>% filter(avg_pi > 0.004)
#14 windows
write_tsv(pixy_CRAD_pi_250kb, "pixy_CRAD_pi_0.004min_250kb.tsv")

pi_outliers <- pixy_CRAD_pi_250kb %>% 
  filter(avg_pi >= quantile(avg_pi, 0.99, na.rm = TRUE))

write_tsv(pi_outliers, "pi_outliers_99_percentile.tsv")




#theta######################################
pixy_CRAD_theta_250kb <- read.table("CRAD_250kb_output/pixy_output_CRAD_250kb_win_watterson_theta.txt", header = TRUE, sep = "\t")
theta_outliers <- pixy_CRAD_theta_250kb %>% 
  filter(avg_watterson_theta >= quantile(avg_watterson_theta, 0.995, na.rm = TRUE))
write_tsv(theta_outliers, "theta_outliers")

#tajimaD##################################
pixy_CRAD_tajimaD_250kb <- read.table("CRAD_250kb_output/pixy_output_CRAD_250kb_win_tajima_d.txt", header = TRUE, sep = "\t")

# Calculate the threshold (99th percentile of absolute values)
threshold <- quantile(abs(pixy_CRAD_tajimaD_250kb$tajima_d), 0.99, na.rm = TRUE)

# Filter the dataframe for outliers
tajimaD_outliers <- pixy_CRAD_tajimaD_250kb[abs(pixy_CRAD_tajimaD_250kb$tajima_d) > threshold, ]
tajimaD_outliers <- tajimaD_outliers %>%
  filter(!is.na(tajima_d))
write_tsv(tajimaD_outliers, "tajimaD_outliers_99_percentile.tsv")

# Filter the dataframe for outliers (-2, 2)
tajimaD_outliers_2 <- pixy_CRAD_tajimaD_250kb[abs(pixy_CRAD_tajimaD_250kb$tajima_d) > 2, ]
tajimaD_outliers_2 <- tajimaD_outliers_2 %>%
  filter(!is.na(tajima_d))
write_tsv(tajimaD_outliers_2, "tajimaD_outliers_2")


######
#plotting repeats underneath chrom diversity
#code adapted from Faye Romero
######
options(scipen = 999)

# Load data
#RepeatMasker .out file
df <- fread("/Users/davidtian/Desktop/side_projects/radiosus_proj/repeats/MIO.finished.scaffolding.fasta.out", fill = T, header = T)
colnames(df) <- c("SW_score", "perc_div", "perc_del", "perc_ins", "query_sequence", "query_start", "query_end", "bases_ending", "matching", "repeat", "class", "bases_consensus", "db_start", "db_end", "ID", "star")
df <- df[-c(1:2), ]
df$query_start <- as.numeric(df$query_start)
df$query_end <- as.numeric(df$query_end)
df$query_sequence <- as.character(df$query_sequence)
#FSJ chrom lengths
lengths <- fread("/Users/davidtian/Desktop/side_projects/radiosus_proj/repeats/MIO.sizes.genome")
colnames(lengths) <- c("Chrom", "Chrom_Length")

# Merge
repeats_df <- left_join(df, lengths, by = c("query_sequence" = "Chrom"))
# Group repeat superfamilies (Kapitonov VV, Jurka J. 2008)
# Does not handle absolutely every class... but should cover all the major/important ones
repeats_df$class_group <- NA_character_
repeats_df <- repeats_df[repeats_df$class != "ARTEFACT",]
repeats_df$class_group[repeats_df$class %in% c("Unknown","Unspecified","Other")] <- "Unknown repeat"
repeats_df$class_group[repeats_df$class %in% c("LTR?","LTR", "LTR/ERV1", "LTR/ERV3", "LTR/ERVK", "LTR/ERVL", "LTR/ERVL?", "LTR/Unknown", "LTR/ERV")] <- "LTR"
repeats_df$class_group[repeats_df$class %in% c("SINE","SINE2","SINE?", "Retroposon", "SINE2/tRNA", "SINE/MIR", "SINE/Deu")] <- "Non-LTR"
repeats_df$class_group[repeats_df$class %in% c("LINE","LINE?", "LINE/CR1", "LINE/CR1?", "LINE/L2", "LINE/R2", "LINE/Penelope")] <- "LINE"
repeats_df$class_group[repeats_df$class %in% c("DNA","Tc1-Mariner","RC","RC?","DNA?", "DNA/PIF-Harbinger")] <- "DNA transposon"
repeats_df$class_group[repeats_df$class %in% c("tRNA","rRNA","snRNA","scRNA")] <- "housekeeping RNAs"
repeats_df$class_group[repeats_df$class %in% c("Low_complexity", "Simple_repeat")] <- "Simple repeat"
repeats_df$class_group[repeats_df$class %in% c("Satellite", "Satellite/Satellite", "Satellite/acro", "Satellite/macro", "Satellite/W-chromosome")] <- "Satellite"
repeats_df <- repeats_df %>% replace_na(list(class_group = "Other repeat"))

# Set window size and chromosome you're looking at

# Set window size (bp)
window_size <- 100000
# Set chromosome
#Chr24 = "HiC_scaffold_10"

CHR="HiC_scaffold_10"
df2 <- repeats_df %>% filter(query_sequence == CHR)
# Get chromosome length
chrom_len <- df2$Chrom_Length[1]

# Create windows and plotting function

# Build windows
windows <- data.frame(
  win_start = seq(0, chrom_len - 1, by = window_size)
) %>%
  mutate(win_end = pmin(win_start + window_size, chrom_len),
         win_size = win_end - win_start)
# Cross every element with every window, get overlap
repeats_to_plot <- crossing(
  df2 %>% select(class_group, query_start, query_end, class_group),
  windows
) %>%
  mutate(
    overlap = pmax(0, pmin(query_end, win_end) - pmax(query_start, win_start))
  ) %>%
  group_by(win_start, win_end, win_size, class_group) %>%
  summarise(total_bp = sum(overlap), .groups = "drop") %>%
  # fill missing data with 0
  complete(nesting(win_start, win_end, win_size),
           class_group,
           fill = list(total_bp = 0)) %>%
  mutate(
    proportion = total_bp / win_size,
    win_mid    = (win_start + win_end) / 2
  )
# Plotting function
plot_region <- function(data, region_start = NULL, region_end = NULL) {
  plot_data <- data
  if (!is.null(region_start)) {
    plot_data <- plot_data %>% filter(win_end > region_start)
  }
  if (!is.null(region_end)) {
    plot_data <- plot_data %>% filter(win_start < region_end)
  }
  ggplot(plot_data, aes(x = win_mid/1000000, y = proportion, fill = class_group)) +
    geom_area() +
    scale_x_continuous(expand = c(0, 0))+
    scale_y_continuous(expand = c(0, 0))+
    coord_cartesian(xlim = c(region_start, region_end)) +
    # geom_vline(xintercept = c(24798300, 39496000), linetype = "dashed", color = "black") +
    scale_fill_manual(values = pnw_palette("Shuksan2", 9)) +
    labs(x = "Position (Mb)", y = "Proportion of Window", fill = "Repeat group") +
    theme_classic()+
    #theme(legend.position = "bottom")+
    theme(legend.position = "none")
}
# usage: plot_region(repeats_to_plot, region_start, region_end)

# Plot

# Note that because of repeat element annotation/grouping weirdness, sometimes y axis (Prop of window) will be >1 if elements have been classified under multiple superfamilies (and/or if it was double annotated by RepeatMasker + LTRStruct)
# Whole chromosome
chr24_repeats <- plot_region(repeats_to_plot)


chr24_theta <- pixy_df %>%
  filter(chromosome == "Chr24") %>%
  #filter(statistic %in% c("avg_pi", "avg_dxy", "avg_wc_fst", "avg_watterson_theta")) %>%
  filter(statistic %in% c("avg_pi", 
                          #"avg_dxy", "avg_wc_fst",
                          "avg_watterson_theta"#, "tajima_d"
  )) %>%
  mutate(chr_position = ((window_pos_1 + window_pos_2)/2)/1000000) %>%
  mutate(statistic = factor(statistic,
                            levels = c("avg_pi", "avg_watterson_theta", "tajima_d"
                                       #"avg_wc_fst", "avg_dxy"
                            ))) %>%
  ggplot(aes(x = chr_position, y = value, color = statistic))+
  #geom_point(size = 2, alpha = 1, stroke = 0)+
  geom_line(linewidth = 0.25)+
  facet_grid(statistic ~ .,
             scales = "free_y", switch = "x", space = "free_x",
             labeller = labeller(statistic = pixy_labeller,
                                 value = label_value))+
  xlab("Position (Mb)")+
  ylab(NULL)+
  theme_bw()+
  theme(panel.spacing = unit(0.5, "cm"),
        strip.background = element_blank(),
        strip.placement = "outside",
        legend.position = "none")+
  scale_x_continuous(expand = c(0, 0))+
  scale_y_continuous(expand = c(0, 0), labels = scales::label_number())+
  scale_color_brewer(palette = "Set1")#+
#facet_wrap(~ chromosome)

c <- chr24_theta / chr24_repeats 
c + plot_annotation(tag_levels = 'A')
