# setup ws ---------------------------------------------------------------------
library(sf)
library(dplyr)
library(purrr)

shp.dir <- "~/R/shapefiles/"


# counties ----------------------------------------------------------------
# get counties, full detail; 2019
counties = tigris::counties(cb = FALSE, year = 2015)
#counties <- st_transform(counties, 4326)
counties <- divFcns::conic.transform(counties)
#counties %>% tibble() %>% count(FUNCSTAT)

colnames(counties) <- tolower(colnames(counties))

# get simplified counties
counties_simplified = tigris::counties(cb = T,
                                       resolution = "5m"
                                       , year = 2015)

# counties_simplified <- st_transform(counties_simplified, 4326)
counties_simplified <- divFcns::conic.transform(counties_simplified)

colnames(counties_simplified) <- tolower(colnames(counties_simplified))


# build czs from counties -------------------------------------------------
# uses county xwalk from https://github.com/walkerke/us-boundaries/blob/master/cz_1990_v2_sp.R
# ( but i want to build from my own counties to get full detail )

# FIPS codes for counties deleted since 1990 census
counties_deleted <- c(
  "02201", "02231", "02270", "02280", "12025", "30113", "46113", "51515",
  "51560", "51780"
)
# FIPS codes for counties added since 1990 census with 1990 commuting zone
counties_added <- tribble(
  ~fips_county, ~cz_1990,
  "02068", "34115",
  "02105", "34109",
  "02158", "34112",
  "02195", "34110",
  "02198", "34111",
  "02230", "34109",
  "02275", "34111",
  "02282", "34109",
  "08014", "28900",
  "12086", "07000",
  "46102", "27704"
)
# URL for commuting zone county partition using 1990 counties
url_cz <- "https://www.ers.usda.gov/webdocs/DataFiles/48457/czlma903.xls?v=68.4"
### older link from walkerke code: "https://www.ers.usda.gov/webdocs/DataFiles/Commuting_Zones_and_Labor_Market_Areas__17970/czlma903.xls"
cz_loc <- "~/R/dblinkr/.tmp/czlma903.csv" #.xls
# Read commuting zone county partition, add place and state variables
library(stringr)
co2cz <-
  read.csv(cz_loc) %>%
  tibble() %>%
  select(
    fips_county = contains("FIPS"),
    cz_1990 = CZ90,
    place_state = contains("largest.place.in.Commuting.Zone")
  ) %>%
  mutate_at(c(1,2),
            ~stringr::str_pad(., 5, side= "left", "0")) %>%
  mutate(
    cz_name =
      place_state %>%
      str_replace(" borough.*| CDP.*| city.*| town.*| \\(rem.*|,.*", ""),
    state = place_state %>% str_sub(start = -2L)
  ) %>%
  select(-place_state)
co2cz
# Adjust county partition for counties added and deleted since 1990
v <-
  counties_added %>%
  left_join(co2cz %>% select(-fips_county) %>% distinct(), by = "cz_1990")
co2cz <-
  bind_rows(co2cz, v) %>%
  filter(!(fips_county %in% counties_deleted))
rm(v)


# end adaptation from walkerke code ---------------------------------------

# -------------------------------------------------------------------------

# union counties to czs from my shp ---------------------------------------

czs <- co2cz %>%
  left_join(counties, by = c("fips_county" = "geoid"))

czs <- czs %>%
  rename(cz = cz_1990) %>%
  st_sf() %>%
  group_by(cz, cz_name) %>%
  summarise(., do_union=T) %>%
  divFcns::conic.transform()
#czs <- czs %>% st_transform(4326)
# czs["cz"] %>% plot()

# simplified
czs_simplified <- co2cz %>%
  left_join(counties_simplified, by = c("fips_county" = "geoid"))

czs_simplified <- czs_simplified %>%
  rename(cz = cz_1990) %>%
  st_sf() %>%
  group_by(cz, cz_name) %>%
  summarise(., do_union=T) %>%
  divFcns::conic.transform()

# write -------------------------------------------------------------------
usethis::use_data(
  counties, counties_simplified,
  czs, czs_simplified
  , overwrite = T)


# -------------------------------------------------------------------------

# cbsas -------------------------------------------------------------------

cbsas = tigris::core_based_statistical_areas(year = 2019)

cbsas <- cbsas %>% select(3, 4, 5,6, 7,9,10,geometry)
cbsas <- cbsas %>% rename( cbsa=1
                        ,cbsa_name = 2)
colnames(cbsas) <- tolower(colnames(cbsas))

cbsas = cbsas %>% divFcns::conic.transform()
# cbsas = st_transform(cbsas, 4326)

usethis::use_data(cbsas
                  , overwrite = T)
