#require(devtools)
#install_github('ramnathv/rCharts')
library("rCharts")
df <- readRDS("rds//invest_grade2.rds")

dfi <- df[df$growth >0,]
dfi$growth.q <- ecdf(dfi$growth)(dfi$growth)

colnames(dfi)
colnames(dfi)[6] <- "Grade"
colnames(dfi)[4] <- "Growth.quantile"
colnames(dfi)[5] <- "Volatility.quantile"

dfi[,2:5] <- apply(dfi[,2:5], 2, round, digits=2)
dfi$rank <- NULL
dfi$sum <- NULL

d <- dPlot(Growth.quantile ~ Volatility.quantile, type="bubble", data=dfi,
      col="Grade", height=450, width=450, groups=c("sector", "Grade"))
d$xAxis(type = "addMeasureAxis")
d$yAxis(type = "addMeasureAxis")
d

d$publish()


colnames(dfi)[2:3] <- c("Monthly.growth", "Historical.volatility")
dfii <- dfi[,c(1:6)]
d2 <- dPlot(Monthly.growth ~ Historical.volatility, type="bubble", data=dfii,
           col="Grade", height=450, width=450, groups=c("sector", "Grade"))
d2$xAxis(type = "addMeasureAxis")
#d2$xAxis(type  = "addLogAxis", overrideMin=.2, overrideMax=5)
d2$yAxis(type = "addMeasureAxis")
#d2$yAxis(type = "addLogAxis", overrideMin=10)
d2
d2$publish()


