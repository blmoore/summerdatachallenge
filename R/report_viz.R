source("R/functions.R")

houses <- loadHouses()


library("ggmap")
map <- get_map(location="London", zoom=8, maptype="toner", color="bw", source="stamen")
p1 <- ggmap(map, extent="device", darken=.6)
p1 + geom_point(data=houses[sample(1:nrow(houses), 1e5),], 
                aes(x=Longitude, y=Latitude, alpha=log10(Price)), col="white") +
  scale_alpha_continuous(range=c(.01, .2)) +
  labs(x="", y="") + theme(legend.position="none") 

p1+ geom_point(data=houses[houses$yearmon == levels(houses$yearmon)[ym],], 
                  aes(x=Longitude, y=Latitude, alpha=log10(log10(Price))), 
                  col="white", size=.3) + 
    labs(x="", y="") + 
    theme(legend.position="none",
          axis.ticks = element_blank(), axis.text.x = element_blank(),
          axis.text.y = element_blank()) +
    annotate("text", x=.8, y=50.5, label=levels(houses$yearmon)[ym], 
             col="white", family="mono") +
    scale_alpha_continuous(range=c(.2, .45))