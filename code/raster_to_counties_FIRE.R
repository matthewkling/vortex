

# this script demonstrates how to summarize raster data by county


# set working directory to your local vortex folder
setwd("C:/Users/Carmen/Dropbox (Stephens Lab)/DS421/Project/vortex")


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

setwd("C:/Users/Carmen/Dropbox (Stephens Lab)/DS421/Project")
r <- raster("wfp_2012_classified.txt")

crs(r) #tells you the coordinate reference system 
crs(counties)

# sync projections
counties <- spTransform(counties, crs(r)) #better to change counties because transforming a grid degrades the data
r <- crop(r, counties)

# convert raster to points
r <- as.data.frame(rasterToPoints(r)) # converts raster to points
coordinates(r) <- c("x", "y") # tells it the data frame is spatial coordinates
crs(r) <- crs(counties) # remind it of the projection

# spatial join
o <- over(r, counties) # overlay (in sp package) outputs a data frame with each raster point as a row and all the counties polygon info as columns
d <- o %>% ## %>% is dplyer syntax, > is a pipe that feeds output of one function into the next one
      mutate(value = d$bio1) %>% ## mutate creates or changes variables. In this case, creates column in o that's 
                                  ## the same as variable of interest in d, replace with risk variable
      group_by(GEOID) %>% ## GEOID = identifier for county, = county FIP; groupby makes sub data frames for each county
      summarize(value=mean(value), value2 = length(value[value==2])/length(value)) ## averages by county

# result has a column for GEOID, column for each new variable

counties@data <- left_join(counties@data, d) #combines new county info with original county spatial data frame

# plot a map
variable <- "value" # the variable you want to map
values <- counties@data[,variable]
colors <- colorRampPalette(c("darkblue", "darkmagenta", "red", "yellow"))(100)[cut(values, breaks=100)]
colors[is.na(colors)] <- "darkblue" # what color to use for counties with no data -- set this to NA if you want them to be white
plot(counties, col=colors, axes=F, border=F)

