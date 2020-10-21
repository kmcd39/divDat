library(dplyr)
library(sf)

shp.dir <- "~/R/shapefiles/"


# redlining -----------------------------------------------------------------

redlining <- st_read(paste0(shp.dir,
                            "redlining shpfiles/shapefile/holc_ad_data.shp"))

head(redlining, 2)
colnames(redlining)
#redlining <- st_transform(redlining, 4326)
redlining <- divFcns::conic.transform(redlining)
redlining["holc_grade"] %>% plot()

redlining <- redlining %>% select(-area_descr)

usethis::use_data(redlining
                  ,overwrite = T)



# places ------------------------------------------------------------------

plc <- st_read(paste0(shp.dir,
                      "places/places.shp"))

#plc <- st_transform(plc, 4326)
plc <- divFcns::conic.transform(plc)

usethis::use_data(plc
                  ,overwrite = T)
