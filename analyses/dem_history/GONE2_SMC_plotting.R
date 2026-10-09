library(ggplot2)
library(tidyverse)
library(readr)
library(stringr)
library(patchwork)

r2.8.files <- list.files(pattern = "r2.8.bootstrap.[0-9]+_GONE2_Ne$", 
                    full.names = TRUE)

#add bootstrap number
r2.8.df <- lapply(r2.8.files, function(f) {
  run_num <- str_extract(f, "(?<=bootstrap\\.)[0-9]+")
  read_table(f, skip = 1, col_names = c("Generation", "Ne_diploids")) %>%
    mutate(Run = run_num)
}) %>%
  bind_rows()

#switch from gen to yrs assuming 1 gen = 1 year
#calibrate based on sampling time of 1994, starts at generation 1, so need to do 1995-1 to get 1994 = gen 1
r2.8.df <- r2.8.df %>% mutate(Year = 1995-Generation)

#calculate median and 95% CI across bootstraps for each year
summary_r2.8.df <- r2.8.df %>%
  group_by(Year) %>%
  summarise(
    median_Ne = median(Ne_diploids),
    lower = quantile(Ne_diploids, 0.025),
    upper = quantile(Ne_diploids, 0.975)
  )

GONE2_plot <- ggplot() +
  #plot bootstraps
  geom_line(data = r2.8.df, aes(x = Year, y = Ne_diploids, group = Run),
            color = "grey50", linewidth = 0.4, alpha = 0.5) +
  #plot median
  geom_line(data = summary_r2.8.df, aes(x = Year, y = median_Ne),
            color = "#964B20", linewidth = 2) +
  #bucket annotation
  geom_segment(aes(x = 1969, xend = 1969, y = -Inf, yend = 1450), 
               linetype = "dashed") +
  annotate("text", x = c(1969), y = 1540, label = c("Saved by \n P. Pister"),
           size = 5, fontface = "bold", hjust = 0.5, vjust = 0.5)+
  #presumed extinct
  geom_segment(aes(x = 1942, xend = 1942, y = -Inf, yend = 1450), 
               linetype = "dashed") +
  annotate("text", x = c(1942), y = 1540, label = c("Presumed \n extinct"),
           size = 5, fontface = "bold", hjust = 0.5, vjust = 0.5)+
  #LA aquaduct
  geom_segment(aes(x = 1913, xend = 1913, y = -Inf, yend = 1450), 
               linetype = "dashed") +
  annotate("text", x = c(1913), y = 1540, label = c("Diversion of water \n to Los Angeles"),
           size = 5, fontface = "bold", hjust = 0.5, vjust = 0.5)+
  scale_x_reverse(limits = c(1994,1845),
                  expand = expansion(mult = c(0, 0)),
                  breaks = seq(1990, 1850, by = -30)) +
  labs(y = expression(paste("Historical ",italic(N[e])))) +
  coord_cartesian(ylim = c(0, 1675)) +
  theme_classic(base_size = 20)
GONE2_plot


#Supp. Fig. comparing rec rates

rec.rate.files <- list.files(pattern = "bootstrap.[0-9]+_GONE2_Ne$", 
                         full.names = TRUE)

rec.rate.df <- lapply(rec.rate.files, function(f) {
  run_num <- str_extract(f, "(?<=bootstrap\\.)[0-9]+")
  r_val   <- str_extract(f, "(?<=r)[0-9.]+(?=\\.bootstrap)") #2.3, 2.8, 3.3
  read_table(f, skip = 1, col_names = c("Generation", "Ne_diploids")) %>%
    mutate(Run = run_num,
           R_value = r_val)
}) %>%
  bind_rows()

rec.rate.df <- rec.rate.df %>% mutate(Year = 1994-Generation)

