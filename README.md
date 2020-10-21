# divDat

R library containing various spatial layers stored as sf objects.
Currently contains:
-CBSAs
-counties
-census tracts
-commuting zones
-the 1947 Interstate Highway Plan
-census-defined places
-Redlining/HOLC neighborhoods
-school districts
-Polygons for estimated single-family residential as portion of total residential land

## To generate
The data is too large to download and install from github, but most layers are generated just from the tigris library. 
Scripts in the data-raw folder can generate for these ones.
