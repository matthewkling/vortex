

library(dplyr)
library(tidyr)
library(ggplot2)
select <- dplyr::select

setwd("~/documents/vortex")

# open master data table
d <- read.csv("output/master_county_data/master_county_data.csv")

# split into independent and dependent data frames
race <- d[,grepl("Census|_fips", names(d))]
names(race) <- sub("CensusRace...", "", names(race))
d <- d[,!grepl("Census", names(d))]

# variables to visualize
variables <- names(d)[grepl("\\.\\.\\.", names(d))]
variables <- variables[!grepl("Fire_risk", variables) | grepl("\\.risk_", variables)] # drop fire metadata variables

for(var in variables){
      v <- d[,var]
      if(class(v)=="factor") v <- as.character(v)
      v <- as.numeric(v)
      v <- cbind(race, v) %>%
            select(v, state_county_fips, TOT_POP, WA:H) %>%
            select(-NH, -Na) %>%
            gather(race, pop, -v, -state_county_fips, -TOT_POP) %>%
            group_by(race) %>%
            mutate(prop_pop = pop / sum(na.omit(pop))) %>%
            na.omit()
      
      m <- summarize(v, wmean = weighted.mean(v, pop))
      
      name <- sub("\\.\\.\\.", ": ", var)
      colors <- c("darkgoldenrod1", "black", "red", "forestgreen", "dodgerblue")
      
      p <- ggplot(v, aes(v, weight=prop_pop, color=factor(race), fill=factor(race))) +
            geom_density(adjust=2, alpha=.2, size=.25) +
            geom_vline(data=m, aes(xintercept=wmean, color=factor(race))) +
            scale_fill_manual(values=colors) +
            scale_color_manual(values=colors) +
            theme_minimal() +
            theme(axis.text.y=element_blank()) +
            labs(x=name, 
                 y="relative proportion of racial group", 
                 title=name,
                 color="race", fill="race")
      ggsave(paste0("output/charts/exposure_histograms/", var, ".png"), p, width=8, height=6)
      ggsave(paste0("output/charts/exposure_histograms/", var, "_log10.png"), p+scale_x_log10(), width=8, height=6)
}


