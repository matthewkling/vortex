#data obtained from http://www.bea.gov/newsreleases/regional/lapi/2015/xls/lapi1115.xls

#setwd("vortex") #code will not run appropriately from another directory
library(rio) #used to import Excel files

#####Downloading data from sources####
#download.file("http://www.bea.gov/newsreleases/regional/lapi/2015/xls/lapi1115.xls","raw_data/poverty_unemployment_med_income/lapi1115.xls",method="curl")
#download.file("http://www2.census.gov/geo/docs/reference/state.txt","raw_data/poverty_unemployment_med_income/state.txt")
#download.file("http://www2.census.gov/geo/docs/reference/codes/files/national_county.txt","raw_data/poverty_unemployment_med_income/fips.csv")

####Make table of FIPS values####

state <- read.table("raw_data/poverty_unemployment_med_income/state.txt",sep="|",header=T,colClasses = "character")
state.abbrv <- subset(state,select = c(STUSAB,STATE_NAME) )

county <- read.csv("raw_data/poverty_unemployment_med_income/fips.csv",colClasses = "character",header=F)
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


fips.table <- fips.table[-which(fips.table$STUSAB == "DC"),]
per.cap.raw <- import("raw_data/poverty_unemployment_med_income/lapi1115.xls")
names(per.cap.raw) <- c("location","per.cap.2012","per.cap.2013","per.cap.2014","state.rank.per.cap.2014","percent.2013","percent.2014","state.rank.percent.2014")

####Initial reading, cleaning####
per.cap.raw <- per.cap.raw[-which(is.na(per.cap.raw$per.cap.2012)|is.na(per.cap.raw$location)),] #removes rows that don't have data, leaving only states/counties.
if("United States" %in% per.cap.raw$location){per.cap.raw <- per.cap.raw[-(1:which(per.cap.raw$location=="United States")),]} #removes United States line

#changing numeric columns to numeric
  per.cap.raw[,"per.cap.2012"] <- as.numeric(per.cap.raw[,"per.cap.2012"])
  per.cap.raw[,"per.cap.2013"] <- as.numeric(per.cap.raw[,"per.cap.2013"])
  per.cap.raw[,"per.cap.2014"] <- as.numeric(per.cap.raw[,"per.cap.2014"])
  per.cap.raw[,"state.rank.per.cap.2014"] <- as.numeric(per.cap.raw[,"state.rank.per.cap.2014"])
  per.cap.raw[,"percent.2013"] <- as.numeric(per.cap.raw[,"percent.2013"])
  per.cap.raw[,"percent.2014"] <- as.numeric(per.cap.raw[,"percent.2014"])
  per.cap.raw[,"state.rank.percent.2014"] <- as.numeric(per.cap.raw[,"state.rank.percent.2014"])
  
####Adding state to the county rows####
per.cap.raw$STATE_NAME <- NA
state.rows <- which(is.na(per.cap.raw$state.rank.per.cap.2014)) #use if column weas convertic to numeric (NA inserted)

state.list <- per.cap.raw$location[state.rows]
st.begin <- state.rows; st.end <- c(state.rows[-1]-1,length(per.cap.raw$location))
state.range <- data.frame(st.begin,st.end) #ranges for each state's counties (all entries between states are from that state; they acted as headers in original document)

for (j in 1:length(state.list)) #using the row ranges for each state, labels counties accordingly.
{
  per.cap.raw$STATE_NAME[state.range$st.begin[j]:state.range$st.end[j]] <- state.list[j]
}
####Removing specific errors, standardizing county names/capitalization####
per.cap.fix <- per.cap.raw #new DF, helps tracking for tracking errors if they occur

#States without systemic errors/spot-fixes
per.cap.fix$location <- gsub("ñ","n",per.cap.fix$location) #official FIPS table does not use the accents
per.cap.fix$location[which(per.cap.fix$location=="Petersburg Borough" & per.cap.fix$STATE_NAME=="Alaska")] <- "Petersburg Census Area" #Petersburg not technically a borough, not listed as such in official FIPS list.
per.cap.fix$location[which(per.cap.fix$location=="Fremont (includes Yellowstone National Park)" & per.cap.fix$STATE_NAME=="Idaho")] <- "Fremont" #removes note from county name
per.cap.fix$location[which(per.cap.fix$location=="Oglala Lakota" & per.cap.fix$STATE_NAME=="South Dakota")] <- "Shannon" #county name changed in May 2015 and has not been updated in FIPS database

