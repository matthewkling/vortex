# Hurricane data

These data come from NOAA's HURDAT2 database for the Atlantic region, and represent the tracks of every hurricane since 1851.

The direct download link for the dataset is http://www.nhc.noaa.gov/data/hurdat/hurdat2-1851-2015-021716.txt

Metadata can be found at http://www.nhc.noaa.gov/data/hurdat/hurdat2-format-atlantic.pdf

Starting from this raw file, our scripts:
1. restructure the data into a tidy tabular format
2. interpolate the raw 6-hour time steps to a one-hour frequency to better represent continuous storm paths
3. derive an index of destructive force by cubing maximum windspeed at each timestep (wind force is proportional to the cube of velocity)
4. sum the index values for all points falling in each US county
5. convert this final data into a standard format and save as a CSV