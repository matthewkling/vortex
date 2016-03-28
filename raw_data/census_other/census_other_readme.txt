Data was obtained from http://www.ers.usda.gov/data-products/county-level-data-sets/download-data.aspx
Each file was converted to .csv format with excel.

#############
#In R, FIPS header names were changed to "state_county_fips" using the following code:
#############

#for the PopulationEstimates.csv file
library(data.table)
popest <- fread("raw_data/census_other/PopulationEstimates.csv", skip=2)
names(popest)[1] <- "state_county_fips"
names(popest)
write.csv(popest, "raw_data/census_other/PopulationEstimates.csv")

#for the PovertyEstimates.csv file
library(data.table)
povest <- fread("raw_data/census_other/PovertyEstimates.csv", skip=2)
names(povest)[1] <- "state_county_fips"
names(povest)
write.csv(povest, "raw_data/census_other/PovertyEstimates.csv")

#for the Unemployment.csv file
library(data.table)
unemp <- fread("raw_data/census_other/Unemployment.csv", skip=6)
names(unemp)[1] <- "state_county_fips"
names(unemp)
write.csv(unemp, "raw_data/census_other/Unemployment.csv")

#############
#Files were then tidied up using the following R code:
#############

#for the PopulationEstimates.csv file
popest_raw <- read.csv(("raw_data/census_other/PopulationEstimates.csv"))

popest <- subset(poverty_raw,select=c(state_county_fips,POVALL_2014,PCTPOVALL_2014))

write.csv(poverty,"output/tidy_county_data/poverty.csv",row.names = F)

#check <- read.csv("output/tidy_county_data/poverty.csv")

#for the PovertyEstimates.csv file
poverty_raw <- read.csv(("raw_data/census_other/PovertyEstimates.csv"))

poverty <- subset(poverty_raw,select=c(state_county_fips,POVALL_2014,PCTPOVALL_2014))

write.csv(poverty,"output/tidy_county_data/poverty.csv",row.names = F)

#check <- read.csv("output/tidy_county_data/poverty.csv")

#for the Unemployment.csv file
poverty_raw <- read.csv(("raw_data/census_other/PovertyEstimates.csv"))

poverty <- subset(poverty_raw,select=c(state_county_fips,POVALL_2014,PCTPOVALL_2014))

write.csv(poverty,"output/tidy_county_data/poverty.csv",row.names = F)

#check <- read.csv("output/tidy_county_data/poverty.csv")


######################
Unemployment Variable Descriptions
Variables	Descriptions	
FIPS_Code	State-County FIPS Code	
State	State Abbreviation	
Area_name	Area name	
Rural_urban_continuum_code_2003	Rural-urban Continuum Code, 2003	
Urban_influence_code_2003	Urban Influence Code, 2003	
Rural_urban_continuum_code_2013	Rural-urban Continuum Code, 2013	
Urban_influence_code_2013	Urban Influence Code, 2013	
Civilian_labor_force_2006	Civilian labor force annual average, 2006	
Employed_2006	Number employed annual average, 2006	
Unemployed_2006	Number unemployed annual average, 2006	
Unemployment_rate_2006	Unemployment rate, 2006	
Civilian_labor_force_2007	Civilian labor force annual average, 2007	
Employed_2007	Number employed annual average, 2007	
Unemployed_2007	Number unemployed annual average, 2007	
Unemployment_rate_2007	Unemployment rate, 2007	
Civilian_labor_force_2008	Civilian labor force annual average, 2008	
Employed_2008	Number employed annual average, 2008	
Unemployed_2008	Number unemployed annual average, 2008	
Unemployment_rate_2008	Unemployment rate, 2008	
Civilian_labor_force_2009	Civilian labor force annual average, 2009	
Employed_2009	Number employed annual average, 2009	
Unemployed_2009	Number unemployed annual average, 2009	
Unemployment_rate_2009	Unemployment rate, 2009	
Civilian_labor_force_2010	Civilian labor force annual average, 2010	
Employed_2010	Number employed annual average, 2010	
Unemployed_2010	Number unemployed annual average, 2010	
Unemployment_rate_2010	Unemployment rate, 2010	
Civilian_labor_force_2011	Civilian labor force annual average, 2011	
Employed_2011	Number employed annual average, 2011	
Unemployed_2011	Number unemployed annual average, 2011	
Unemployment_rate_2011	Unemployment rate, 2011	
Civilian_labor_force_2012	Civilian labor force annual average, 2012	
Employed_2012	Number employed annual average, 2012	
Unemployed_2012	Number unemployed annual average, 2012	
Unemployment_rate_2012	Unemployment rate, 2012	
Civilian_labor_force_2013	Civilian labor force annual average, 2013	
Employed_2013	Number employed annual average, 2013	
Unemployed_2013	Number unemployed annual average, 2013	
Unemployment_rate_2013	Unemployment rate, 2013	
Civilian_labor_force_2014	Civilian labor force annual average, 2014	
Employed_2014	Number employed annual average, 2014	
Unemployed_2014	Number unemployed annual average, 2014	
Unemployment_rate_2014	Unemployment rate, 2014	
Median_Household_Income_2014	Median household Income Annual Average, 2014	
Med_HH_Income_Percent_of_State_Total_2014	County Household Median Income as a percent of the State Total Median Household Income	
		
