# This script pulls EJ Screen data from the EPA API: https://ejscreen.epa.gov/mapper/ejscreenapi.html
# Data is downloaded by census block group, the smallest areal unit supported by EJ Screen
# -----------------------------------------------------------------------------
# The following packages are necessary to run this script
# install.packages('censusxy')
# install.packages('jsonlite')
library('tidyverse')

# EJ Screen field descriptions: https://ejscreen.epa.gov/mapper/ejsoefielddesc.html

# EDIT THESE FIELDS TO PULL DATA FOR YOUR ADDRESS OF INTEREST
street = "1111 E Cabrillo Blvd." # street name & number, string
city = "Santa Barbara" # string
statecode = "CA" # two-letter code, string
zipcode = 93101 # five-digit code, integer

address = censusxy::cxy_single(street, city, statecode, zipcode) # Census format for address
lon = address['coordinates.x'] # Census block group longitude
lat = address['coordinates.y'] # Census block group latitude

geogs = censusxy::cxy_geography(lon, lat) # Geographies for census block group
tract = geogs['Census.Tracts.GEOID'] # Census tract num.
blkgrp = geogs['X2020.Census.Blocks.BLKGRP'] # Census block group num. (w/in tract)
FIPS = toString(paste(tract, blkgrp, sep = '')) # FIPS code for block group

# Create URL for corresponding json file for FIPS code in EJ Screen API
url1 = 'https://ejscreen.epa.gov/mapper/ejscreenRESTbroker.aspx?namestr='
url2 = '&geometry=&distance=&unit=9035&areatype=blockgroup&areaid='
url3 = '&f=pjson'
url = paste(url1, FIPS, url2, FIPS, url3, sep ='')

# Example: visualize EJ Screen data within national percentiles
ejscreen_raw <- jsonlite::fromJSON(url) # Download EJ Screen data for census block at json
NP_inds = grep(x = names(ejscreen_raw), pattern = 'N_P') # Extract indices of national percentiles
# Construct data frame for visualization below
NP_df = as.data.frame(unlist(ejscreen_raw[NP_inds])) 
NP_names = colnames(NP_df)
NP_vals = as.numeric(ejscreen_raw[NP_inds])
NP_data = data.frame(Field = NP_names, Percentile = NP_vals)

ggplot(data = NP_data, aes(x = Field, y = Percentile)) + geom_col() + 
  theme(axis.text.x = element_text(angle = 90)) + ylim(0, 100)

# Evan Heberlein - eth47@cornell.edu