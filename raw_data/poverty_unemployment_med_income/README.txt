Unemployment data were downloaded from http://www.ers.usda.gov/dataFiles/CountyLevelDatasets/Unemployment.xls
Poverty data were downloaded from http://www.ers.usda.gov/dataFiles/CountyLevelDatasets/PovertyEstimates.xls
Per-capita income were downloaded from http://www.bea.gov/newsreleases/regional/lapi/2015/xls/lapi1115.xls
Table with state names/abbreviations downloaded from http://www2.census.gov/geo/docs/reference/state.txt
Table with all county fips downloaded from http://www2.census.gov/geo/docs/reference/codes/files/national_county.txt

Unemployment and poverty data were downloaded from USDA Economic Research Service; several datasets available at http://www.ers.usda.gov/data-products/county-level-data-sets/download-data.aspx
Documentation for data at http://www.ers.usda.gov/data-products/county-level-data-sets/documentation.aspx 
Poverty estimates were obtained from U.S. Census Bureau's Small Area Income and Poverty Estimate (SAIPE) program, and unemployment and median household income came from the Bureau of Labor Statistics (BLS) Local Area Unemployment Statistics (LAUS) program. More details on data documentation site.


Income data were obtained from US Bureau of Economic Analysis, news release here http://www.bea.gov/newsreleases/regional/lapi/lapi_newsrelease.htm
Full release in PDF form found here: http://www.bea.gov/newsreleases/regional/lapi/2015/pdf/lapi1115.pdf
Note: this dataset presented significant formatting challenges:
	- Counties were not listed with state name or FIPS; state had to be matched to each county entry
	- State/county combinations were matched to a table of states/counties and associated FIPS
	- Virginia has an unusual way of coding cities and counties, and this dataset has merged several municipalies then lists them as "larger municipality + smaller municipalitie(s)". All had to be separated in order for the county/state name to be matched to FIPS.