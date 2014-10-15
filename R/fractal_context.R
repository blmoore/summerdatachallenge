library("directlabels")
library("dplyr")
library("RColorBrewer")
library("reshape2")
library("rgdal")
library("rgeos")
source("R/functions.R")
options(scipen=99)

## Cases per regions       Cases  Median n
## Area (CB):                 45     29500
## District (CB21):          771      1660
## Sector (CB21 6):         2640       511
## Postocde (CB21 6XA):   305958         3

top <- sort(table(houses$district), decreasing=T)
head(top)

# say you're looking at a house in: SW18 4HU 
sw18 <- subset(houses, district == "SW18")
sw184 <- subset(houses, sector == "SW18 4")

modelArea <- function(data, dates, label){
  if (nrow(data) > 2e4){
    out <- loess(Price ~ as.numeric(Trdate), 
                 data=data[sample(1:nrow(data), 2e4),])
  } else {
    out <- loess(Price ~ as.numeric(Trdate), data)
  }
  p <- predict(out, as.numeric(dates), se=T)
  p <- with(p, cbind(fit, se.fit))
  return(data.frame(time=dates, area=label, p))
}

quarts <- seq(min(houses$Trdate), max(houses$Trdate), by="quarter")

# london postcode areas
london <- c("N", "NW", "E", "EC", "SE", "SW", "WC", "W")
ldn <- subset(houses, area %in% london)

london.res <- modelArea(ldn, quarts, "London")
sw.res <- modelArea(subset(houses, area == "SW"), quarts, "SW")
sw18.res <- modelArea(sw18, quarts, "SW18")
sw184.res <- modelArea(sw184, quarts, "SW18 4")
sw184hu.res <- modelArea(subset(sw184, Postcode == "SW18 4HU"),
                         quarts, "SW18 4HU")
all.res <- modelArea(houses, quarts, "South-East")

qs <- rbind(london.res, sw.res, sw18.res, sw184.res, sw184hu.res, all.res)

# Generate color palette w/ last two: grey shaded
cols <- rev(brewer.pal(5, "Blues")[-1])
cols <- c(cols, "grey60", "grey80")

qs$area <- factor(qs$area, 
            levels=c("SW18 4HU", "SW18 4", "SW18", "SW", "London", "South-East"))

## Loess models for each area heirarchy (web)
pdf("plots/PostcodeLevelsLoess.pdf", 5.5, 5.5)
ggplot(qs, aes(x=time, y=fit/1000, col=area, fill=area)) +
  geom_ribbon(aes(ymin=(fit/1000) - (se.fit/1000),
                  ymax=(fit/1000) + (se.fit/1000)),
              alpha=I(.2), col=NA) +
  geom_line() + geom_point() + theme_sdc() +
  theme(legend.position="none") +
  labs(y="Trended house sales (000s £)",
       col="", x="", fill="") +
  scale_color_manual(values=cols) +
  scale_fill_manual(values=cols) +
  geom_dl(aes(label=area), list("smart.grid", cex=1.3)) +
  annotate("text", x=as.Date("2010-02-01"), y=780, 
           label="SW18 4HU", size=7, col=I("grey50"))
dev.off()

pcsummary <- group_by(sw184, Postcode) %>% 
  summarise(sales=n(), med=median(Price))

## Number sales vs. median prices
ggplot(pcsummary, aes(y=med/1e3, x=sales,
                      size=ifelse(Postcode == "SW18 4HU", 1, 0))) +
  geom_point() + theme_sdc() +
  theme(legend.position="none") +
  scale_size_continuous(range=c(2, 5)) +
  labs(x="5yr house sales", y="Median sale price (000s £)")

## SW18 4** density plot, w/ SW18 4HU marked
pdf("plots/FC3_SectorDistribution.pdf", 4, 2)
ggplot(pcsummary, aes(x=med/1e3)) +
  geom_density(fill=I(rgb(239, 245, 249, max=255)),
               col=I(rgb(175,205,226, max=255))) + theme_sdc() +
  geom_vline(xintercept=median(sw184[sw184$Postcode == "SW18 4HU",]$Price)/1e3,
             col=rgb(39, 109, 175, max=255)) +
  theme(axis.ticks = element_blank(), 
        axis.title.y = element_blank(), 
        axis.text.y =  element_blank()) +
  labs(x="5yr house sales (median price, 000s £)") +
  annotate("text", x=750, y=4e-3, label="SW18 4", col=I("grey30"), size=6)
