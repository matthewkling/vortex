setwd("C:/Users/Carmen/Desktop/vortex/output/master_county_data")

risk <- read.csv("cleanedrisk.csv")
social <- read.csv("cleanedsocial.csv")

# Standardize all risk variables
names(risk)
risk$hail_scaled <- scale(risk$hail_tot_intensity) # default for scale is substract mean, divide by sd
risk$tornado_scaled <- scale(risk$tornado_tot_intensity)
risk$wind_scaled <- scale(risk$wind_tot_intensity)
risk$fire_scaled <- scale(risk$highfirerisk)

# Create cumulative risk index
risk$risk_ind_sum <- (risk$hail_scaled + risk$tornado_scaled + risk$wind_scaled + risk$fire_scaled)

write.csv(risk, "scaledrisk.csv", row.names = FALSE)
trial <- read.csv("scaledrisk.csv")
