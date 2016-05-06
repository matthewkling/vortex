

library(dplyr)
library(tidyr)
library(ggplot2)
select <- dplyr::select

setwd("~/documents/vortex")

# open master data table
f <- read.csv("output/master_county_data/master_county_data.csv")


###### race ######

# split data into race and non-race frames
race <- f[,grepl("Census|_fips", names(f))]
names(race) <- sub("CensusRace...", "", names(race))
d <- f[,!grepl("Census", names(f))]

# variables to visualize
variables <- names(d)[grepl("\\.\\.\\.", names(d))]
variables <- variables[!grepl("Fire_risk", variables) | grepl("\\.risk_", variables)] # drop fire metadata variables

# generate an exposure-by-race density plot for all variables
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
      ggsave(paste0("output/charts/race_histograms/", var, ".png"), p, width=8, height=6)
      
      # log scale
      ggsave(paste0("output/charts/race_histograms/", var, "_log10.png"), p+scale_x_log10(), width=8, height=6)
}




##### poverty #####

d <- f

variables <- names(d)[grepl("\\.\\.\\.", names(d))]
variables <- variables[!grepl("poverty_pct", variables)]
variables <- variables[!grepl("Fire_risk", variables) | grepl("\\.risk_", variables)] # drop fire metadata variables
variables <- variables[!grepl("CensusRace", variables)]

pov <- select(d, poverty_pct_2014...PCTPOVALL_2014, CensusRace...TOT_POP)
names(pov) <- c("pov", "pop")

# generate an exposure-by-race density plot for all variables
for(var in variables){
      v <- d[,var]
      if(class(v)=="factor") v <- as.character(v)
      v <- as.numeric(v)
      v <- cbind(pov, v)
      
      name <- sub("\\.\\.\\.", ": ", var)
      colors <- c("darkgoldenrod1", "black", "red", "forestgreen", "dodgerblue")
      
      p <- ggplot(v, aes(pov, v, weight=pop, alpha=pop)) +
            geom_smooth(method=lm, color="darkred", fill="darkred") +
            geom_point()+
            theme_minimal() +
            scale_alpha(trans="log10", range=c(0,1), breaks=10^c(0:10)) +
            labs(y=name, 
                 x="percent below poverty line", 
                 title=name,
                 alpha="population")
      ggsave(paste0("output/charts/poverty_scatterplots/", var, ".png"), p, width=8, height=6)
      
      # log scale
      ggsave(paste0("output/charts/poverty_scatterplots/", var, "_log10.png"), 
             p + scale_y_log10(),
             width=8, height=6)
}