Sources:	Rural Classifications - USDA, Economic Research Service	http://www.ers.usda.gov/topics/rural-economy-population/rural-classifications.aspx
	Labor force variables- Bureau of Labor Statistics, Local Area Unemployment Statistics	http://www.bls.gov/lau/
	Median HH Income- Census Bureau, Small Area Income & Poverty Estimates (SAIPE)	http://www.census.gov/did/www/saipe/index.html
		
	For more information contact: Tim Parker  tparker@ers.usda.gov	
######################





######################	
Population Estimates Variable Descriptions

Source: Population estimates - Census Bureau	http://www.census.gov/popest/data/counties/totals/2014/CO-EST2014-alldata.html						
							
Column variable	Description	Notes					
FIPStxt	State-County FIPS Code						
State	State Abbreviation						
Area_Name	Area name						
Rural-urban_Continuum Code_2003	Rural-urban Continnuum Code, 2003	http://www.ers.usda.gov/data-products/rural-urban-continuum-codes.aspx#.UVRRXjcTSHs					
Urban_Influence_Code_2003	Urban Influence Code, 2003	http://www.ers.usda.gov/data-products/urban-influence-codes.aspx#.UVRRmzcTSHs					
Rural-urban_Continuum Code_2013	Rural-urban Continnuum Code, 2013	http://www.ers.usda.gov/data-products/rural-urban-continuum-codes.aspx#.UjyXuH9tdWo					
Urban_Influence_Code_2013	Urban Influence Code, 2013	http://www.ers.usda.gov/data-products/urban-influence-codes.aspx#.UVRRmzcTSHs					
CENSUS_2010_POP	4/1/2010 resident Census 2010 population						
ESTIMATES_BASE_2010	4/1/2010 resident total population estimates base						
POP_ESTIMATE_2010	7/1/2010 resident total population estimate						
POP_ESTIMATE_2011	7/1/2011 resident total population estimate						
POP_ESTIMATE_2012	7/1/2012 resident total population estimate						
POP_ESTIMATE_2013	7/1/2013 resident total population estimate						
POP_ESTIMATE_2014	7/1/2014 resident total population estimate						
N_POP_CHG_2010	Numeric Change in resident total population 4/1/2010 to 7/1/2010						
N_POP_CHG_2011	Numeric Change in resident total population 7/1/2010 to 7/1/2011						
N_POP_CHG_2012	Numeric Change in resident total population 7/1/2011 to 7/1/2012						
N_POP_CHG_2013	Numeric Change in resident total population 7/1/2012 to 7/1/2013						
N_POP_CHG_2014	Numeric Change in resident total population 7/1/2013 to 7/1/2014						
Births_2010	Births in period 4/1/2010 to 6/30/2010						
Births_2011	Births in period 7/1/2010 to 6/30/2011						
Births_2012	Births in period 7/1/2011 to 6/30/2012						
Births_2013	Births in period 7/1/2012 to 6/30/2013						
Births_2014	Births in period 7/1/2013 to 6/30/2014						
Deaths_2010	Deaths in period 4/1/2010 to 6/30/2010						
Deaths_2011	Deaths in period 7/1/2010 to 6/30/2011						
Deaths_2012	Deaths in period 7/1/2011 to 6/30/2012						
Deaths_2013	Deaths in period 7/1/2012 to 6/30/2013						
Deaths_2014	Deaths in period 7/1/2013 to 6/30/2014						
NATURAL_INC_2010	Natural increase in period 4/1/2010 to 6/30/2010						
NATURAL_INC_2011	Natural increase in period 7/1/2010 to 6/30/2011						
NATURAL_INC_2012	Natural increase in period 7/1/2011 to 6/30/2012						
NATURAL_INC_2013	Natural increase in period 7/1/2012 to 6/30/2013						
NATURAL_INC_2014	Natural increase in period 7/1/2013 to 6/30/2014						
INTERNATIONAL_MIG_2010	Net international migration in period 4/1/2010 to 6/30/2010						
INTERNATIONAL_MIG_2011	Net international migration in period 7/1/2010 to 6/30/2011						
INTERNATIONAL_MIG_2012	Net international migration in period 7/1/2011 to 6/30/2012						
INTERNATIONAL_MIG_2013	Net international migration in period 7/1/2012 to 6/30/2013						
INTERNATIONAL_MIG_2014	Net international migration in period 7/1/2013 to 6/30/2014						
DOMESTIC_MIG_2010	Net domestic migration in period 4/1/2010 to 6/30/2010						
DOMESTIC_MIG_2011	Net domestic migration in period 7/1/2010 to 6/30/2011						
DOMESTIC_MIG_2012	Net domestic migration in period 7/1/2011 to 6/30/2012						
DOMESTIC_MIG_2013	Net domestic migration in period 7/1/2012 to 6/30/2013						
DOMESTIC_MIG_2014	Net domestic migration in period 7/1/2013 to 6/30/2014						
NET_MIG_2010	Net migration in period 4/1/2010 to 6/30/2010						
NET_MIG_2011	Net migration in period 7/1/2010 to 6/30/2011						
NET_MIG_2012	Net migration in period 7/1/2011 to 6/30/2012						
NET_MIG_2013	Net migration in period 7/1/2012 to 6/30/2013						
NET_MIG_2014	Net migration in period 7/1/2013 to 6/30/2014						
RESIDUAL_2010	Residual for period 4/1/2010 to 6/30/2010						
RESIDUAL_2011	Residual for period 7/1/2010 to 6/30/2011						
RESIDUAL_2012	Residual for period 7/1/2011 to 6/30/2012						
RESIDUAL_2013	Residual for period 7/1/2012 to 6/30/2013						
RESIDUAL_2014	Residual for period 7/1/2013 to 6/30/2014						
GQ_ESTIMATES_BASE_2010	4/1/2010 Group Quarters total population estimates base						
GQ_ESTIMATES_2010	7/1/2010 Group Quarters total population estimate						
GQ_ESTIMATES_2011	7/1/2011 Group Quarters total population estimate						
GQ_ESTIMATES_2012	7/1/2012 Group Quarters total population estimate						
GQ_ESTIMATES_2013	7/1/2013 Group Quarters total population estimate						
GQ_ESTIMATES_2014	7/1/2014 Group Quarters total population estimate						
R_birth_2011	Birth rate in period 7/1/2010 to 6/30/2011						
R_birth_2012	Birth rate in period 7/1/2011 to 6/30/2012						
R_birth_2013	Birth rate in period 7/1/2012 to 6/30/2013						
R_birth_2014	Birth rate in period 7/1/2013 to 6/30/2014						
R_death_2011	Death rate in period 7/1/2010 to 6/30/2011						
R_death_2012	Death rate in period 7/1/2011 to 6/30/2012						
R_death_2013	Death rate in period 7/1/2012 to 6/30/2013						
R_death_2014	Death rate in period 7/1/2013 to 6/30/2014						
R_NATURAL_INC_2011	Natural increase rate in period 7/1/2010 to 6/30/2011						
R_NATURAL_INC_2012	Natural increase rate in period 7/1/2011 to 6/30/2012						
R_NATURAL_INC_2013	Natural increase rate in period 7/1/2012 to 6/30/2013						
R_NATURAL_INC_2014	Natural increase rate in period 7/1/2013 to 6/30/2014						
R_INTERNATIONAL_MIG_2011	Net international migration rate in period 7/1/2010 to 6/30/2011						
R_INTERNATIONAL_MIG_2012	Net international migration rate in period 7/1/2011 to 6/30/2012						
R_INTERNATIONAL_MIG_2013	Net international migration rate in period 7/1/2012 to 6/30/2013						
R_INTERNATIONAL_MIG_2014	Net international migration rate in period 7/1/2013 to 6/30/2014						
R_DOMESTIC_MIG_2011	Net domestic migration rate in period 7/1/2010 to 6/30/2011						
R_DOMESTIC_MIG_2012	Net domestic migration rate in period 7/1/2011 to 6/30/2012						
R_DOMESTIC_MIG_2013	Net domestic migration rate in period 7/1/2012 to 6/30/2013						
R_DOMESTIC_MIG_2014	Net domestic migration rate in period 7/1/2013 to 6/30/2014						
R_NET_MIG_2011	Net migration rate in period 7/1/2010 to 6/30/2011						
R_NET_MIG_2012	Net migration rate in period 7/1/2011 to 6/30/2012						
R_NET_MIG_2013	Net migration rate in period 7/1/2012 to 6/30/2013						
R_NET_MIG_2014	Net migration rate in period 7/1/2013 to 6/30/2014						
######################
							
