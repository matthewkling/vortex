# This script converts the raw downloaded hurricane data into tidy county format,
# first performing some spatial interpolation and deriving an exposure index.
# Input: raw NOAA hurricane data, hurdat2-1851-2015-021716.txt
# Output: tidy county-wise hurricane exposure, hurricane.csv
# Author: Matthew Kling

library(data.table)
library(dplyr)
library(tidyr)
library(stringr)
library(raster)
library(rgeos)
library(rgdal)
library(broom)
library(maptools)
library(ggplot2)
library(viridis)

# read text file line-wise
d <- readLines("raw_data/hurricane/hurdat2-1851-2015-021716.txt")

# transform raw hurricane data into an R-readable csv format
commas <- c()
for(i in 1:length(d)){
      if(length(gregexpr(",", d[i])[[1]]) == 3){ # lines with only 3 commas are storm headers
            id <- paste0(substr(d[i], 1,8), ", ") # get the sorm id tag
            commas <- c(commas, i)
            next()
      }
      d[i] <- paste0(id, d[i]) # add the tag to every entry for that storm
}
d <- d[setdiff(1:length(d), commas)] # remove the storm header lines
writeLines(d, "raw_data/hurricane/hurricanes_tabular.csv") # save intermediate file

# clean up tabular data
d <- fread("raw_data/hurricane/hurricanes_tabular.csv", header=F) %>%
      mutate(id=V1,
             date=V2,
             time=str_pad(V3, 4, "left", 0),
             lat=as.numeric(substr(V6,1,4)), lat_dir=substr(V6, 5,5),
             lon=as.numeric(substr(V7,1,4)) * -1, lon_dir=substr(V7, 5,5),
             windspeed=as.numeric(V8)) %>%
      filter(lat_dir=="N", lon_dir=="W") %>%
      dplyr::select(id:windspeed)%>%
      filter(windspeed > 0) %>%
      mutate(datetime = as.POSIXct(paste(date, time), format="%Y%m%d %H")) %>%
      arrange(datetime)

# load counties shapefile
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
bbox <- extent(-126, -59, 22, 53)
counties <- crop(counties, bbox) # crop to US48
counties$area <- gArea(counties, byid=T) # calculate area per county

# crop to buffer around US extent, to avoid unnecessary computation
e <- extent(counties) * 1.1
coordinates(d) <- c("lon", "lat")
d <- crop(d, e)
d <- as.data.frame(d)

# interpolation -- linear interpolation of coordinates and windspeeds at hourly timesteps
ds <- split(d, d$id)
ds <- lapply(ds, function(x){
      writeLines(as.character(x$id[1]))
      dd <- data.frame()
      if(nrow(x)<2) return(x)
      for(i in 2:nrow(x)){
            di <- x[(i-1):i,]
            if(di$id[1]!=di$id[2]) next()
            tdiff <- as.integer(difftime(x$datetime[2], x$datetime[1], units="hours"))
            dd <- rbind(dd, di[1,])
            for(h in 1:(tdiff-1)){
                  new <- di[1,]
                  weights <- c(tdiff-h, h)
                  weights <- weights / sum(weights)
                  new$datetime <- new$datetime + 3600 * h
                  new$lat <- weighted.mean(di$lat, weights)
                  new$lon <- weighted.mean(di$lon, weights)
                  new$windspeed <- weighted.mean(di$windspeed, weights)
                  dd <- rbind(dd, new)
            }
      }
      return(dd)
})
d <- do.call("rbind", ds)

# crop to us extent
coordinates(d) <- c("lon", "lat")
crs(d) <- crs(counties)
d <- crop(d, extent(counties))

# tabulate weather events per county and join to shapefile data
s <- data %>% 
            over(counties) %>%
            cbind(data@data) %>%
            group_by(GEOID) %>%
            summarize(n_storms=n(),
                      total_intensity=sum(windspeed^3),
                      intensity_per_area=total_intensity/sum(area)) %>%
            left_join(counties@data, .) %>%
            mutate(state_fips=STATEFP, county_fips=COUNTYFP) %>%
            dplyr::select(n_storms:county_fips)

# fill NA values with minimum valid value
na2min <- function(x){
      x[is.na(x) | x<0] <- min(na.omit(x[x>=0]))
      return(x)
}
s$total_intensity <- na2min(s$total_intensity)
s$intensity_per_area <- na2min(s$intensity_per_area)

# export final tidy data
write.csv(s, "output/tidy_county_data/hurricane.csv", row.names=F)


