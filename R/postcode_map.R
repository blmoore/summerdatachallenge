source("R/functions.R")

houses <- loadHouses()

lat.min <- min(houses$Latitude)
lat.max <- max(houses$Latitude)
long.min <- min(houses$Longitude)
long.max <- max(houses$Longitude)

# base graphics data overview
map("worldHires", ".", col="gray90", fill=TRUE, 
    xlim=c(long.min, long.max), ylim=c(lat.min, lat.max))
points(p$longitude, p$latitude, pch=".")

# places <- readShapePoly("england-latest.shp/places.shp")
# as.data.frame(places)
# 
# library("rgdal")
# places <- readOGR(dsn = "england-latest.shp", "waterways") 
# pp <- fortify(places)


library("ggmap")
map <- get_map(location="London", zoom=8, maptype="toner", color="bw", source="stamen")
p1 <- ggmap(map, extent="device", darken=.6)
p1 + geom_point(data=houses[sample(1:nrow(houses), 1e5),], 
                aes(x=Longitude, y=Latitude, alpha=log10(Price)), col="white") +
  scale_alpha_continuous(range=c(.01, .2)) +
  labs(x="", y="") + theme(legend.position="none") 

# filename ordering for (e.g.) imagemagick (yes, 51 not 52)
getfn <- function(n)
  ifelse(n > 51, paste0("zz", letters[n %% 26]), 
         ifelse(n > 26, paste0("z", letters[n %% 26]), letters[n]))


for( ym in 1:65 ){
  # x=1, y=50.5
  p1 + geom_point(data=houses[houses$yearmon == levels(houses$yearmon)[ym],], 
                       aes(x=Longitude, y=Latitude, alpha=log10(log10(Price))), 
                  col="white", size=.3) + 
    labs(x="", y="") + 
    theme(legend.position="none",
          axis.ticks = element_blank(), axis.text.x = element_blank(),
         axis.text.y = element_blank()) +
    annotate("text", x=.8, y=50.5, label=levels(houses$yearmon)[ym], 
             col="white", size=8, family="mono") +
    scale_alpha_continuous(range=c(.2, .45))
    ggsave(paste0("plots/seq/", getfn(ym), ".png"), width=3.5, height=3.5)
}

## stitch pngs to gif w/ imagemagick
## http://ubuntuforums.org/showthread.php?t=1132058
## convert -delay 13 -loop 0 *.png -resize 60% animated2.gif
## or something more exotic, median filtering, etc.:
## convert -delay 10 -loop 0 *.png -median 5x5 animated3.gif
system("convert -delay 13 -loop 0 plots/seq/*.png -resize 60% plots/seq/animated_se.gif")

## Zoom to london only
map2 <- get_map(location="London", zoom=10, maptype="toner", color="bw", source="stamen")
p2 <- ggmap(map2, extent="device", darken=.6)

for( ym in 1:65 ){
  p2 + geom_point(data=houses[houses$yearmon == levels(houses$yearmon)[ym],], 
                  aes(x=Longitude, y=Latitude, alpha=log10(Price)), 
                  col="white", size=.5) + 
    labs(x="", y="") + 
    theme(legend.position="none",
          axis.ticks = element_blank(), axis.text.x = element_blank(),
          axis.text.y = element_blank()) +
  annotate("text", x=.11, y=51.26, label=levels(houses$yearmon)[ym], col="white", family="mono") +
    scale_alpha_continuous(range=c(.3, .6))
  
  ggsave(paste0("plots/seq2/", getfn(ym), ".png"), width=2.5, height=2.5)
}

system("convert -delay 13 -loop 0 plots/seq2/*.png -resize 60% plots/seq/animated_ldn.gif")

