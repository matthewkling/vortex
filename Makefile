PHONY.: masterdatafile cleanedtables cumulativerisk

all: output/master_county_data/master_county_data.csv output/master_county_data/cleanedsocial.csv output/master_county_data/cleanedrisk.csv
		
masterdatafile: code/join_tidy_county_data.R
	Rscript code/join_tidy_county_data.R

cleanedtables: code/CleanMasterForAnalysis.R
	Rscript code/CleanMasterForAnalysis.R

cumulativerisk: code/Create_Cumulative_Index.R  output/master_county_data/riskraw.csv
	Rscript code/Create_Cumulative_Index.R

