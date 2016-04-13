### cleaning income data

lower48income <- read.csv("C:/Users/User1/Desktop/Stat259/vortex/vortex/raw_data/income/lower48income.csv")
View(lower48income)

income<- na.omit(lower48income)
View(income)

colnames(income)<- c("state_fips", "county_fips", "county.name", "Dollars", "Dollar_RankinState", "PercChange", "PercChange_RankinState")


## write to csv in tidy data folder
write.csv(income, "output/tidy_county_data/incomelower48.csv", row.names=FALSE)