#Entries (from Virginia) that do not have "city" in them, but should.
per.cap.fix$location[which(per.cap.fix$location=="Alexandria" & per.cap.fix$STATE_NAME == "Virginia")] <- "Alexandria city"
per.cap.fix$location[which(per.cap.fix$location=="Chesapeake" & per.cap.fix$STATE_NAME == "Virginia")] <- "Chesapeake city"
per.cap.fix$location[which(per.cap.fix$location=="Hampton" & per.cap.fix$STATE_NAME == "Virginia")] <- "Hampton city"
per.cap.fix$location[which(per.cap.fix$location=="Newport News" & per.cap.fix$STATE_NAME == "Virginia")] <- "Newport News city"
per.cap.fix$location[which(per.cap.fix$location=="Norfolk" & per.cap.fix$STATE_NAME == "Virginia")] <- "Norfolk city"
per.cap.fix$location[which(per.cap.fix$location=="Portsmouth" & per.cap.fix$STATE_NAME == "Virginia")] <- "Portsmouth city"
per.cap.fix$location[which(per.cap.fix$location=="Suffolk" & per.cap.fix$STATE_NAME == "Virginia")] <- "Suffolk city"
per.cap.fix$location[which(per.cap.fix$location=="Virginia Beach" & per.cap.fix$STATE_NAME == "Virginia")] <- "Virginia Beach city"


#Entries that have merged smaller municipalities with larger (mostly Virginia); easier and less opaque than using a pattern-based fix.
    #Note from full release (http://www.bea.gov/newsreleases/regional/lapi/2015/pdf/lapi1115.pdf): Virginia combination areas consist of one or two independent cities with populations of less than 100,000 combined with an adjacent county. The county name appears first, followed by the city name(s). Separate estimates for the jurisdictions making up the combination areas are not available.

#merged.index <- grep("\\+", per.cap.fix$location) #pulls locations with " +" in location name
#merged <- per.cap.fix[merged.index,] #useful to see what locations are, base replacements on, makes altering names further down 

separated <- as.data.frame(matrix(data = NA, nrow=0, ncol = 9)) #dataframe to put un-merged municipalities into
names(separated) <- names(per.cap.fix)

#Separating municipalities (mostly Virginia; this strategy used for tranparency/easier troubleshooting)
Maui = per.cap.fix[which(per.cap.fix$location=="Maui + Kalawao"),]; Maui$location <- "Maui"
Kalawao = per.cap.fix[which(per.cap.fix$location=="Maui + Kalawao"),]; Kalawao$location <- "Kalawao"

Albemarle = per.cap.fix[which(per.cap.fix$location=="Albemarle + Charlottesville"),]; Albemarle$location <- "Albemarle"
Charlottesville.city = per.cap.fix[which(per.cap.fix$location=="Albemarle + Charlottesville"),]; Charlottesville.city$location <- "Charlottesville city"

Alleghany = per.cap.fix[which(per.cap.fix$location=="Alleghany + Covington"),]; Alleghany$location <- "Alleghany"
Covington.city = per.cap.fix[which(per.cap.fix$location=="Alleghany + Covington"),]; Covington.city$location <- "Covington city"

Augusta = per.cap.fix[which(per.cap.fix$location=="Augusta, Staunton + Waynesboro"),]; Augusta$location <- "Augusta"
Staunton.city = per.cap.fix[which(per.cap.fix$location=="Augusta, Staunton + Waynesboro"),]; Staunton.city$location <- "Staunton city"
Waynesboro.city = per.cap.fix[which(per.cap.fix$location=="Augusta, Staunton + Waynesboro"),]; Waynesboro.city$location <- "Waynesboro city"

Campbell = per.cap.fix[which(per.cap.fix$location=="Campbell + Lynchburg"),]; Campbell$location <- "Campbell"
Lynchburg.city = per.cap.fix[which(per.cap.fix$location=="Campbell + Lynchburg"),]; Lynchburg.city$location <- "Lynchburg city"

Carroll = per.cap.fix[which(per.cap.fix$location=="Carroll + Galax"),]; Carroll$location <- "Carroll"
Galax.city = per.cap.fix[which(per.cap.fix$location=="Carroll + Galax"),]; Galax.city$location <- "Galax city"

