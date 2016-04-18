#data obtained from http://www.ers.usda.gov/dataFiles/CountyLevelDatasets/Unemployment.xls

#setwd("vortex") #code will not run appropriately from another directory
library(rio)

unem.raw <- import("raw_data/poverty_unemployment_med_income/Unemployment.xls")

unem <- unem.raw[-(1:(which(unem.raw[,1]=="FIPS_Code")-1)),] #remove the rows above the column names, held comments from original excel file
colnames(unem) <- unem[which(unem[,1]=="FIPS_Code"),] #adds rownames
if (which(unem$FIPS_Code=="FIPS_Code")!=0){unem <- unem[-which(unem$FIPS_Code=="FIPS_Code"),]} #if the names are still in a row, removes.
unem <- unem[-which(is.na(unem$Rural_urban_continuum_code_2003)),] #removes data for just states (leaves only counties)
if (which(names(unem)=="FIPS_Code")!=0){names(unem)[which(names(unem)=="FIPS_Code")] <- "state_county_fips"} #changes FIPS code column

#selecting desired data
categories <- c(
  "state_county_fips",
  "Unemployed_2014",
  "Unemployment_rate_2014",
  "Median_Household_Income_2014"
)

unem.clean.2014 <- unem[,categories]

write.csv(unem.clean.2014,"output/tidy_county_data/unemployed_2014.csv",row.names=F) #writes out cleaned data
