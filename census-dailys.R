###=== CENSUS DAILY RESPONSE REPORT ===============================

###--- PREP WORKSPACE ---------------------------------------------

## Set working directory and clear memory
setwd("/Users/shannoncarter/Documents/JanuaryAdvisors/census-daily-reports")
rm(list = ls(all = T))

## Load required packages
require(tidyverse)
require(httr)
require(jsonlite)
require(leaflet)
require(sf)
require(tigris)

options(stringsAsFactors = FALSE)

## Load auxiliary data
kinder_crosswalk <- read.csv("kinder_cta_crosswalk.csv", header = T)
kinder_crosswalk$GEOID10 <- as.character(kinder_crosswalk$GEOID10)

###--- PULL DATA VIA API -----------------------------------------

# https://api.census.gov/data/2020/dec/responserate.html

# Harris County tracts 
root <- "https://api.census.gov/data/2020/dec/responserate"
search <- "?get=DRRALL,CRRINT,RESP_DATE,CRRALL,GEO_ID,DRRINT&for=tract:*&in=state:48&in=county:201&key="
key <- Sys.getenv("CENSUS_API_KEY")
get_data <- GET(url=paste0(root, search, key))
get_json <- content(get_data, "text")
read_data <- fromJSON(get_json, flatten = TRUE) 
colnames(read_data) = read_data[1, ]
read_data = read_data[-1, ]   
df <- as.data.frame(read_data)
df <- select(df, 
             date = RESP_DATE, GEOID10 = GEO_ID, tract = tract,
             daily_all = DRRALL, daily_int = DRRINT, 
             cumulative_all = CRRALL, cumulative_int = CRRINT) %>% 
  separate(GEOID10, into = c(NA, "GEOID10"), sep = "S") 

df_kinder <- left_join(df, kinder_crosswalk)
df_kinder$cumulative_all <- as.numeric(df_kinder$cumulative_all)

shape <- block_groups("48", "201", cb = T)
shape <- st_as_sf(shape)
df_kinder$GEOID <- df_kinder$GEOID10

df$GEOID <- df$GEOID10
df_spatial <- left_join(shape, df)
df_spatial <- st_as_sf(df_spatial) 

palette1 <- colorBin("Reds", bins = 5, domain = df_spatial$cumulative_all, na.color = "#949292")
testing <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  setView(-95.31, 29.77, zoom = 9) %>% 
  addPolygons(
    data = df_spatial,
    color = 'white',
    weight = 1,
    fillColor = palette1(df_spatial$cumulative_all)
    )
testing


  
