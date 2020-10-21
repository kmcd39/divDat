library(dplyr)
library(purrr)
library(sf)

state_list = xwalks::state2div$statefp

# get full--- concat unified w/ elementarty
usds = purrr::map_dfr(state_list,
                      possibly(~tigris::school_districts(state = .,
                                                         type = "unified",
                                                         cb=F,
                                                         year = 2019)
                               ,otherwise = NA))

esds = purrr::map(state_list,
                  possibly(~tigris::school_districts(state = .,
                                                     type = "elementary",
                                                     cb=F,
                                                     year = 2019)
                           ,otherwise = NA))
esds <- esds[!is.na(esds)]
esds <- do.call("rbind", esds)

colnames(usds)
colnames(esds)
usds = select(usds
              ,c(1,3,4,5,6,7,SDTYP, 11,12,geometry))
esds = select(esds
              ,c(1,3,4,5,6,7,SDTYP, 11,12,geometry))

sdsf = rbind(usds,esds)
sdsf

# trim 0 land area "not-defined" school districts
sdsf %>% filter(grepl("Not Defined", NAME, ignore.case = T) )
sdsf <- sdsf %>%
  filter( !grepl("Not Defined", NAME, ignore.case = T) )

school.dists = sdsf

#school.dists = st_transform(school.dists, 4326)
school.dists = divFcns::conic.transform(school.dists)
usethis::use_data(school.dists
                  ,overwrite = T)
# verify no overlap -------------------------------------------------------
'
dif = sdsf %>% st_intersection()
tmp = dif %>% filter(n.overlaps > 1)
library(lwgeom)
tmp = tmp %>%
  st_transform(4326) %>%
  mutate(intarea = st_geod_area(geometry))

tmp$intarea %>% summary()'
# lol yes no overlaps.

# write 2 db --------------------------------------------------------------
library(dblinkr)

con <- princeton.db.connect("km31", "Sh@rkey20")
st_write(obj = sdsf
         , dsn = con
         , Id(schema="divs", table="school_dists"))



# get lower-res equivalent ------------------------------------------------

usds.simp = purrr::map_dfr(state_list,
                           possibly(~tigris::school_districts(.,
                                                              type = "unified",
                                                              cb=T,
                                                              year = 2019)
                                    ,otherwise = NA))

esds.simp = purrr::map_dfr(state_list,
                           possibly(~tigris::school_districts(.,
                                                              type = "elementary",
                                                              cb=T,
                                                              year = 2019)
                                    ,otherwise = NA))



esds <- esds[!is.na(esds)]
esds <- do.call("rbind", esds)

colnames(usds)
colnames(esds)
'
usds = select(usds
              ,c(1,3,4,5,6,7,SDTYP, 11,12,geometry))
esds = select(esds
              ,c(1,3,4,5,6,7,SDTYP, 11,12,geometry))

sdsf = rbind(usds,esds)
sdsf'
