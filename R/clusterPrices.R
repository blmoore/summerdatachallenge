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


head(houses)
library("reshape2")
hm <- dcast(houses, sector ~ yearmon, 
            fun.aggregate=median, value.var="Price")

# length reference, mask out low cells
hm.mask <- dcast(houses, sector ~ yearmon,  value.var="Price")

image(log10(as.matrix(hm[,-1])+1))

library("gplots")
library("RColorBrewer")

row.lab <- rep("", ncol(hm)-1)
row.lab[seq(1, ncol(hm)-1, by=4)] <- colnames(hm)[-1][seq(1, ncol(hm)-1, by=4)]
bl <- colorRampPalette(brewer.pal(9, "Blues"))(64)
# uneven breaks, norm distributed prices
heatmap.2(log10(as.matrix(hm[complete.cases(hm),-1])), 
          dendrogram="row", trace="none", Colv=NULL,
          col=bl, labRow=F, labCol=row.lab, srtCol=45)

