#Columns of interest: see names pdf in github folder for column metadata
#COLUMNS 1:20 -- Single races by male and female 
#+
#COL57 H_MALE
#COL58 H_FEMALE
#COL33 NH_MALE
#COL34 NH_FEMALE

CC2014 <- read.csv("C:/Users/User1/Desktop/Stat259/vortex/vortex/raw_data/census/CensusRaceEst/CC-EST2014-ALLDATA.csv")
#for consistency with compiling scripts
names(CC2014)[2:3]<-c("state_fips", "county_fips")

CC_AGE_SEX<-cbind(CC2014[,1:20], CC2014[,57:58], CC2014[,33:34])
# totals, select row where Age=0, and years 3-7 representing population estimates in July 2010-2014
CC_SEX<-subset(CC_AGE_SEX, AGEGRP == 0 & YEAR!=1 & YEAR!=2)

CC<-CC_SEX
CC$WA<-CC$WA_MALE+CC$WA_FEMALE
CC$BA<-CC$BA_MALE+CC$BA_FEMALE
CC$IA<-CC$IA_MALE+CC$IA_FEMALE
CC$AA<-CC$AA_MALE+CC$AA_FEMALE
CC$Na<-CC$NA_MALE+CC$NA_FEMALE
CC$NH<-CC$NH_MALE+CC$NH_FEMALE
CC$H<-CC$H_MALE+CC$H_FEMALE

#trim male female columns
CC<-cbind(CC[,2:6], CC[,8], CC[,25:31])
View(CC)
names(CC)[6]<-"TOT_POP"

View(CC)

#Split by Year into a list of lists for seperate tables!
CCbyYR<-split(CC,CC$YEAR)
summary(CCbyYR)

#Export each dataframe in CCbyYR to a csv

CC.df<- do.call("rbind", lapply(CCbyYR, as.data.frame)) 
write.csv(CC.df, file = "CensusRace.csv")


