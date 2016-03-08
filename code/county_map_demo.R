

# this script demonstrates how to make a quick map of any county-wise data


# set working directory to your local vortex folder
setwd("~/documents/vortex")

library(raster)
library(rgdal)
library(rgeos)
library(stringr)
library(dplyr)

# load US counties shapefile
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
counties <- crop(counties, extent(-126, -59, 22, 53)) # crop to US48
counties$area <- gArea(counties, byid=T) # calculate area per county

# load csv of county data, and pad the fips codes with zeroes so they match the expected format
d <- read.csv("output/tidy_county_data/tornado.csv", stringsAsFactors=F)
d$state_fips <- str_pad(d$state_fips, 2, "left", 0) 
d$county_fips <- str_pad(d$county_fips, 3, "left", 0)

# add the county data to the county shapefile
counties@data <- left_join(counties@data, d, 
                           by=c("STATEFP"="state_fips", # the second argument here should be the name of your state fips variable
                                "COUNTYFP"="county_fips")) # same for county

# plot a map
variable <- "n_storms" # the variable you want to map
values <- counties@data[,variable]
values <- log(values) # i'm using a log transformation here due to the tornado frequency distribution
colors <- colorRampPalette(c("darkblue", "darkmagenta", "red", "yellow"))(100)[cut(values, breaks=100)]
colors[is.na(colors)] <- "darkblue" # what color to use for counties with no data -- set this to NA if you want them to be white
plot(counties, col=colors, axes=F, border=F)

