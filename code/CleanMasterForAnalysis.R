master_county_data <- read.csv("~/vortex/output/master_county_data/master_county_data.csv")
View(master_county_data)


countydata<- master_county_data[,c("state_fips", 
                                   "county_fips", 
                                   "CensusRace...STNAME",
                                   "CensusRace...CTYNAME",
                                   "land_area",
                                   "CensusRace...TOT_POP",
                                   "CensusRace...H",
                                   "poverty_pct_2014...PCTPOVALL_2014",
                                   "hail...total_intensity",
                                   "tornado...total_intensity",
                                   "wind...total_intensity", 
                                   "natural_amenities...Scale"
                                   )]
countydata$highfirerisk<- master_county_data$Fire_risk_2012...risk_4+master_county_data$Fire_risk_2012...risk_5
countydata$PercUnempl<- as.numeric(master_county_data$unemployed_2014...Unemployed_2014)/master_county_data$CensusRace...TOT_POP
countydata$PercMino<- (master_county_data$CensusRace...TOT_POP - master_county_data$CensusRace...WA)/master_county_data$CensusRace...TOT_POP


## temporary fix of NAs##
countydata<- countydata[1:3142,]

write.csv(countydata, "~/vortex/output/master_county_data/cleanedcounty.csv")

