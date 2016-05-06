######### Downloading and Cleaning the Demographic Data by county ###########
###### Data comes from Census Bureau Population Estimates from 2014 #########

#download data
download.file("https://www.census.gov/popest/data/counties/asrh/2014/files/CC-EST2014-ALLDATA.csv", "raw_data/census/CensusRaceEst/CC-EST2014-ALLDATA.csv", method="curl")

#read data
CC2014 <- read.csv("raw_data/census/CensusRaceEst/CC-EST2014-ALLDATA.csv")

# Adjust column names for consistency when compiling scripts via join_tidy_county_data.R
names(CC2014)[2:3]<-c("state_fips", "county_fips")

# To identify columns of interest: see names pdf in rawdata/census/CensusRaceEst directory #
#COLUMNS 1:20 -- Single races by male and female 
#+
#COL57 H_MALE
#COL58 H_FEMALE
#COL33 NH_MALE
#COL34 NH_FEMALE

CC_AGE_SEX<-cbind(CC2014[,1:20], CC2014[,57:58], CC2014[,33:36])

# aggregate age data
# totals, select row where Age=0, and years 3-7 representing population estimates in July 2010-2014
CC_SEX<-subset(CC_AGE_SEX, AGEGRP == 0 & YEAR!=1 & YEAR!=2)

#rename table and aggregate sexes
CC<-CC_SEX

CC$WA<-CC$WA_MALE+CC$WA_FEMALE
CC$BA<-CC$BA_MALE+CC$BA_FEMALE
CC$IA<-CC$IA_MALE+CC$IA_FEMALE
CC$AA<-CC$AA_MALE+CC$AA_FEMALE
CC$Na<-CC$NA_MALE+CC$NA_FEMALE
CC$NH<-CC$NH_MALE+CC$NH_FEMALE
CC$H<-CC$H_MALE+CC$H_FEMALE
CC$NHW<-CC$NHWA_MALE+ CC$NHWA_FEMALE

#trim male female columns, adjust column names
CC<-cbind(CC[,2:6], CC[,8], CC[,27:34])
View(CC)
names(CC)[6]<-"TOT_POP"

View(CC)

#Split by Year into a list of lists for seperate tables!
CCbyYR<-split(CC,CC$YEAR)
summary(CCbyYR)

#Export each dataframe in CCbyYR to a csv

CC.df<- do.call("rbind", lapply(CCbyYR, as.data.frame)) 

#write.csv(CC.df, file = "CensusRace.csv")  
# Here we write only year == 7 which reflects popolation estimates for July 2014. 
write.csv(CC.df[CC.df$YEAR==7,], file = "output/tidy_county_data/CensusRace.csv", row.names=F)


