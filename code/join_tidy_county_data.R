
# merge county-level datasets into a single master table

library(dplyr)

setwd("~/documents/vortex")

# load data
files <- list.files("output/tidy_county_data", full.names=T)
tables <- lapply(files, read.csv, stringsAsFactors=F)

# build a combined state_county_fips variable in all tables that lack it
tables <- lapply(tables, function(x){
      if(!"state_county_fips" %in% names(x)){
            x$state_county_fips <- paste0(str_pad(x$state_fips, 2, "left", 0),
                                          str_pad(x$county_fips, 3, "left", 0))
      }
      return(x)
})

# add dataset-specific tag to dataset-specific variable names to avoid name conflicts
for(i in 1:length(tables)) names(tables[[i]])[!grepl("_fips", names(tables[[i]]))] <- 
      paste0(gsub(".csv", "", basename(files[i])), "...", names(tables[[i]])[!grepl("_fips", names(tables[[i]]))])

# merge datasets
master <- Reduce(full_join, tables)

