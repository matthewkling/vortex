#data obtained from http://www.ers.usda.gov/data-products/county-level-data-sets/download-data.aspx

setwd("vortex")
library(rio)

pov <- import("C:/Users/Laura A/Downloads/PovertyEstimates.xls")

write.csv(pov,"C:/Users/Laura A/Downloads/pov_attempt.csv",row.names=F)
  