library(tidyverse)
library(ggplot2)

#final 6/17/26
pca <- read_table("CRAD.FINAL.chrs.only.rm.CYPRAD18_1.plink.PCA.indep-pairwise.50_10_0.2.keep.eigenvec", col_names = FALSE)
eigenval <- scan("CRAD.FINAL.chrs.only.rm.CYPRAD18_1.plink.PCA.indep-pairwise.50_10_0.2.keep.eigenval")

# remove nuisance column
pca <- pca[,-1]
# set names
names(pca)[1] <- "ind"
names(pca)[2:ncol(pca)] <- paste0("PC", 1:(ncol(pca)-1))

#populations
spp <- rep(NA, length(pca$ind))
spp[grep("18", pca$ind)] <- "WMRS"
spp[grep("W368", pca$ind)] <- "Well 368"

#make tibble 
pca <- as_tibble(data.frame(pca, spp))

#percent variance explained 
pve <- data.frame(PC = 1:13, pve = eigenval/sum(eigenval)*100)
pve <- data.frame(PC = 1:12, pve = eigenval/sum(eigenval)*100)


#plot percent variance explained for each principle component
a <- ggplot(pve, aes(PC, pve)) + geom_bar(stat = "identity")
a + ylab("Percentage variance explained") + theme_light()

# calculate the cumulative sum of the percentage variance explained
cumsum(pve$pve)

#color scheme
label_colors <- c("WMRS" = "#964B20",
                     "Well 368" = "#00843E")


#plot
b <- ggplot(pca, aes(PC1, PC2, col = spp)) + 
  geom_point(size = 6) + 
  theme_classic(base_size = 18) +
  xlab(paste0("PC1 (", signif(pve$pve[1], 3), "%)")) +
  ylab(paste0("PC2 (", signif(pve$pve[2], 3), "%)")) +
  scale_color_manual(values = label_colors) +
  labs(col = "Population") +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(ncol = 3))
b

c <- ggplot(pca, aes(PC2, PC3, col = spp)) + 
  geom_point(size = 6) + 
  theme_classic(base_size = 18) +
  xlab(paste0("PC2 (", signif(pve$pve[2], 3), "%)")) +
  ylab(paste0("PC3 (", signif(pve$pve[3], 3), "%)")) +
  scale_color_manual(values = label_colors) +
  labs(col = "Population") +
  theme(legend.position = "bottom") +
  guides(color = guide_legend(ncol = 3))
c
