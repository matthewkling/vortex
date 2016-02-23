
# user-specific file paths -- each person should replicate for their machine, and define the user variable in the console before running
if(user=="Matt") setwd("~/documents/vortex")
if(user=="Your name") setwd("path to your local git directory")


# libraries
library(dplyr)
library(rgdal)
library(raster)
library(rgeos)
library(ggplot2)
library(broom)
library(maptools)
library(viridis)


############ load storms data ##############
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

files <- list.files("raw_data/census/tornado_wind_hail", pattern="\\.csv", full.names=T)
d <- lapply(files, load_data)
names(d) <- c("tornado", "hail", "wind")


############ load US counties shapefile ############
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
counties <- crop(counties, extent(-126, -59, 22, 53)) # crop to US48
counties$area <- gArea(counties, byid=T) # calculate area per county


############ tabulate weather events per county and join to shapefile data ############
countify <- function(data){
      
      # spatial bookkeeping
      coordinates(data) <- c("slon", "slat")
      crs(data) <- crs(counties)
      
      # calculate events per county
      o <- over(data, counties) %>% # actually this spatially explicit query isn't strictly necessary, could just join on fips. that would be the approach for crop damage etc
            group_by(GEOID) %>%
            summarize(n_storms=n(),
                      area=mean(area, na.rm=T))
      
      # join point and polygon datasets
      data <- counties
      data <- tidy(data, region="GEOID")
      data <- left_join(data, o, by=c("id"="GEOID"))
      return(data)
}
      
s <- lapply(d, countify) 



############ save some simple maps ###########

make_map <- function(weather){
      f <- s[[weather]]
      png(paste0("output/", weather, "_frequency_map.png"), width=3000, height=2000)
      p <- ggplot(f, aes(long, lat, fill=n_storms/area, group=group, order=order)) + 
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

lapply(names(s), make_map)

