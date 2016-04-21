# This script distills and organizes the "master county" dataset (which includes every variable from every source dataset), 
# producing a table of data for inclusion in the shiny app. It also scales and combines risk variables to create an overall
# risk index. It exports two copies of each file, one to the shiny app data folder and one to the primary data output folder.

# load input data
master_county_data <- read.csv('output/master_county_data/master_county_data.csv')
#dangerous dropping of NAs
#master_county_data <-na.omit(master_county_data)


#### ENVIRONMENTAL RISK DATA ####

riskdata <- master_county_data[,c('state_fips', 
                                 'county_fips', 
                                 'CensusRace...STNAME',
                                 'CensusRace...CTYNAME',
                                 'land_area',
                                 'hail...total_intensity',
                                 'tornado...total_intensity',
                                 'hurricane...total_intensity',
                                 'wind...total_intensity' 
                                   )]
riskdata$highfirerisk <- master_county_data$Fire_risk_2014...risk_4 + master_county_data$Fire_risk_2014...risk_5

# Rename columns to avoid spaces
colnames(riskdata)[colnames(riskdata)=='CensusRace...STNAME'] <- 'STNAME'
colnames(riskdata)[colnames(riskdata)=='CensusRace...CTYNAME'] <- 'CTYNAME'
colnames(riskdata)[colnames(riskdata)=='hail...total_intensity'] <- 'hail_tot_intensity'
colnames(riskdata)[colnames(riskdata)=='tornado...total_intensity'] <- 'tornado_tot_intensity'
colnames(riskdata)[colnames(riskdata)=='hurricane...total_intensity'] <- 'hurricane_tot_intensity'
colnames(riskdata)[colnames(riskdata)=='wind...total_intensity'] <- 'wind_tot_intensity'

#write.csv(riskdata, 'output/master_county_data/riskraw.csv', row.names=FALSE)


# Standardize all risk variables
#names(risk)
riskdata$hail_scaled <- scale(riskdata$hail_tot_intensity) # default for scale is substract mean, divide by sd
riskdata$tornado_scaled <- scale(riskdata$tornado_tot_intensity)
riskdata$wind_scaled <- scale(riskdata$wind_tot_intensity)
riskdata$hurricane_scaled <- scale(riskdata$hurricane_tot_intensity)
riskdata$fire_scaled <- scale(riskdata$highfirerisk)

# Create cumulative risk index
riskdata$risk_ind_sum <- (riskdata$hail_scaled + riskdata$tornado_scaled + riskdata$wind_scaled + riskdata$fire_scaled)

write.csv(riskdata, 'output/master_county_data/cleanedrisk.csv', row.names = FALSE)
write.csv(riskdata, 'shiny/app1/data/cleanedrisk.csv', row.names = FALSE)






#### SOCIOECONOMIC DATA ####

socialdata<- master_county_data[,c('state_fips', 
                                 'county_fips', 
                                 'CensusRace...STNAME',
                                 'CensusRace...CTYNAME',
                                 'land_area',
                                 'natural_amenities...Scale',
                                 'CensusRace...TOT_POP',
                                 'CensusRace...H',
                                 'poverty_2014...PCTPOVALL_2014', 'incomelower48...Dollars',
                                 'unemployed_2014...Unemployment_rate_2014',
                                 'unemployed_2014...Median_Household_Income_2014')]

colnames(socialdata)[colnames(socialdata)=='CensusRace...STNAME'] <- 'STNAME'
colnames(socialdata)[colnames(socialdata)=='CensusRace...CTYNAME'] <- 'CTYNAME'
colnames(socialdata)[colnames(socialdata)=='natural_amenities...Scale'] <- 'Natural_Amenities'
colnames(socialdata)[colnames(socialdata)=='CensusRace...TOT_POP'] <- 'TOTPOP'
colnames(socialdata)[colnames(socialdata)=='CensusRace...H'] <- 'CensusRace_H'
colnames(socialdata)[colnames(socialdata)=='poverty_2014...PCTPOVALL_2014'] <- 'PCTPOVALL_2014'
colnames(socialdata)[colnames(socialdata)=='incomelower48...Dollars'] <- 'Income_Dollars'
colnames(socialdata)[colnames(socialdata)=='unemployed_2014...Unemployed_rate_2014'] <- 'UnemplyRate'
colnames(socialdata)[colnames(socialdata)=='unemployed_2014...Median_Household_Income_2014'] <- 'MedianHouseholdIncome_UE'

socialdata$PercMino<- (master_county_data$CensusRace...TOT_POP - master_county_data$CensusRace...WA)/master_county_data$CensusRace...TOT_POP
socialdata$PercHisp<- master_county_data$CensusRace...H/master_county_data$CensusRace...TOT_POP
socialdata$PercBlk<- master_county_data$CensusRace...BA/master_county_data$CensusRace...TOT_POP
socialdata$PercWh<- master_county_data$CensusRace...WA/master_county_data$CensusRace...TOT_POP
socialdata$PercAs<- master_county_data$CensusRace...AA/master_county_data$CensusRace...TOT_POP
socialdata$PercPIHI<- master_county_data$CensusRace...Na/master_county_data$CensusRace...TOT_POP
socialdata$PercAI<- master_county_data$CensusRace...IA/master_county_data$CensusRace...TOT_POP

write.csv(socialdata, 'output/master_county_data/cleanedsocial.csv', row.names=FALSE)
write.csv(socialdata, 'shiny/app1/data/cleanedsocial.csv', row.names=FALSE)

