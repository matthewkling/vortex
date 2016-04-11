.PHONY: data clean

all: output/master_county_data.csv, output/cleanedsocial.csv, output/cleanrisk.csv
		
output/master_county_data.csv: code/join_tidy_county_data.R
	cd code; Rscript join_tidy_county_data.R

output/cleanedsocial.csv: code/CleanMasterForAnalysis.R
	cd code; Rscript CleanMasterForAnalysis.R

output/cleanedrisk.csv: code/Create_Cummulative_Index.R
	cd code; Rscript Creat_Cummulative_Index.R

