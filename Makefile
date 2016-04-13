PHONY.: master_datafile cleanedtables cummulativerisk

all: output/master_county_data/master_county_data.csv output/master_county_data/cleanedsocial.csv output/master_county_data/cleanedrisk.csv
		
master_datafile: code/join_tidy_county_data.R
	cd code; Rscript join_tidy_county_data.R

cleanedtables: code/CleanMasterForAnalysis.R
	cd code; Rscript CleanMasterForAnalysis.R

cummulativerisk: code/Create_Cumulative_Index.R  output/master_county_data/riskraw.csv
	cd code; Rscript Create_Cumulative_Index.R

