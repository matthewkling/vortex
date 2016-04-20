
# This script .
# Matthew Kling

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

### first, transform raw hurricane data into an R-readable csv format

# read text file line-wise
d <- readLines("raw_data/hurricane/hurdat2-1851-2015-021716.txt")

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

# write csv
writeLines(d, "raw_data/hurricane/hurricanes_tabular.csv")


### 

# open and clean up data
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

# crop to buffer around US extent
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
countify <- function(data){
      
      # spatial bookkeeping
      #coordinates(data) <- c("deg_east", "deg_north")
      #crs(data) <- crs(counties)
      #data <- crop(data, bbox)
      
      # sumamrize events per county
      o <- over(data, counties) %>%
            cbind(data@data) %>%
            group_by(GEOID) %>%
            summarize(n_storms=n(),
                      total_intensity=sum(windspeed^3))
      
      # join point and polygon datasets
      data <- counties
      data <- tidy(data, region="GEOID")
      data <- left_join(data, o, by=c("id"="GEOID"))
      return(data)
}


# map
make_map <- function(f, weather){
      png(paste0("output/charts/", weather, "_frequency_map.png"), width=3000, height=2000)
      p <- ggplot(f, aes(long, lat, fill=total_intensity/area, group=group, order=order)) + 
            geom_polygon(color=NA) +
            scale_fill_viridis(option="A", na.value="black",
                               trans="log10", breaks=10^(0:10)) +
            theme(panel.background=element_blank(), panel.grid=element_blank(),
                  axis.text=element_blank(), axis.title=element_blank(), axis.ticks=element_blank(),
                  legend.position="top", text=element_text(size=40)) +
            coord_map("stereographic") +
            guides(fill=guide_colourbar(barwidth=50, barheight=3)) +
            labs(fill=paste(weather, "intensity per unit area  "))
      plot(p)
      dev.off()
}


s <- countify(d)
write.csv(s, "output/tidy_county_data/hurricane.csv", row.names=F)
make_map(s, "hurricane")