dev.off()

# for ordering
sw18.s <- group_by(sw18, sector) %>%
  summarise(med=median(Price))
sw18.s <- sw18.s[order(sw18.s$med),]

# order by median sale
sw18$sector <- factor(sw18$sector, levels=sw18.s$sector)

pdf("plots/FC2_DistrictDistribution.pdf", 5, 3.5)
ggplot(sw18, aes(x=sector, y=Price/1e3)) +
  geom_violin(fill=I(rgb(239, 245, 249, max=255)),
              col=I(rgb(175,205,226, max=255))) + 
                geom_jitter(alpha=I(.35), col=I("grey80"), size=I(.8)) +
  theme_sdc() + scale_y_log10(breaks=c(100,250,500,1000,2500,5000)) +
  labs(y="House sales (000s £)", x="") +
  annotate("text", x="SW18 4", y=7.5e3, label="SW18", col=I("grey40"), size=6)
dev.off()

# London areas
london.s <- group_by(ldn, area) %>% 
  summarise(med=median(Price))
london.s <- london.s[order(london.s$med),]
ldn$area <- factor(ldn$area, levels=(london.s$area))

pdf("plots/FC0_LondonAreas.pdf", 3.5, 5)
ggplot(ldn, aes(x=area, y=Price/1e3)) +
  geom_violin(fill=I(rgb(203, 212, 231, max=255)),
              col=I(rgb(175,205,226, max=255)),
              scale="width") + 
  #geom_jitter(alpha=I(.35), col=I("grey80"), size=I(.8)) +
  theme_sdc() + scale_y_log10(breaks=c(50,100,500,1000,5000), 
                              limits=c(80, 10000)) +
  labs(y="House prices (000s £)", x="") +
  geom_crossbar(data=london.s, inherit.aes=F, aes(x=area, y=med/1e3,
                                                  ymin=med/1e3, max=med/1e3),
             col=rgb(12, 61, 137, max=255), width=I(.65)) +
  coord_flip() + 
  geom_text(data=london.s, inherit.aes=F, aes(x=area, y=(med/1e3)*.75,
                                              label=area),
            color=I(rgb(12, 61, 137, max=255)), size=3) +
  theme(axis.text.y=element_blank())
dev.off()

# from : https://en.wikipedia.org/wiki/SW_postcode_area
swmap <- readOGR("R/sw.kml", "SW")
swggmap <- fortify(swmap)

# group translates to postcode, get these via:
#    sed -e 's,.*<name>\([^<]*\)</name>.*,\1,g' sw.kml 
g2pc <- c("SW1A", "SW1E", "SW1H", "SW1P", "SW1V", "SW1W", 
          "SW1X", "SW1Y", "SW2", "SW3", "SW4", "SW5", "SW6", 
          "SW7", "SW8", "SW9", "SW10", "SW11", "SW12", "SW13", 
          "SW14", "SW15", "SW16", "SW17", "SW18", "SW19", "SW20")

# munge and plot
sw <- subset(houses, area == "SW")
district.s <- group_by(sw, district) %>%
  summarise(m=median(Price))
district.s <- district.s[match(g2pc, district.s$district),]
swggmap$fcol <- rep(district.s$m, rle(as.character(swggmap$group))$lengths)

# map polygon w/ colours
svg("plots/FC1_AreaMap.svg", 4.5, 3)
ggplot(swggmap) + 
  geom_polygon(aes(x=long, y=lat, group=id, fill=fcol/1e3), col="white") +
  #scale_colour_manual(values=c(rep("white", 24), "black", "white", "white")) +
  scale_fill_gradientn(trans="log", colours=brewer.pal(9, "Blues")[-1],
                       breaks=c(1e2, 5e2, 1e3, 5e3)) +
  new_theme_empty + labs(fill="5yr median \nhouse prices (£k)")
dev.off()
