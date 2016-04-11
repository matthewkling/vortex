.PHONY: data clean

all: output/master_county_data/master_county_data.csv output/master_county_data/cleanedsocial.csv output/master_county_data/cleanedrisk.csv
		
output/master_county_data/master_county_data.csv: code/join_tidy_county_data.R
	cd code; Rscript join_tidy_county_data.R

output/master_county_data/cleanedsocial.csv: code/CleanMasterForAnalysis.R
	cd code; Rscript CleanMasterForAnalysis.R

output/master_county_data/cleanedrisk.csv: code/Create_Cumulative_Index.R  output/master_county_data/riskraw.csv
	cd code; Rscript Create_Cumulative_Index.R

