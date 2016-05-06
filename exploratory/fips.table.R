#Creates table containing state/county names and fips, so files with only some attributes can be converted.
    #State data from http://www2.census.gov/geo/docs/reference/state.txt
    #County data from http://www2.census.gov/geo/docs/reference/codes/files/national_county.txt (info/GUI here https://www.census.gov/geo/reference/codes/cou.html)

state <- read.table("state.txt",sep="|",header=T,colClasses = "character")
state.abbrv <- subset(state,select = c(STUSAB,STATE_NAME) )

county <- read.csv("fips.csv",colClasses = "character",header=F)
names(county) <- c("STUSAB","state_fips","county_fips","county_name_full","fips_class")

fips.table <- merge(state.abbrv,county,by="STUSAB")
fips.table$state_county_fips <- paste(fips.table$state_fips,fips.table$county_fips,sep="")

#remove non-states
discard.terr <- which(fips.table$STATE_NAME=="American Samoa"|fips.table$STATE_NAME=="Guam"|fips.table$STATE_NAME=="Northern Mariana Islands"|fips.table$STATE_NAME=="Puerto Rico"|fips.table$STATE_NAME=="U.S. Minor Outlying Islands"|fips.table$STATE_NAME=="U.S. Virgin Islands")
fips.table <- fips.table[-discard.terr,]

fips.table$lc_county_names <- fips.table$county_name_full
fips.table$lc_county_names <- tolower(fips.table$lc_county_names)
fips.table$lc_county_names[which(fips.table$STATE_NAME!="Virginia")] <- gsub(" county","",fips.table$lc_county_names)[which(fips.table$STATE_NAME!="Virginia")] #removes county from names, except for Virginia because Virginia is so odd.
fips.table$lc_county_names <- gsub(" parish","",fips.table$lc_county_names) #removes parish from names


write.csv(fips.table,"fips.table.csv",row.names = F)

fips.table$lc_county_name <-
