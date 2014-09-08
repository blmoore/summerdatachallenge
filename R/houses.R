## Predict where house prices will increase
## using data from other datasets. Interest
## would be from: 1) REITs 2) zoopla etc.
library("dplyr")
library("ggplot2")
#devtools::install_github("blmR", "blmoore")
library("blmR")

houses <- read.csv("houseprices/london2009-2014-house-prices//Houseprice_2009_100km_London.csv", stringsAsFactors=F)

houses$Price <- as.numeric(gsub("_", "", houses$Price))
houses$Trdate <- as.Date(houses$Trdate)

# how have house prices changed over time
#ggplot(houses[sample(1:nrow(houses), 1e5),], 
#       aes(x=Trdate, y=Price, col=Property_Type)) +
#  geom_point() + scale_y_log10()

# area level (e.g. NW)
houses$area <- factor(gsub("^(\\D+?)\\d.*", "\\1", as.character(houses$Postcode)))

# district (e.g. NW9)
houses$district <- factor(do.call(rbind, strsplit(houses$Postcode, " "))[,1])

# sector (e.g. NW9 6)
houses$sector <- paste(as.character(houses$district),
  gsub(".*?\\s(\\d+).+", "\\1", houses$Postcode), sep=" ")

h2 <- group_by(houses, district) %>%
  filter(n() > 5e3)

plot.district <- function(){
  options(scipen=99)
  # view per district price changes
  ggplot(h2, aes(x=Trdate, y=Price/1e3, fill=district)) +
    #facet_wrap(~district, scales="free_y") +
    geom_smooth(method="auto", col=I("grey20")) +
    scale_fill_brewer(palette="Paired") +
    theme_blm() + 
    labs(x="", y="Price (£k)", fill="Postcode")
  
  ggplot(h2, aes(x=Trdate, y=Price/1e3, fill=district)) +
    #facet_wrap(~district, scales="free_y") +
    geom_smooth(method="auto", col=I("grey20")) +
    scale_fill_brewer(palette="Paired") +
    theme_blm() + 
    labs(x="", y="Price (£k)", fill="Postcode")
  
  invisible()
}

# test post code
# hist(table(h2$))
# hist(table(h2$pc1))
# hist(table(h2$pc2))

ggplot(subset(houses, district == "SW6"), 
        aes(x=Trdate, y=Price/1e3)) +
  geom_point() + geom_smooth(method="lm") +
  geom_smooth()

## instead of time series, aggregate into weekly or monthly 
## prices and rolling median 

houses$month <- months(houses$Trdate)
houses$yearmon <- as.factor(as.yearmon(houses$Trdate))

h3 <- houses %>% group_by(area, district, yearmon) %>%
    filter(n() > 1e2) %>%
  summarise(median=median(Price))

## monthly hi - low - max like open close of stocks?
h3$yearmon <- as.Date(as.character(paste("1", h3$yearmon)), format="%d %B %Y")

ggplot(h3, aes(x=yearmon, y=median, col=area)) +
  facet_wrap(~area, scales="free_y") +
  geom_line()
