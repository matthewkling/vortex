setwd("C:/Users/Carmen/Desktop/vortex/output/master_county_data")
clean <- read.csv("cleanedcounty.csv", header = TRUE)
master <- read.csv("master_county_data.csv", header = TRUE)
names(clean)
hist(clean$PercUnempl)

rm(master)

