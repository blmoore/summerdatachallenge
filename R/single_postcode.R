library("dplyr")
library("ggplot2")
library("RColorBrewer")
library("reshape2")
source("R/functions.R")
options(scipen=99)

## Cases per regions       Cases  Median n
## Area (CB):                 45     29500
## District (CB21):          771      1660
## Sector (CB21 6):         2640       511
## Postocde (CB21 6XA):   305958         3

# EC2Y 9AP - 228 house sales over 5 year period

# SE1 6EG - 124
top <- sort(table(houses$district), decreasing=T)
head(top)

# say you're looking at a house in: SW18 4HU 

sw18 <- subset(houses, district == "SW18")
sw184 <- subset(houses, sector == "SW18 4")

# polar co-ord chart, month on month
library("zoo")
z <- zoo(houses$Price, houses$yearmon)
houses$rollmed <- rollmedian(z, 3, fill=NA)

sw18 <- subset(houses, district == "SW18")
ggplot(sw18, aes(x=Trdate, y=Price)) +
  geom_point(alpha=I(.2)) +
  #scale_y_log10() +
  geom_smooth(method="loess") +
  coord_cartesian(ylim=c(quantile(sw18$Price, .05), 
                         quantile(sw18$Price, .95)))


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

#qs <- data.frame(time=quarts, sw18=sw18.q, sw=sw.q, london=l.q, all=all.q)
#qs <- melt(qs, id.vars="time")

cols <- rev(brewer.pal(5, "Blues")[-1])
# last two: grey shaded
cols <- c(cols, "grey60", "grey80")

library("directlabels")
qs$area <- factor(qs$area, 
            levels=c("SW18 4HU", "SW18 4", "SW18", "SW", "London", "South-East"))

## static plots for now:
pdf("plots/sw18.pdf", 5.5, 5.5)
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


## compare with other postcodes in SW18 4:
ggplot(sw184, aes(x=Trdate, y=Price, col=Postcode)) +
  geom_smooth(method="lm") + geom_point()

pcsummary <- group_by(sw184, Postcode) %>% 
  summarise(sales=n(), med=median(Price))

ggplot(pcsummary, aes(y=med/1e3, x=sales,
                      size=ifelse(Postcode == "SW18 4HU", 1, 0))) +
  geom_point() + theme_sdc() +
  theme(legend.position="none") +
  scale_size_continuous(range=c(2, 5)) +
  labs(x="5yr house sales", y="Median sale price (000s £)")


ggplot(pcsummary, aes(x=med/1e3)) +
  geom_density(fill=I(rgb(239, 245, 249, max=255)),
               col=I(rgb(175,205,226, max=255))) + theme_sdc() +
  geom_vline(xintercept=median(sw184[sw184$Postcode == "SW18 4HU",]$Price)/1e3,
             col=rgb(39, 109, 175, max=255)) +
  theme(axis.ticks = element_blank(), 
        axis.title.y = element_blank(), 
        axis.text.y =  element_blank()) +
  labs(x="5yr house sales (median price, 000s £)")


