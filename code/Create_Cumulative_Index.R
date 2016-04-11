setwd("C:/Users/Carmen/Desktop/vortex/output/master_county_data")
risk <- read.csv("cleanedrisk.csv", header = TRUE)
names(risk)

# Look at data before log transforming or standardizing
grid <- par(mfrow=c(2, 2))
hist(risk$highfirerisk, breaks = 20)
hist(risk$wind_tot_intensity, breaks = 20)
hist(risk$tornado_tot_intensity, breaks = 20)
hist(risk$hail_tot_intensity, breaks = 20)
par(grid)

# Log transform the least normal risk variables, fire and hail, and standardize
hist(log(risk$highfirerisk+0.000001))

grid <- par(mfrow=c(2, 2))
hist(risk$fire_scaled, breaks = 20) 
hist(risk$wind_scaled, breaks = 20)
hist(risk$tornado_scaled, breaks = 20)
hist(risk$hail_scaled, breaks = 20)
par(grid)

# Log transform fire and hail:

grid <- par(mfrow=c(2, 2))
hist(log(risk$fire_scaled + 0.1), breaks = 20)
hist(risk$wind_scaled, breaks = 20)
hist(risk$tornado_scaled, breaks = 20)
hist(log(risk$hail_scaled + 0.1), breaks = 20)
par(grid)


# Standardize all risk variables
names(risk)
risk$hail_scaled <- scale(risk$hail_tot_intensity) # default for scale is substract mean, divide by sd
risk$tornado_scaled <- scale(risk$tornado_tot_intensity)
risk$wind_scaled <- scale(risk$wind_tot_intensity)
risk$fire_scaled <- scale(risk$highfirerisk)

# Create cumulative risk index
risk$risk_ind_sum <- (risk$hail_scaled + risk$tornado_scaled + risk$wind_scaled + risk$fire_scaled)

write.csv(risk, "cleanedrisk.csv", row.names = FALSE)

