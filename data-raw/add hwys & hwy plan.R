library(dplyr)
library(sf)

shp.dir <- "~/R/shapefiles/"

# 1947 hwy plan ---------------------------------------------------------------------
# this is the 1947 hwy plan digitized by philly federal reserve ppl, after I
# made some manual edits using mapedit::editFeatures
interstate.plan <- st_read(paste0(shp.dir, "1947plan/most addl cleans/cleaner-hwy-plan.shp"))

#interstate.plan <- st_transform(interstate.plan, 4326)
interstate.plan <- divFcns::conic.transform(interstate.plan)

# cleaned_plan["id"] %>% plot()
usethis::use_data(interstate.plan
                  ,overwrite = T)


# full NHPN ---------------------------------------------------------------

#########
