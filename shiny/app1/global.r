library(dplyr)
library(tidyr)
library(maps)
library(mapproj)
library(stringr)


# load data
ds <- read.csv("data/cleanedsocial.csv", stringsAsFactors=F) %>%
      mutate(fips = as.integer(paste0(state_fips, str_pad(county_fips, 3, "left", 0)))) %>%
      select(-STNAME, -CTYNAME, -state_fips, -county_fips, -land_area)

dr <- read.csv("data/cleanedrisk.csv", stringsAsFactors=F) %>%
      #select(-land_area) %>%
      mutate(state_fips=as.integer(state_fips),
             county_fips=as.integer(county_fips)) %>%
      mutate(fips = as.integer(paste0(state_fips, str_pad(county_fips, 3, "left", 0)))) %>%
      select(-CTYNAME, -state_fips, -county_fips)

# fips-to-name dictionary from maps library;
FIPS <- maps::county.fips
FIPS$polyname <- as.character(FIPS$polyname)
FIPS$polyname[FIPS$polyname=="florida,miami-dade"] <- "florida,dade"

# a clean counties table with the proper number and order of counties for plotting
cty <- readRDS("data/counties.rds") %>%
      mutate(polyname = name) %>%
      select(polyname) %>%
      left_join(., FIPS) %>%
      mutate(ID=1:length(polyname))

#if(!all.equal(ds$fips, dr$fips)) stop("social and risk data are misaligned")
e <- cbind(dr, select(ds, -fips))
fill <- function(x) na.omit(x)[1]
e <- left_join(cty, e) %>%
      group_by(ID) %>%
      summarise_each(funs(fill)) %>%
      ungroup() %>%
      filter(!duplicated(ID))
#if(!all.equal(cty$fips, e$fips)) stop("incorrect county structure")
e <- as.data.frame(e)

# fill in some missing values -- this is a patch that should maybe be transferred to the data prep scripts
na2min <- function(x){
      x[is.na(x) | x<0] <- min(na.omit(x[x>=0]))
      return(x)
}
e <- mutate_each_(e, funs(na2min), names(e)[grepl("tot_intensity", names(e))]) %>%
      mutate(population_density = TOTPOP/land_area,
             Income_Dollars = as.integer(as.character(sub(",", "", Income_Dollars))))

# variable names dictionary and translation functions
vars <- read.csv("data/variable_names", stringsAsFactors=F) %>%
      filter(category != "other") %>%
      arrange(desc(category), display)
r2d <- function(x) vars$display[match(x, vars$raw)]
d2r <- function(x) vars$raw[match(x, vars$display)]
g2r <- function(x) vars$raw[match(x, vars$group)]

# fake inputs for dev/debugging -- not used
input <- list(xv=vars$display[vars$category=="social"][1], 
              yv=vars$display[vars$category=="risk"][1],
              xscale="linear",
              yscale="linear",
              smoother="none",
              region="USA",
              palette="inferno",
              transpose_palette=F,
              groups=na.omit(vars$group[vars$group!=""])[1:2],
              envvar=vars$display[vars$category=="risk"][1],
              scale="linear",
              histogram_region="USA")

beforeparens <- function(x){
      if(grepl("\\(", x)) return(substr(x, 1, regexpr("\\(", x)[1]-2))
      return(x)}
capfirst <- function(x) paste0(toupper(substr(x,1,1)), substr(x,2,nchar(x)))

