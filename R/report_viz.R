library("ggmap")
source("R/functions.R")
set.seed(42)

houses <- loadHouses()

map <- get_map(location="London", zoom=8, maptype="toner", color="bw", source="stamen")
p1 <- ggmap(map, extent="device", darken=.6)

pdf("plots/report_overview.pdf", 2.5, 2.5)
p1 + geom_point(data=houses[sample(1:nrow(houses), 1e5),], size=I(.2),
                aes(x=Longitude, y=Latitude, alpha=log10(Price)), col="white") +
  scale_alpha_continuous(range=c(.05, .25)) +
  labs(x="", y="") + theme(legend.position="none") 
dev.off()
