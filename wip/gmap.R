######### Google maps API web app #########
# Generates input csv for a fusion table  #
# to be used with google maps API.        #
###########################################
library("dplyr")
source("R/functions.R")

houses <- loadHouses()

## sector KML
kml <- read.csv("gmap/UK postcode districts.csv")
length(unique(houses$sector))
kml <- kml[kml[,1] %in% unique(houses$district),]

k <- group_by(houses, district) %>% 
  filter(district %in% kml[,1]) %>%
  summarise(median=median(Price), number=n(),
            newbuilds=length(Newbuild[Newbuild == "Y"]),
            min=min(Price), max=max(Price),
            mean=round(mean(Price), -3))

# match order of k and kml
k <- k[match( as.character(kml[,1]), k$district ),]
k$kml <- paste0("\"", kml[,2], "\"")
k$median <- round(k$median, -3)
write.csv(k, "gmap/fusion_kml.csv", row.names=F, quote=F)
