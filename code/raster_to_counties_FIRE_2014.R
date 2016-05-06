## THIS SCRIPT CHANGES FIRE DATA FROM RASTER LEVEL TO COUNTY LEVEL

library(raster)
library(rgdal)
library(rgeos)
library(stringr)
library(dplyr)

# load US counties shapefile
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
head(counties@data) 
counties <- crop(counties, extent(-126, -59, 22, 53)) # crop to US48 using lat long, extent creates a box
extent(counties) # shows you boundaries of counties in lat long
counties$area <- gArea(counties, byid=T) # calculate area per county

setwd("raw_data/fire/whp_2014_classified/")
r <- raster("whp2014_cls")

# sync projections
counties <- spTransform(counties, crs(r)) #better to change counties because transforming a grid degrades the data

# the below for loop breaks apart the computation into states to make it manageable
States <- data.frame()
State.names <- unique(counties$STATEFP)
for(i in State.names[1:49]) {
  State <- counties[counties$STATEFP==i,]
  rState <- crop(r, State)
  rState <- as.data.frame(rasterToPoints(rState))
  coordinates(rState) <- c("x", "y")
  crs(rState) <- crs(State)
  o <- over(rState, State)
  d <- o %>%
    mutate(value = rState$whp2014_cls) %>% 
    group_by(GEOID) %>%
    summarize(mean_risk = mean(value),
              max_risk = max(value),
              risk_1 = length(value[value==1])/length(value),
              risk_2 = length(value[value==2])/length(value),
              risk_3 = length(value[value==3])/length(value),
              risk_4 = length(value[value==4])/length(value),
              risk_5 = length(value[value==5])/length(value),
              risk_6 = length(value[value==6])/length(value),
              risk_7 = length(value[value==7])/length(value))
  State@data <- left_join(State@data, d)
  States <- rbind(States, State@data)
}
names(States)[1] <- "state_fips"
names(States)[2] <- "county_fips"
Fire_Risk_by_County <- States
setwd("~/vortex/")
write.csv(Fire_Risk_by_County, "output/tidy_county_data/Fire_risk_2014.csv", row.names=F)