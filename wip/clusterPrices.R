### Unused preliminary clustering work
library("dtw")
library("gplots")
library("pvclust")
library("RColorBrewer")
library("reshape2")
library("snow")
library("TSclust")
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

hm <- dcast(houses, sector ~ yearmon, 
            fun.aggregate=median, value.var="Price")

# length reference, mask out low cells
hm.mask <- dcast(houses, sector ~ yearmon,  value.var="Price")

image(log10(as.matrix(hm[,-1])+1))

num.cols=24

row.lab <- rep("", ncol(hm)-1)
row.lab[seq(1, ncol(hm)-1, by=4)] <- colnames(hm)[-1][seq(1, ncol(hm)-1, by=4)]
bl <- colorRampPalette(brewer.pal(9, "Blues"))(num.cols)
# uneven breaks, norm distributed prices
rsc <- as.numeric(factor(gsub("(.*?)\\d+", "\\1", hm[,1])))
rsc <- rsc[complete.cases(hm)]

heatmap.2(log10(as.matrix(hm[complete.cases(hm),-1])), 
          dendrogram="row", trace="none", Colv=NULL,
          col=bl, labRow=F, labCol=row.lab, srtCol=45,
          RowSideColors=heat.colors(max(rsc))[rsc],
          breaks=quantile(log10(houses$Price), seq(0.01, .97, length.out=(num.cols+1))))

ts.dist <- function(x, ...)
  dist(x, method="DTW")


# pre-compute some stuffs
mat <- log10(as.matrix(hm[complete.cases(hm),-1]))
rowcols <- heat.colors(max(rsc))[rsc]
brks <- quantile(log10(houses$Price), seq(0.01, .97, length.out=(num.cols+1)))

heatmap.2(mat, dendrogram="row", trace="none", Colv=NULL,
          distfun=ts.dist, hclustfun=hc, RowSideColors=rowcols,
          col=bl, labRow=F, labCol=row.lab, srtCol=45, breaks=brks)


sax.dist <- function(x, ...)
  # try dist on un-transformed values
  diss(as.matrix(hm[complete.cases(hm),-1]), "DWT", ...)

hc <- function(x, ...)
  hclust(x, method="ward.D")

heatmap.2(mat, dendrogram="row", trace="none", Colv=NULL,
          distfun=sax.dist, hclustfun=hc, RowSideColors=rowcols,
          col=bl, labRow=F, labCol=row.lab, srtCol=45, breaks=brks)

dist.mat <- sax.dist(mat)

cli <- makeCluster(6, type="MPI")
clustered <- parPvclust(cli, t(mat), method.hclust="centroid",
                        method.dist="correlation", nboot=50)
stopCluster(cli)

plot(clustered)
