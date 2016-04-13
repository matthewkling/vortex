# Distill raw hurricane data into county-level exposure. 

# Inputs: Allstorms.ibtracs_wmo.v03r08.csv (sourced from http://go.usa.gov/cywdG on 2/22/2016 using an all-inclusive search)
# Outputs: 
# Author: Matthew Kling



library(dplyr)
library(tidyr)
library(data.table)
library(raster)
library(rgdal)
library(rgeos)
library(broom)
library(maptools)
library(ggplot2)
library(viridis)

if(user=="Matt") setwd("~/documents/vortex")

# load hurricane data
d <- fread("raw_data/hurricane/Allstorms.ibtracs_wmo.v03r08.csv", skip=2)

# clean
names(d) <- sub("YYYY-MM-DD HH:MM:SS", "timestamp", names(d))
names(d) <- sub("#", "storm_number", names(d))
names(d)[1] <- "serial_number"
d <- d %>%
      filter(kt > 0) %>%
      mutate(datetime = as.POSIXct(timestamp, format="%Y-%m-%d %H:%M:%S")) %>%
      arrange(datetime)


# load counties shapefile
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
bbox <- extent(-126, -59, 22, 53)
counties <- crop(counties, bbox) # crop to US48
counties$area <- gArea(counties, byid=T) # calculate area per county


# crop to USA
coordinates(d) <- c("deg_east", "deg_north")
crs(d) <- crs(counties)
d <- crop(d, bbox)
d <- as.data.frame(d)

# interpolation
dd <- data.frame()
for(i in 2:nrow(d)){
      writeLines(as.character(i))
      di <- d[(i-1):i,]
      if(di$serial_number[1]!=di$serial_number[2]) next()
      tdiff <- as.integer(difftime(d$datetime[2], d$datetime[1], units="hours"))
      
      dd <- rbind(dd, di[1,])
      for(h in 1:(tdiff-1)){
            new <- di[1,]
            weights <- c(tdiff-h, h)
            weights <- weights / sum(weights)
            new$datetime <- new$datetime + 3600 * h
            new$deg_north <- weighted.mean(di$deg_north, weights)
            new$deg_east <- weighted.mean(di$deg_east, weights)
            new$kt <- weighted.mean(di$kt, weights)
            dd <- rbind(dd, new)
      }
      dd <- rbind(dd, di[2,])
}
dd <- distinct(dd)
stop("woo")







# tabulate weather events per county and join to shapefile data
countify <- function(data){
      
      # spatial bookkeeping
      coordinates(data) <- c("deg_east", "deg_north")
      crs(data) <- crs(counties)
      data <- crop(data, bbox)
      
      # sumamrize events per county
      o <- over(data, counties) %>%
            cbind(data@data) %>%
            group_by(GEOID) %>%
            summarize(n_storms=n(),
                      total_intensity=sum(kt^3))
      
      # join point and polygon datasets
      data <- counties
      data <- tidy(data, region="GEOID")
      data <- left_join(data, o, by=c("id"="GEOID"))
      return(data)
}


# map
make_map <- function(f, weather){
      png(paste0("output/charts/", weather, "_frequency_map.png"), width=3000, height=2000)
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


s <- countify(d)
write.csv(s, "output/tidy_county_data/hurricane.csv", row.names=F)
make_map(s, "hurricane")
