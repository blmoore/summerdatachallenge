source("R/functions.R")

houses <- loadHouses()

# grad 10 points for heatmap
ll <- houses[sample(1:nrow(houses), 2000),c("Latitude", "Longitude", "Price")]
ll[,1:2] <- apply(ll[,1:2], 2, round, digits=2)

weights <- round(log10(ll$Price), digits=1)
weights <- weights - min(weights) + 1

raw <- 
  paste0("{location: new google.maps.LatLng(", 
         ll[,1], ", ", ll[,2], "), weight:", weights, "},")


clip <- pipe("pbcopy", "w")
write(raw, file=clip)
close(clip)

set.seed(42)
options(scipen=99)
h <- houses[,c("Latitude", "Longitude", "Price", "Trdate")]
colnames(h)[4] <- "Date"
write.csv(h, "gmap/fusiondata_full.csv", row.names=F)

## sector KML
kml <- read.csv("gmap/UK postcode districts.csv")
length(unique(houses$sector))
kml <- kml[kml[,1] %in% unique(houses$district),]

library("dplyr")
k <- group_by(houses, district) %>% 
  filter(district %in% kml[,1]) %>%
  summarise(median=median(Price), number=n(),
            newbuilds=length(Newbuild[Newbuild == "Y"]),
            min=min(Price), max=max(Price))

# match order (AL10 195000)
k <- k[match( as.character(kml[,1]), k$district ),]
k$kml <- paste0("\"", kml[,2], "\"")
k$median <- round(k$median, -3)
write.csv(k, "gmap/fusion_kml.csv", row.names=F, quote=F)
