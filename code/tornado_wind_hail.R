# This script converts the raw downloaded tornado/hail/wind data into tidy county format.
# Input: raw NOAA storms data (all csv files in the "raw_data/tornado_wind_hail" folder),
          # and US counties shapefile
# Output: tidy county-wise exposure tables: tornado.csv, hail.csv, wind.csv
# Author: Matthew Kling


# libraries
library(dplyr)
library(rgdal)
library(raster)
library(rgeos)
library(ggplot2)
library(broom)
library(maptools)
library(viridis)



####### functions #######

# function to load storms data
# metadata is at http://www.spc.noaa.gov/wcm/data/SPC_severe_database_description.pdf
# column names are common to all weather types, but wind has an extra variable
load_data <- function(path){
      d <- read.csv(path, header=F, stringsAsFactors=F)
      varnames <- c("id", "year", "month", "day", "date", "time", "time_zone",
                    "state", "state_fips", "state_code", "intensity",
                    "injuries", "fatalities", "loss", "crop_loss", 
                    "slat", "slon", "elat", "elon", "length", "width",
                    "num_states", "state_num", "segment",
                    paste0("county_fips_", 1:4))
      if(grepl("wind", basename(path))) varnames <- c(varnames, "mag_type") 
      names(d) <- varnames
      return(d)
}


# function to tabulate weather events per county
countify <- function(data){
      require(stringr)
      data <- data %>%
            mutate(state_fips = str_pad(state_fips, 2, "left", "0"),
                   county_fips = str_pad(county_fips_1, 3, "left", "0")) %>%
            group_by(state_fips, county_fips) %>%
            dplyr::summarize(n_storms=n(),
                      total_intensity=sum(intensity)) 
      data<- filter(data, county_fips != "000")  #removing aggregate state and country rows
      return(data)
}

# function to fill NA values with minimum valid value
na2min <- function(x){
      x$n_storms[is.na(x$n_storms)] <- 0
      x$total_intensity[is.na(x$total_intensity) | x$total_intensity<0] <- min(na.omit(x$total_intensity[x$total_intensity>=0]))
      return(x)
}

# function to make shapefile from county data table
geojoin <- function(data, shapefile){
      #shapefile@data <- mutate_each(shapefile@data, funs(as.integer), STATEFP, COUNTYFP)
      shapefile@data <- left_join(shapefile@data, data, by=c("STATEFP"="state_fips", "COUNTYFP"="county_fips"))
      return(shapefile)
}


# function to save some simple maps
make_map <- function(weather){
      f <- d[[weather]]
      s <- tidy(f, region="GEOID")
      s <- left_join(s, f@data, by=c("id"="GEOID"))
      
      png(paste0("output/charts/", weather, "_frequency_map.png"), width=3000, height=2000)
      p <- ggplot(s, aes(long, lat, fill=n_storms/area, group=group, order=order)) + 
            geom_polygon(color=NA) +
            scale_fill_viridis(option="A", na.value="black",
                                        trans="log10", breaks=10^(0:10)) +
            theme(panel.background=element_blank(), panel.grid=element_blank(),
                  axis.text=element_blank(), axis.title=element_blank(), axis.ticks=element_blank(),
                  legend.position="top", text=element_text(size=40)) +
            coord_map("stereographic") +
            guides(fill=guide_colourbar(barwidth=50, barheight=3)) +
            labs(fill=paste(weather, "events per unit area  "))
      plot(p)
      dev.off()
}


######## data setup #########

# load US counties shapefile
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
counties <- crop(counties, extent(-126, -59, 22, 53)) # crop to US48
counties$area <- gArea(counties, byid=T) # calculate area per county

# load weather event data
files <- list.files("raw_data/tornado_wind_hail", pattern="\\.csv", full.names=T)
names(files) <- c("tornado", "hail", "wind")



####### processing ##########

d <- lapply(files, load_data)
d <- lapply(d, countify)
d <- lapply(d, na2min)
for(w in names(d)) write.csv(d[[w]], paste0("output/tidy_county_data/", w, ".csv"), row.names=F)

#d <- lapply(d, geojoin, shapefile=counties)
#lapply(names(d), make_map)