Dinwiddie = per.cap.fix[which(per.cap.fix$location=="Dinwiddie, Colonial Heights + Petersburg"),]; Dinwiddie$location <- "Dinwiddie"
Colonial.Heights.city = per.cap.fix[which(per.cap.fix$location=="Dinwiddie, Colonial Heights + Petersburg"),]; Colonial.Heights.city$location <- "Colonial Heights city"
Petersburg.city = per.cap.fix[which(per.cap.fix$location=="Dinwiddie, Colonial Heights + Petersburg"),]; Petersburg.city$location <- "Petersburg city"

Fairfax = per.cap.fix[which(per.cap.fix$location=="Fairfax, Fairfax City + Falls Church"),]; Fairfax$location <- "Fairfax"
Fairfax.city = per.cap.fix[which(per.cap.fix$location=="Fairfax, Fairfax City + Falls Church"),]; Fairfax.city$location <- "Fairfax city"
Falls.Church.city = per.cap.fix[which(per.cap.fix$location=="Fairfax, Fairfax City + Falls Church"),]; Falls.Church.city$location <- "Falls Church city"

Frederick = per.cap.fix[which(per.cap.fix$location=="Frederick + Winchester"),]; Frederick$location <- "Frederick"
Winchester.city = per.cap.fix[which(per.cap.fix$location=="Frederick + Winchester"),]; Winchester.city$location <- "Winchester city"

Greensville = per.cap.fix[which(per.cap.fix$location=="Greensville + Emporia"),]; Greensville$location <- "Greensville"
Emporia.city = per.cap.fix[which(per.cap.fix$location=="Greensville + Emporia"),]; Emporia.city$location <- "Emporia city"

Henry = per.cap.fix[which(per.cap.fix$location=="Henry + Martinsville"),]; Henry$location <- "Henry"
Martinsville.city = per.cap.fix[which(per.cap.fix$location=="Henry + Martinsville"),]; Martinsville.city$location <- "Martinsville city"

James.City = per.cap.fix[which(per.cap.fix$location=="James City + Williamsburg"),]; James.City$location <- "James City"
Williamsburg.city = per.cap.fix[which(per.cap.fix$location=="James City + Williamsburg"),]; Williamsburg.city$location <- "Williamsburg city"

Montgomery = per.cap.fix[which(per.cap.fix$location=="Montgomery + Radford"),]; Montgomery$location <- "Montgomery"
Radford.city = per.cap.fix[which(per.cap.fix$location=="Montgomery + Radford"),]; Radford.city$location <- "Radford city"

Pittsylvania= per.cap.fix[which(per.cap.fix$location=="Pittsylvania + Danville"),]; Pittsylvania$location <- "Pittsylvania"
Danville.city = per.cap.fix[which(per.cap.fix$location=="Pittsylvania + Danville"),]; Danville.city$location <- "Danville city"

Prince.George = per.cap.fix[which(per.cap.fix$location=="Prince George + Hopewell"),]; Prince.George$location <- "Prince George"
Hopewell.city = per.cap.fix[which(per.cap.fix$location=="Prince George + Hopewell"),]; Hopewell.city$location <- "Hopewell city"

Prince.William = per.cap.fix[which(per.cap.fix$location=="Prince William, Manassas + Manassas Park"),]; Prince.William$location <- "Prince William"
Manassas.city = per.cap.fix[which(per.cap.fix$location=="Prince William, Manassas + Manassas Park"),]; Manassas.city$location <- "Manassas city"
Manassas.Park.city = per.cap.fix[which(per.cap.fix$location=="Prince William, Manassas + Manassas Park"),]; Manassas.Park.city$location <- "Manassas Park city"

Roanoke.city = per.cap.fix[which(per.cap.fix$location=="Roanoke + Salem"),]; Roanoke.city$location <- "Roanoke city"
Salem.city = per.cap.fix[which(per.cap.fix$location=="Roanoke + Salem"),]; Salem.city$location <- "Salem city"

Rockbridge = per.cap.fix[which(per.cap.fix$location=="Rockbridge, Buena Vista + Lexington"),]; Rockbridge$location <- "Rockbridge"
Buena.Vista.city = per.cap.fix[which(per.cap.fix$location=="Rockbridge, Buena Vista + Lexington"),]; Buena.Vista.city$location <- "Buena Vista city"
Lexington.city = per.cap.fix[which(per.cap.fix$location=="Rockbridge, Buena Vista + Lexington"),]; Lexington.city$location <- "Lexington city"

Rockingham = per.cap.fix[which(per.cap.fix$location=="Rockingham + Harrisonburg"),]; Rockingham$location <- "Rockingham"
Harrisonburg.city = per.cap.fix[which(per.cap.fix$location=="Rockingham + Harrisonburg"),]; Harrisonburg.city$location <- "Harrisonburg city"

