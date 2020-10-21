library(dplyr)
library(sf)

rm(list=ls())

wd = "~/R/all sharkey geoseg work/dividedness-measures/polygons and subdivisions/"
cldir = paste0(wd, "SFZ/from corelogic/from-shannon 10-9-2020/")

# get tract SFR ratios ----------------------------------------------------------

# from CL
sfct = list.files(cldir) %>%
  `[`(grepl("tract", .))

sfct = read.csv(paste0(cldir, sfct)) %>% tibble()
sfct = select(sfct, -c(contains("X_merge")))

# get spatial tracts -------------------------------------
cts <- readRDS("~/R/shapefiles/2010 CTs/simplified-shp.RDS")
cts %>% tibble()
#cts <- st_read("~/R/shapefiles/2010 CTs/US_tract_2010.shp")
cts <- cts %>% select( c( state = 1
                          ,county = 2
                          ,geoid = 4
                          ,gisjoin = GISJOIN
                          ,aland = ALAND10
                          ,awater=AWATER10) )

cts <- cts %>% mutate_at(c(1,2,3,4), as.character)
# merge
head(cts$geoid)
head(sfct$fipstract)
nchar(cts$geoid) %>% unique()
nchar(sfct$fipstract) %>% unique()
sfct = sfct %>% filter(fipstract != "missing")
sfct$fipstract <- stringr::str_pad(sfct$fipstract, 11, "left", "0")
sfcts = cts %>%
  left_join(sfct,
            by=c("geoid" = "fipstract"))

# check
sfcts %>% summary()


# bucket and form aggregate SFR polygons ----------------------------------
sfcts = sfcts %>%
  mutate(binned.pct_acres_sfr =
           cut( sfcts$pct_acres_sfr
                ,breaks = seq(0,1,1/4)
                #,labels = c("0-25%",">25-50%",">50-75%",">75-1")
                ,include.lowest = T
                ,dig.lab = 2 )
  ) %>%
  mutate(binned.pct_nunits_sfr =
           cut( sfcts$pct_nunits_sfr
                ,breaks = seq(0,1,1/4)
                #,labels = c("0-25%",">25-50%",">50-75%",">75-1")
                ,include.lowest = T
                ,dig.lab = 2 )
  )

# union tracts by SFR bucket
sfr.polys = sfcts %>%
  #filter(state == "25") %>% # for test area
  st_make_valid() %>%
  group_by(binned.pct_acres_sfr) %>%
  summarise(., do_union = T)

# explode
sfr.polys = sfr.polys %>%
  rmapshaper::ms_explode()
# and id per poly-in-bucket
sfr.polys = sfr.polys %>%
  group_by(binned.pct_acres_sfr) %>%
  mutate(b.id = row_number(binned.pct_acres_sfr)) %>%
  ungroup()

plot(sfr.polys['binned.pct_acres_sfr'])
sfr.polys <- sfr.polys %>% rename(acre_sfr = binned.pct_acres_sfr)

st_write(sfr.polys,
         "~/R/shapefiles/SFR-zoning-polys/SFR.shp")



# or if already generated and ya wanna skip expensive steps ---------------
library(sf)
sfr.polys=st_read("~/R/shapefiles/SFR-zoning-polys/SFR.shp")
head(sfr.polys)

# put bins in expected order
sfr.polys$acre_sfr = sfr.polys$acre_sfr %>% factor()
levels(sfr.polys$acre_sfr) <- levels(sfr.polys$acre_sfr)[c(4,1,2,3)]
levels(sfr.polys$acre_sfr)

# sfr.polys <- st_transform(sfr.polys, 4326)
sfr.polys <- divFcns::conic.transform(sfr.polys)

usethis::use_data(sfr.polys
                  ,overwrite = T)
