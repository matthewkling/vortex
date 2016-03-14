
#problem with this is that it's only 2008-2012

library(acs)
library(sqldf)
library(ggplot2)
library(maps)
library(tigris)
library(stringr) # to pad fips codes

api.key.install(key="550e70d4fc2a461f97ea0a5f1cac71ec2bf3c213")


#states = geo.make(state="*")

# load the boundary data for all counties
county.df=map_data("county")
# rename fields for later merge
names(county.df)[5:6]=c("state","county")
state.df=map_data("state")
# wow! a single geo.set to hold all the counties...?
us.county=geo.make(state="*", county="*")


income<-acs.fetch(endyear = 2012, span = 5, geography = us.county,
                  table.number = "B19001", col.names = "pretty")
acs.lookup(keyword="race")
# 
# 17    C02003_002       C02003              Detailed Race
# 18    C02003_003       C02003              Detailed Race
# 19    C02003_004       C02003              Detailed Race
# 20    C02003_005       C02003              Detailed Race
# 21    C02003_006       C02003              Detailed Race

race<- acs.fetch(endyear = 2012, span = 5, geography = us.county,
                  table.number = "C02003", col.names = "pretty")


income_df <- data.frame(paste0(str_pad(income@geography$state, 2, "left", pad="0"), 
                               str_pad(income@geography$county, 3, "left", pad="0")),
                               income@estimate[,c("Household Income: Total:",
                                           "Household Income: $200,000 or more")], 
                        stringsAsFactors = FALSE)

rownames(income_df)<-1:nrow(income_df)
names(income_df)<-c("GEOID", "total", "over_200")
income_df$percent <- 100*(income_df$over_200/income_df$total)

#tigris
counties <- c(5, 47, 61, 81, 85)


income_merged<- geo_join(county.df, income_df, "GEOID", "GEOID")
# there are some tracts with no land that we should exclude
income_merged <- income_merged[income_merged$ALAND>0,]



race_df <- data.frame(paste0(str_pad(race@geography$state, 2, "left", pad="0"), 
                             str_pad(race@geography$county, 3, "left", pad="0")),
                      race@estimate[,c("Detailed Race: Total:",
                                         "Detailed Race: Population of one race: White", "Detailed Race: Population of one race: Black or African American")], stringsAsFactors = FALSE)
