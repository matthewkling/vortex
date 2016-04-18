### cleaning income data

lower48income <- read.csv("raw_data/income/lower48income.csv") #assume vortex is working directory
View(lower48income)

income<- na.omit(lower48income)
View(income)

## write to csv in tidy data folder
write.csv(income, "output/tidy_county_data/incomelower48.csv")