rec.rate_summary_df <- rec.rate.df %>%
  group_by(R_value, Year) %>%
  summarise(
    median_Ne = median(Ne_diploids),
    lower = quantile(Ne_diploids, 0.025),
    upper = quantile(Ne_diploids, 0.975)
  )


colors <- c("#FFA500", "#964B20", "#4F7942")

rec.rate.comp.plot <- ggplot() +
  #95% CI ribbon per rec rate, use ribbons, lines too messy
  geom_ribbon(data = rec.rate_summary_df,
              aes(x = Year, ymin = lower, ymax = upper, fill = R_value, group = R_value),
             alpha = 0.3, color = NA) +
  # median line per rec rate
  geom_line(data = rec.rate_summary_df, 
            aes(x = Year, y = median_Ne, color = R_value, group = R_value),
            linewidth = 1.5) +
  geom_segment(aes(x = 1969, xend = 1969, y = -Inf, yend = 1550), 
               linetype = "dashed") +
  annotate("text", x = c(1969), y = 1615, label = c("Saved by \n P. Pister"),
           size = 5, fontface = "bold", hjust = 0.5, vjust = 0.5)+
  #presumed extinct
  geom_segment(aes(x = 1942, xend = 1942, y = -Inf, yend = 1550), 
               linetype = "dashed") +
  annotate("text", x = c(1942), y = 1615, label = c("Presumed \n extinct"),
           size = 5, fontface = "bold", hjust = 0.5, vjust = 0.5)+
  #LA aquaduct
  geom_segment(aes(x = 1913, xend = 1913, y = -Inf, yend = 1550), 
               linetype = "dashed") +
  annotate("text", x = c(1913), y = 1615, label = c("Diversion of water \n to Los Angeles"),
           size = 5, fontface = "bold", hjust = 0.5, vjust = 0.5)+
  scale_x_reverse(limits = c(1994,1845),
                  expand = expansion(mult = c(0, 0)),
                  breaks = seq(1990, 1850, by = -30)) +
  labs(y = expression(paste("Historical ",italic(N[e]))), 
       color = "Rec. rate") +
  guides(fill = "none")+
  scale_fill_manual(values = colors)+
  theme_classic(base_size = 20)+
  scale_color_manual(
    values = colors,
    labels = \(x) paste(x, "cM/Mb")) + 
  theme(legend.position = "inside",
        legend.position.inside = c(1,0.05),
        legend.justification = c("right", "bottom"),
        legend.box.just = "center",                
        legend.title = element_text(hjust = 0.5),
        legend.text = element_text(hjust = 0.5) )
rec.rate.comp.plot


#SMC++

SMC_piecewise_data <- read.csv("CRAD.piecewise.V3.plot.csv")
SMC_spline_cubic_data <- read.csv("CRAD.spline.cubic.V3.plot.csv")
SMC_spline_pchip_data <- read.csv("CRAD.spline.pchip.V3.plot.csv")

#filter out zero for log scale 
filtered_SMC_data <- SMC_piecewise_data %>% filter(x > 0)

SMC_plot <- ggplot(filtered_SMC_data, aes(x = x, y = y)) +
  geom_line(color = "#FFA500", size = 2) +
  scale_x_log10(
    breaks = c(1000, 10000),
    labels = scales::trans_format("log10", scales::math_format(10^.x))
  ) +
  annotation_logticks(sides = "b")+
  annotate("rect", xmin = 7700, xmax = 27000, ymin = -Inf, ymax = Inf, 
          fill = "gray50", alpha = 0.2) +
  annotate("text", x = 14418, y = 6000, label = "Drying of \n Owens Valley", #log midpoint 
          size = 5, fontface = "bold", hjust = 0.5, vjust = 0.5)+
  labs(x = "Years ago", y = expression(paste("Historical ",italic(N[e])))) +
  theme_classic(base_size = 20)

SMC_plot

#patchwork GONE and SMC++ plot
SMC_plot / GONE2_plot + plot_annotation(tag_levels = "A")