######################							
PovertyEstimates Variable Descriptions

Column variable name	Description	Notes
FIPStxt	State-County FIPS Code	
State	State Abbreviation	
Area_name	Area name	
Rural-urban_Continuum_Code_2003	Rural-urban Continuum Code, 2003	http://www.ers.usda.gov/data-products/rural-urban-continuum-codes.aspx
Urban_Influence_Code_2003	Urban Influence Code, 2003	http://www.ers.usda.gov/data-products/urban-influence-codes.aspx
Rural-urban_Continuum_Code_2013	Rural-urban Continuum Code, 2013	http://www.ers.usda.gov/data-products/rural-urban-continuum-codes.aspx
Urban_Influence_Code_2013	Urban Influence Code, 2013	http://www.ers.usda.gov/data-products/urban-influence-codes.aspx
POVALL_2014	Estimate of people of all ages in poverty 2014	http://www.census.gov/did/www/saipe/index.html
CI90LBAll_2014	90% confidence interval lower bound of estimate of people of all ages in poverty 2014	
CI90UBALL_2014	90% confidence interval upper bound of estimate of people of all ages in poverty 2014	
PCTPOVALL_2014	Estimated percent of people of all ages in poverty 2014	
CI90LBALLP_2014	90% confidence interval lower bound of estimate of percent of people of all ages in poverty 2014	
CI90UBALLP_2014	90% confidence interval upper bound of estimate of percent of people of all ages in poverty 2014	
POV017_2014	Estimate of people age 0-17 in poverty 2014	
CI90LB017_2014	90% confidence interval lower bound of estimate of people age 0-17 in poverty 2014	
CI90UB017_2014	90% confidence interval upper bound of estimate of people age 0-17 in poverty 2014	
PCTPOV017_2014	Estimated percent of people age 0-17 in poverty 2014	
CI90LB017P_2014	90% confidence interval lower bound of estimate of percent of people age 0-17 in poverty 2014	
CI90UB017P_2014	90% confidence interval upper bound of estimate of percent of people age 0-17 in poverty 2014	
POV517_2014	Estimate of related children age 5-17 in families in poverty 2014	
CI90LB517_2014	90% confidence interval lower bound of estimate of related children age 5-17 in families in poverty 2014	
CI90UB517_2014	90% confidence interval upper bound of estimate of related children age 5-17 in families in poverty 2014	
PCTPOV517_2014	Estimated percent of related children age 5-17 in families in poverty 2014	
CI90LB517P_2014	90% confidence interval lower bound of estimate of percent of related children age 5-17 in families in poverty 2014	
CI90UB517P_2014	90% confidence interval upper bound of estimate of percent of related children age 5-17 in families in poverty 2014	
MEDHHINC_2014	Estimate of median household income 2014	
CI90LBINC_2014	90% confidence interval lower bound of estimate of median household income 2014	
CI90UBINC_2014	90% confidence interval upper bound of estimate of median household income 2014	
POV05_2014	Estimate of people under age 5 in poverty 2014	
CI90LB05_2014	90% confidence interval lower bound of estimate of people under age 5 in poverty 2014	
CI90UB05_2014	90% confidence interval upper bound of estimate of people under age 5 in poverty 2014	
PCTPOV05_2014	Estimated percent of people under age 5 in poverty 2014	
CI90LB05P_2014	90% confidence interval lower bound of estimate of percent of people under age 5 in poverty 2014	
CI90UB05P_2014	90% confidence interval upper bound of estimate of percent of people under age 5 in poverty 2014	
		
Sources: Census Bureau Population Estimates: http://www.census.gov/did/www/saipe/		
USDA, Economic Research Service, Rural Classifications: http://www.ers.usda.gov/topics/rural-economy-population/rural-classifications.aspx		
		
		
For more information contact: Tim Parker  tparker@ers.usda.gov	
######################
	