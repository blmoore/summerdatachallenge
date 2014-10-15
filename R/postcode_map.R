######### Overview visualisation:: Web gifs #########
library("ggmap")
source("R/functions.R")

houses <- loadHouses()

lat.min <- min(houses$Latitude)
lat.max <- max(houses$Latitude)
long.min <- min(houses$Longitude)
long.max <- max(houses$Longitude)

map <- get_map(location="London", zoom=8, maptype="toner", color="bw", source="stamen")
p1 <- ggmap(map, extent="device", darken=.6)

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
             col="white", family="mono") +
    scale_alpha_continuous(range=c(.2, .45))
    ggsave(paste0("plots/seq/", getfn(ym), ".png"), width=2.5, height=2.5)
}

## stitch pngs to gif w/ imagemagick
## http://ubuntuforums.org/showthread.php?t=1132058
## convert -delay 13 -loop 0 *.png -resize 60% animated2.gif
## or something more exotic, median filtering, etc.:
## convert -delay 10 -loop 0 *.png -median 5x5 animated3.gif
system("convert -delay 13 -loop 0 plots/seq/*.png -resize 60% plots/gifs/all.gif")

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

system("convert -delay 13 -loop 0 plots/seq2/*.png -resize 60% plots/gifs/london.gif")

