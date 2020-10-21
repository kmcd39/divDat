library(sf)
library(dplyr)

# state list
stateL = xwalks::state2div$statefp


# get full reso CTs -------------------------------------------------------

cts = purrr::map_dfr(
  stateL,
  ~tigris::tracts(. ,
                  cb = F,
                  year = 2010
                  )
  )

# check & clean
cts %>% tibble()
cts %>% filter(COUNTYFP10 != COUNTYFP) #(check)
cts <- cts %>%
  select( statefp = 1
         ,countyfp = 2
         ,geoid=3
         ,geometry)

# project
cts <- divFcns::conic.transform(cts)

# make valid
library(lwgeom)
cts <- st_make_valid(cts)

# write
usethis::use_data(cts
                  , overwrite = T)


# get simplified cts ------------------------------------------------------
'
cts.simplified = purrr::map_dfr(
  stateL,
  ~tigris::tracts(. ,
                  cb = T,
                  year = 2010
  )
)

# check & clean
cts.simplified %>% tibble()

cts.simplified <- cts.simplified %>%
  select( statefp = 1
          ,countyfp = 2
          ,geoid=3
          ,geometry)

# project
cts.simplified <- divFcns::conic.transform(cts.simplified)

# write
usethis::use_data(cts.simplified
                  , overwrite = T)
'
