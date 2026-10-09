library(dplyr)
library(ggplot2)
library(forcats)

##### Read in ROH calling results and chrom data #####

chroms <- read.table('MIO.chrom.sizes.genome', sep = '\t', header = FALSE)
colnames(chroms) <- c('chrom','length')
tot.len <- sum(chroms$length)

## BCFtools/ROH
## GT

bcf.gt.full <- read.table('CRAD_GTonly_RG_ONLY.txt',
                          header = FALSE, sep = '\t')
colnames(bcf.gt.full) <- c('RG','id','chrom','start','end','length','n.snps','quality')
#add in pop data 
bcf.gt.full <- bcf.gt.full %>%
  mutate(pop = case_when(
    grepl("W368", id) ~ "Well 368",
    TRUE              ~ "WMRS"
  ))
bcf.gt.full <- bcf.gt.full[bcf.gt.full$length >= 100000,] ## applying 100kb filter, as would normally be done

short = bcf.gt.full %>% 
  filter(length >= 100000 & length < 500000) %>% 
  group_by(id) %>%
  summarise_at(c("length"), sum, na.rm = T) %>%
  mutate(totalLenGb = length/10^9, 
         Range = "0.1-0.5 Mb") %>% 
  as.data.frame()

medium = bcf.gt.full %>% 
  filter(length >= 500000 & length < 1000000) %>% 
  group_by(id) %>%
  summarise_at(c("length"), sum, na.rm = T) %>% 
  mutate(totalLenGb = length/10^9, 
         Range = "0.5-1 Mb")  %>% 
  as.data.frame()

long = bcf.gt.full %>% 
  filter(length >= 1000000 & length < 1500000) %>% 
  group_by(id) %>%
  summarise_at(c("length"), sum, na.rm = T) %>%
  mutate(totalLenGb = length/10^9, 
         Range = "1-1.5 Mb") %>% 
  as.data.frame()

bcf.gt.full %>% 
  filter(id =="CRAD_18-2") %>%
  summarise_at(c("length"), sum, na.rm = T)

#Merge interval data frames
FinalDF = rbind(short, medium, long)
FinalDF$Range = factor(FinalDF$Range, levels=c("0.1-0.5 Mb", "0.5-1 Mb", "1-1.5 Mb"))


ind_plot <- FinalDF %>%
  ggplot(aes(x=id, y=totalLenGb, fill=Range)) + 
  geom_bar(stat="identity", position = position_stack(reverse = TRUE)) + 
  coord_flip() + 
  scale_fill_manual(values = c("0.1-0.5 Mb"= "#D2B48C", 
                               "0.5-1 Mb" = "#FBB117",
                               "1-1.5 Mb" = "#F7793B"), 
                    breaks = c("0.1-0.5 Mb",
                               "0.5-1 Mb",
                               "1-1.5 Mb"), 
                    name = "Range") + 
  labs(x ="Individuals", y = "Length of the Genome in ROH (Gb)") + 
  #scale_y_continuous(expand = c(0, 0))+
  theme_classic()+
  theme(axis.text.x = element_text(size = 14), 
        #axis.text.y = element_text(size = 28),
        axis.text.y = element_blank(),
        axis.title=element_text(size=14),
        legend.title=element_text(size=14), 
        legend.text=element_text(size=14))
ind_plot
# Sum up the lengths for each individual
df_summed <- FinalDF %>%
  group_by(id) %>%
  summarize(FROH = sum(length)/tot.len) %>%
  mutate(pop = case_when(
    grepl("W368", id) ~ "Well 368",
    TRUE              ~ "WMRS"
  ))
print(df_summed)

label_colors <- c("WMRS" = "#964B20",
                  "Well 368" = "#00843E")

#boxplot comparison of FROH between pops 
pop_comp <- ggplot(df_summed, aes(x = pop, y = FROH, fill = pop)) +
  geom_boxplot() +
  scale_fill_manual(values = label_colors)+
  theme_classic() +
  labs(x = "Population",
       y = expression(F[ROH]))+
  theme(axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
       axis.title=element_text(size=14),
       legend.position = "none")

pop_comp

library(patchwork)
pop_comp + ind_plot + plot_layout(widths = c(1, 2)) + plot_annotation(tag_levels = 'A')

#stats for comparing pops
#ANOVA
anova_model <- aov(FROH ~ pop, data = df_summed)
summary(anova_model)
#P = 0.617
#t-test
t.test(FROH ~ pop, data = df_summed)
#p-value = 0.5846


#average FROH per pop 
df_summed %>%
  group_by(pop) %>%
  summarize(mean_FROH = mean(FROH, na.rm = TRUE))
#W368 = 0.104
#WMRS = 0.112

#average FROH acrss all 12 
df_summed %>%
  group_by(pop) %>%
  summarize(mean_FROH = mean(FROH, na.rm = TRUE))%>%
  pull(2) %>%
  mean()

#average size per individual 
bcf.gt.full %>%
  group_by(id) %>%
  summarize(mean_length = mean(length, na.rm = TRUE))

#average size of the average across ind 
bcf.gt.full %>%
  group_by(id) %>%
  summarize(mean_length = mean(length, na.rm = TRUE))%>%
  pull(2) %>%
  mean()

#mean porportion of ROHs per ind that is in the 0.1 - 0.5 category
FinalDF %>% 
  group_by(id) %>% 
  mutate(
    total = sum(length, na.rm = TRUE),
    proportion = length / total
  ) %>% 
  ungroup() %>% 
  filter(Range == "0.1-0.5 Mb") %>%
  summarize(mean_prop = mean(proportion, na.rm = TRUE))


#histogram of ROH sizes per ind
ggplot(bcf.gt.full, aes(x = length)) +
  geom_histogram(fill = "steelblue", color = "black") +
  facet_wrap(~ id) +
  theme_classic() +
  labs(title = "ROH Length Distribution per Individual", 
       x = "Length", 
       y = "Count")
