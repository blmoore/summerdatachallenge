library("dplyr")
library("ggplot2")
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


sw18 <- subset(houses, district == "SW18")
ggplot(sw18, aes(x=Trdate, y=Price, col=Newbuild)) +
  facet_wrap(~Newbuild) +
  #geom_point() + 
  geom_smooth(method="lm")


counts <- group_by(houses, Postcode) %>% summarise(count=n())
ggplot(counts, aes(x=count)) + 
  stat_ecdf(geom="line") +
  scale_x_log10()

dcounts <- group_by(houses, district) %>% summarise(count=n())
ggplot(dcounts, aes(x=count)) + 
  stat_ecdf(geom="line") +
  scale_x_log10()

ggplot(houses, aes(x=Newbuild, y=Trdate)) +
  geom_violin()
  
ggplot(houses, aes(x=Trdate, y=Price)) +
  facet_wrap(~Newbuild)

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

smod <- loess(Price ~ as.numeric(Trdate), data=sw18)
months <- seq(min(sw18$Trdate), max(sw18$Trdate), by="quarter")
cat(paste0(signif(predict(smod, as.numeric(months)), 3), sep=","))

amod <- loess(Price ~ as.numeric(Trdate), 
              data=houses[sample(1:nrow(houses), 1e5),])
cat(paste0(signif(predict(amod, as.numeric(months)), 3), sep=","))

## statis plots for now:
