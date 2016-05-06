#data obtained from http://www.ers.usda.gov/dataFiles/CountyLevelDatasets/Unemployment.xls

#setwd("vortex") #code will not run appropriately from another directory
library(rio)

med.in.raw <- import("raw_data/poverty_unemployment_med_income/Unemployment.xls")

med.in <- med.in.raw[-(1:(which(med.in.raw[,1]=="FIPS_Code")-1)),] #remove the rows above the column names, held comments from original excel file
colnames(med.in) <- med.in[which(med.in[,1]=="FIPS_Code"),] #adds colnames
if (which(med.in$FIPS_Code=="FIPS_Code")!=0){med.in <- med.in[-which(med.in$FIPS_Code=="FIPS_Code"),]} #if the names are still in a row, removes.
med.in <- med.in[-which(is.na(med.in$Rural_urban_continuum_code_2003)),] #removes data for just states and misc census areas (leaves only counties)
if (which(names(med.in)=="FIPS_Code")!=0){names(med.in)[which(names(med.in)=="FIPS_Code")] <- "state_county_fips"} #changes FIPS code column

#to match Valeri's original format, removing Hawai'i and Alaska data to leave lower 48 and changing column name
med.in.low48 <- med.in[-which(med.in$State=="AK"|med.in$State=="HI"|med.in$State=="PR"),]

#selecting desired data
categories <- c(
  "state_county_fips",
  "Median_Household_Income_2014"
)

categories <- c(
  "state_county_fips",
  "Median_Household_Income_2014"
)

#to match Valeri's original format, changing Median_Household_Income_2014 to DOllars

med.in.low48 <- med.in.low48[,categories]
names(med.in.low48)[which(names(med.in.low48)=="Median_Household_Income_2014")] <- "Dollars"
med.in.clean.2014 <- med.in.low48
  
write.csv(med.in.clean.2014,"output/tidy_county_data/incomelower48.csv",row.names=F) #writes out cleaned data; preserved original cleaned file and columns name
