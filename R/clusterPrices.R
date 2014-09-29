source("R/functions.R")
set.seed(2)

## cluster monthly price change profiles
houses <- loadHouses()


# sample 20 random postcodes for clustering
# redraw london as clustered by price
pclist <- unique(houses$sector)
pclist <- pclist[sample(1:length(pclist), 20)]

sub <- houses[houses$sector %in% pclist,]

ggplot(sub, aes(x=yearmon, y=Price/1e3, group=sector)) +
  geom_smooth(method="loess") + geom_point() +
  facet_wrap(~sector, ncol=5, scales="free_y") +
  theme_sdc()
