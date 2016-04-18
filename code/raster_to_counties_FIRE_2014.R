## THIS DIRECTORY CHANGES FIRE DATA FROM RASTER TO COUNTY SUMMARIES

library(raster)
library(rgdal)
library(rgeos)
library(stringr)
library(dplyr)

# load US counties shapefile
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
# @data is just like a data frame
head(counties@data) #like opening an attribute table, but doesn't have coordinates
counties <- crop(counties, extent(-126, -59, 22, 53)) # crop to US48 using lat long, extent creates a box
extent(counties) # shows you boundaries of counties in lat long
counties$area <- gArea(counties, byid=T) # calculate area per county

# THIS FILE PATH IS NOT WITHIN VORTEX BECAUSE UNZIPPING THIS LARGE OF A FILE WITHIN VORTEX CRASHES GIT
setwd("C:/Users/Carmen/Desktop/whp_2014_classified/")
r <- raster("whp2014_cls")

# sync projections
counties <- spTransform(counties, crs(r)) #better to change counties because transforming a grid degrades the data
#r <- crop(r, counties) # time consuming and unnecessary 

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
Fire_Risk_by_County_2014 <- States
setwd("~/vortex/")
write.csv(Fire_Risk_by_County_2014, "output/tidy_county_data/Fire_risk_2012.csv", row.names=F)

# plot a map
#values <- "States$mean_risk" # the variable you want to map
#values <- counties@data[,variable]
#colors <- colorRampPalette(c("darkblue", "darkmagenta", "red", "yellow"))(100)[cut(values, breaks=100)]
#colors[is.na(colors)] <- "darkblue" # what color to use for counties with no data -- set this to NA if you want them to be white
#plot(counties, col=colors, axes=F, border=F)