Southampton = per.cap.fix[which(per.cap.fix$location=="Southampton + Franklin"),]; Southampton$location <- "Southampton"
Franklin.city = per.cap.fix[which(per.cap.fix$location=="Southampton + Franklin"),]; Franklin.city$location <- "Franklin city"

Spotsylvania = per.cap.fix[which(per.cap.fix$location=="Spotsylvania + Fredericksburg"),]; Spotsylvania$location <- "Spotsylvania"
Fredericksburg.city = per.cap.fix[which(per.cap.fix$location=="Spotsylvania + Fredericksburg"),]; Fredericksburg.city$location <- "Fredericksburg city"

Washington = per.cap.fix[which(per.cap.fix$location=="Washington + Bristol"),]; Washington$location <- "Washington"
Bristol.city = per.cap.fix[which(per.cap.fix$location=="Washington + Bristol"),]; Bristol.city$location <- "Bristol city"

Wise = per.cap.fix[which(per.cap.fix$location=="Wise + Norton"),]; Wise$location <- "Wise"
Norton.city = per.cap.fix[which(per.cap.fix$location=="Wise + Norton"),]; Norton.city$location <- "Norton city"

York = per.cap.fix[which(per.cap.fix$location=="York + Poquoson"),]; York$location <- "York"
Poquoson.city = per.cap.fix[which(per.cap.fix$location=="York + Poquoson"),]; Poquoson.city$location <- "Poquoson city"

separated = rbind( #binds rows with fixed names
  Maui,
  Kalawao,
  Albemarle,
  Charlottesville.city,
  Alleghany,
  Covington.city,
  Augusta,
  Staunton.city,
  Waynesboro.city,
  Campbell,
  Lynchburg.city,
  Carroll,
  Galax.city,
  Dinwiddie,
  Colonial.Heights.city,
  Petersburg.city,
  Fairfax,
  Fairfax.city,
  Falls.Church.city,
  Frederick,
  Winchester.city,
  Greensville,
  Emporia.city,
  Henry,
  Martinsville.city,
  James.City, #for the record, it is "James City County". Because Virginia.
  Williamsburg.city,
  Montgomery,
  Radford.city,
  Pittsylvania,
  Danville.city,
  Prince.George,
  Hopewell.city,
  Prince.William,
  Manassas.city,
  Manassas.Park.city,
  Roanoke.city,
  Salem.city,
  Rockbridge,
  Buena.Vista.city,
  Lexington.city,
  Rockingham,
  Harrisonburg.city,
  Southampton,
  Franklin.city,
  Spotsylvania,
  Fredericksburg.city,
  Washington,
  Bristol.city,
  Wise,
  Norton.city,
  York,
  Poquoson.city
) 

per.cap.counties <- per.cap.fix[-which(is.na(per.cap.fix$state.rank.per.cap.2014)),] #removes state (and DC) entries from dataframe
if(("Albemarle" %in% per.cap.counties$location)==FALSE) {per.cap.counties <- rbind(per.cap.counties,separated)} #checks to make sure the separated counties haven't been added yet (admittedly arbitrary selection of county in VA, but one that doesn't share a name with any counties in other states.)
if(length(grep("\\+", per.cap.counties$location) != 0)) {per.cap.counties <- per.cap.counties[-grep("\\+", per.cap.counties$location),]} #removes the merged county names if they haven't been removed.



####Matching counties to FIPS table####
per.cap.counties$lc_county_names <- NA
per.cap.counties$lc_county_names <- tolower(per.cap.counties$location) #takes them to lowercase so they can be matched
fips.add <- merge(fips.table,per.cap.counties,by=c("STATE_NAME","lc_county_names"),all=T)
#check <- fips.add[which(is.na(fips.add$per.cap.2012)|is.na(fips.add$state_county_fips)),] #shows lines that have not merged appropriately; richmond/bedford virginia are both counties and cities, the cities not specifically mentioned in the per capita data. 

####Pulling desired data####
categories <- c(
  "state_county_fips",
  "per.cap.2014"
)

#to match Valeri's original format, changing per.cap.2014 to Dollars

per.cap <- fips.add[,categories]
names(per.cap)[which(names(per.cap)=="per.cap.2014")] <- "Dollars"

write.csv(per.cap,"output/tidy_county_data/incomelower48.csv",row.names=F) #writes out cleaned data; preserved original cleaned file and columns name

