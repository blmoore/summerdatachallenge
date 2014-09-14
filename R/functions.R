## Repo of functions for use across scripts
library("gpclib")
library("ggplot2")
library("mapdata")
library("maps")
library("maptools")
library("rgeos")
library("zoo")

loadHouses <- function(){
  h <- read.csv("houseprices/london2009-2014-house-prices//Houseprice_2009_100km_London.csv", 
                stringsAsFactors=F)
  
  # remove underscores, convert to number
  h$Price <- as.numeric(gsub("_", "", h$Price))
  h$Trdate <- as.Date(h$Trdate)
  
  # area level (e.g. NW)
  h$area <- factor(gsub("^(\\D+?)\\d.*", "\\1", as.character(h$Postcode)))
  
  # district (e.g. NW9)
  h$district <- factor(do.call(rbind, strsplit(h$Postcode, " "))[,1])
  
  # sector (e.g. NW9 6)
  h$sector <- paste(as.character(h$district),
                    gsub(".*?\\s(\\d+).+", "\\1", h$Postcode), sep=" ")
  
  h$month <- months(h$Trdate)
  h$yearmon <- as.factor(as.yearmon(h$Trdate))
  
  return(h)
}

