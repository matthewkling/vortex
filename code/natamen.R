#data obtained from http://www.ers.usda.gov/datafiles/Natural_Amenities_Scale/natamenf_1_.xls


#setwd("vortex") #code will not run appropriately from another directory
library(data.table)
library(rio)
library(xlsx)

download.file("http://www.ers.usda.gov/datafiles/Natural_Amenities_Scale/natamenf_1_.xls","raw_data/natural_amenities/natamenf.xls",method="curl")
nat.raw <- read.xlsx("raw_data/natural_amenities/natamenf.xls",1)
write.csv(nat.raw,"raw_data/natural_amenities/natamenf.csv", row.names = F)

natamen <- read.csv("raw_data/natural_amenities/natamenf.csv", skip=83) #removes comments and descriptions from the beginning of the data
names(natamen)[1] <- "state_county_fips" #changes column name
write.csv(natamen,"raw_data/natural_amenities/natamenf_fips.csv")

natamen_raw <- read.csv(("raw_data/natural_amenities/natamenf_fips.csv"));natamen_raw <- natamen_raw[,-1]

natamen.clean <- subset(natamen_raw,select=c(state_county_fips,Scale))

write.csv(natamen.clean,"output/tidy_county_data/natural_amenities.csv",row.names = F)

