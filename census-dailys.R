###=== CENSUS DAILY RESPONSE REPORT ===============================

###--- PREP WORKSPACE ---------------------------------------------

## Set working directory and clear memory
setwd("/Users/shannoncarter/Documents/JanuaryAdvisors/census-daily-reports")
rm(list = ls(all = T))

## Load required packages
require(tidyverse)
require(httr)
require(jsonlite)

options(stringsAsFactors = FALSE)

###--- PULL DATA VIA API -----------------------------------------

# https://api.census.gov/data/2020/dec/responserate.html
# pull tract level response rates each day

# https://www.r-bloggers.com/accessing-apis-from-r-and-a-little-r-programming/

url  <- "http://api.census.gov/data/2020/dec/responserate.html"
path <- "census-daily-reports"

raw.result <- GET(url = url, path = path)
raw.result$status_code # whoops

this.raw.content <- rawToChar(raw.result$content)
this.content <- fromJSON(this.raw.content)
