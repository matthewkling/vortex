setwd("../output/master_county_data")
master_county_data <- read.csv("master_county_data.csv")
View(master_county_data)


riskdata<- master_county_data[,c("state_fips", 
                                 "county_fips", 
                                 "CensusRace...STNAME",
                                 "CensusRace...CTYNAME",
                                 "land_area",
                                 "hail...total_intensity",
                                 "tornado...total_intensity",
                                 "wind...total_intensity" 
                                   )]
riskdata$highfirerisk<- master_county_data$Fire_risk_2012...risk_4+master_county_data$Fire_risk_2012...risk_5

# Rename columns to avoid spaces
colnames(riskdata)[colnames(riskdata)=="CensusRace...STNAME"] <- "STNAME"
colnames(riskdata)[colnames(riskdata)=="CensusRace...CTYNAME"] <- "CTYNAME"
colnames(riskdata)[colnames(riskdata)=="hail...total_intensity"] <- "hail_tot_intensity"
colnames(riskdata)[colnames(riskdata)=="tornado...total_intensity"] <- "tornado_tot_intensity"
colnames(riskdata)[colnames(riskdata)=="wind...total_intensity"] <- "wind_tot_intensity"

socialdata<- master_county_data[,c("state_fips", 
                                 "county_fips", 
                                 "CensusRace...STNAME",
                                 "CensusRace...CTYNAME",
                                 "land_area",
                                 "natural_amenities...Scale",
                                 "CensusRace...TOT_POP",
                                 "CensusRace...H",
                                 "poverty_pct_2014...PCTPOVALL_2014", "incomelower48...Dollars",
                                 "unemployed_2014...Unemployed_2014")]

colnames(socialdata)[colnames(socialdata)=="CensusRace...STNAME"] <- "STNAME"
colnames(socialdata)[colnames(socialdata)=="CensusRace...CTYNAME"] <- "CTYNAME"
colnames(socialdata)[colnames(socialdata)=="natural_amenities...Scale"] <- "Natural_Amenities"
colnames(socialdata)[colnames(socialdata)=="CensusRace...TOT_POP"] <- "TOTPOP"
colnames(socialdata)[colnames(socialdata)=="CensusRace...H"] <- "CensusRace_H"
colnames(socialdata)[colnames(socialdata)=="poverty_pct_2014...PCTPOVALL_2014"] <- "PCTPOVALL_2014"
colnames(socialdata)[colnames(socialdata)=="incomelower48...Dollars"] <- "Income_Dollars"
colnames(socialdata)[colnames(socialdata)=="unemployed_2014...Unemployed_2014"] <- "NumbUnemply"


socialdata$PercMino<- (master_county_data$CensusRace...TOT_POP - master_county_data$CensusRace...WA)/master_county_data$CensusRace...TOT_POP
socialdata$PercHisp<- master_county_data$CensusRace...H/master_county_data$CensusRace...TOT_POP
socialdata$PercBlk<- master_county_data$CensusRace...BA/master_county_data$CensusRace...TOT_POP
socialdata$PercWh<- master_county_data$CensusRace...WA/master_county_data$CensusRace...TOT_POP
socialdata$PercAs<- master_county_data$CensusRace...AA/master_county_data$CensusRace...TOT_POP
socialdata$PercPIHI<- master_county_data$CensusRace...Na/master_county_data$CensusRace...TOT_POP
socialdata$PercAI<- master_county_data$CensusRace...IA/master_county_data$CensusRace...TOT_POP



## temporary fix of NAs##
#countydata<- countydata[1:3142,]

write.csv(riskdata, "cleanedrisk.csv")
write.csv(socialdata, "cleanedsocial.csv" )
View(socialdata)
