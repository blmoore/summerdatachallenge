## Predict where house prices will increase
## using data from other datasets. Interest
## would be from: 1) REITs 2) zoopla etc.
library("dplyr")
library("ggplot2")
library(
#devtools::install_github("blmR", "blmoore")
library("blmR")

houses <- read.csv("houseprices/london2009-2014-house-prices//Houseprice_2009_100km_London.csv", stringsAsFactors=F)

str(houses)

houses$Price <- as.numeric(gsub("_", "", houses$Price))
houses$Trdate <- as.Date(houses$Trdate)

ggplot(houses[sample(1:nrow(houses), 1e5),], 
       aes(x=Trdate, y=Price, col=Property_Type)) +
  geom_point() + scale_y_log10()

houses$pc1 <- factor(do.call(rbind, strsplit(houses$Postcode, " "))[,1])
houses$pc2 <- factor(gsub("(\\D+?)\\d*", "\\1", as.character(houses$pc1)))

h2 <- group_by(houses, pc2) %>%
  filter(n() > 2e4)

options(scipen=99)
ggplot(h2, aes(x=Trdate, y=Price/1e3, fill=pc2)) +
  geom_smooth(method="auto", col=I("grey20")) +
  scale_fill_brewer(palette="Set2") +
  theme_blm() + 
  labs(x="", y="Price (£k)", fill="Postcode")

 # scale_y_continuous(breaks=c(1e4, 5e4, 1e5, 5e5, 6e5, 7e5, 1e6, 5e6, 2e7))

