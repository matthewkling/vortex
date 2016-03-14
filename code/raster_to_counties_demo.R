

# this script demonstrates how to summarize raster data by county


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

# load some raster data... using mean temp as an example
d <- getData('worldclim', var='bio', res=5)
d <- d[[1]]

# sync projections
counties <- spTransform(counties, crs(d))
d <- crop(d, counties)

# convert raster to points
d <- as.data.frame(rasterToPoints(d))
coordinates(d) <- c("x", "y")
crs(d) <- crs(counties)

# spatial join
o <- over(d, counties)
d <- o %>%
      mutate(value = d$bio1) %>%
      group_by(GEOID) %>%
      summarize(value=mean(value))
counties@data <- left_join(counties@data, d)

# plot a map
variable <- "value" # the variable you want to map
values <- counties@data[,variable]
colors <- colorRampPalette(c("darkblue", "darkmagenta", "red", "yellow"))(100)[cut(values, breaks=100)]
colors[is.na(colors)] <- "darkblue" # what color to use for counties with no data -- set this to NA if you want them to be white
plot(counties, col=colors, axes=F, border=F)

