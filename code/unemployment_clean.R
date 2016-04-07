#data obtained from http://www.ers.usda.gov/data-products/county-level-data-sets/download-data.aspx

setwd("vortex")
library(rio)

pov.raw <- import("raw_data/poverty_unemployment/Unemployment.xls")

pov <- pov.raw[-(1:(which(pov.raw[,1]=="FIPS_Code")-1)),] #remove the rows above the column names, held comments from original excel file
colnames(pov) <- pov[which(pov[,1]=="FIPS_Code"),] #adds rownames
if (which(pov$FIPS_Code=="FIPS_Code")!=0){pov <- pov[-which(pov$FIPS_Code=="FIPS_Code"),]} #if the names are still in a row, removes.
pov <- pov[-is.na(pov$Rural_urban_continuum_code_2003),] #removes data for just states (leaves only counties)
if (which(names(pov)=="FIPS_Code")!=0){names(pov)[which(names(pov)=="FIPS_Code")] <- "state_county_fips"} #changes FIPS code column

categories <- c(
  "state_county_fips",
  "Unemployed_2014",
  "Unemployment_rate_2014",
  "Median_Household_Income_2014"
)

pov.clean.2014 <- pov[,categories]

write.csv(pov.clean.2014,"output/tidy_county_data/unemployed_2014.csv",row.names=F)

