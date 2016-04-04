
# merge county-level datasets into a single master table
install.packages(c("dplyr", "stringr", "rgdal", "raster", "rgeos"))
library(dplyr)
library(stringr)
library(rgdal)
library(raster)
library(rgeos)

setwd("~/documents/vortex")

# load data
files <- list.files("output/tidy_county_data", full.names=T)
tables <- lapply(files, read.csv, stringsAsFactors=F)

# build a combined state_county_fips variable in all tables that lack it
tables <- lapply(tables, function(x){
      if(!"state_county_fips" %in% names(x)){
            x$state_county_fips <- paste0(str_pad(x$state_fips, 2, "left", 0),
                                          str_pad(x$county_fips, 3, "left", 0))
      }else{
            x$state_county_fips <- str_pad(x$state_county_fips, 5, "left", 0)
      }
      return(x)
})

# add dataset-specific tag to dataset-specific variable names to avoid name conflicts
for(i in 1:length(tables)) names(tables[[i]])[!grepl("_fips", names(tables[[i]]))] <- 
      paste0(gsub(".csv", "", basename(files[i])), "...", names(tables[[i]])[!grepl("_fips", names(tables[[i]]))])

# merge datasets
master <- Reduce(full_join, tables)

# add county area to table
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
counties <- crop(counties, extent(-126, -59, 22, 53)) # crop to US48
counties <- data.frame(state_county_fips=counties$GEOID,
                       land_area=gArea(counties, byid=T))
master <- left_join(master, counties)

# export csv
write.csv(master, "output/master_county_data/master_county_data.csv", row.names=F)