#data obtained from http://www.ers.usda.gov/data-products/county-level-data-sets/download-data.aspx

setwd("vortex")
library(rio)

pov.raw <- import("raw_data/poverty_unemployment/PovertyEstimates.xls")

pov <- pov.raw[-(1:(which(pov.raw[,1]=="FIPStxt")-1)),] #remove the rows above the column names, held comments from original excel file
colnames(pov) <- pov[which(pov[,1]=="FIPStxt"),] #adds rownames
if (which(pov$FIPStxt=="FIPStxt")!=0){pov <- pov[-which(pov$FIPStxt=="FIPStxt"),]} #if the names are still in a row, removes.
pov <- pov[-which(is.na(pov$Rural_urban_Continuum_Code_2003)),] #removes data for just states (leaves only counties)
if (which(names(pov)=="FIPStxt")!=0){names(pov)[which(names(pov)=="FIPStxt")] <- "state_county_fips"} #changes FIPS code column

categories <- c(
  "state_county_fips",
  "POVALL_2014",
  "PCTPOVALL_2014"
)

pov.clean.2014 <- pov[,categories]

write.csv(pov.clean.2014,"output/tidy_county_data/poverty_2014.csv",row.names=F)

