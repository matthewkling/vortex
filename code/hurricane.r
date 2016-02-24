

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


# load counties shapefile
counties <- readOGR("raw_data/census/us_counties_shapefile", "cb_2014_us_county_500k")
bbox <- extent(-126, -59, 22, 53)
counties <- crop(counties, bbox) # crop to US48
counties$area <- gArea(counties, byid=T) # calculate area per county


# tabulate weather events per county and join to shapefile data
countify <- function(data){
      
      # spatial bookkeeping
      coordinates(data) <- c("deg_east", "deg_north")
      crs(data) <- crs(counties)
      data <- crop(data, bbox)
      
      # calculate events per county
      o <- over(data, counties) %>%
            cbind(data@data) %>%
            group_by(GEOID) %>%
            summarize(n_storms=sum(kt),
                      area=mean(area, na.rm=T))
      
      # join point and polygon datasets
      data <- counties
      data <- tidy(data, region="GEOID")
      data <- left_join(data, o, by=c("id"="GEOID"))
      return(data)
}
s <- countify(d)

# map
make_map <- function(f, weather){
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

make_map(s, "hurricane")
