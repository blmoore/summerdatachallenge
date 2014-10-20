# ##########################################################
# ----------------- Investment Grading ------------------- #
#                                                          #
# Pre-compute stats for all sectors:                       #
#                                                          #
#   1) growth:     signed % change from start of forecast  #
#                  to end (12 months later)                #
#   2) volatility: how valitile has the price been over    #
#                  the last 5 years                        #
#                                                          #
# Find all as a quantile of all sectors, mean could then   #
# be its "investment grade" depending on its distribution. #
############################################################
library("dplyr")
library("forecast")
library("ggplot2")
library("parallel")
library("zoo")
source("R/functions.R")

houses <- loadHouses()

growth <- function(sector){
  data <- houses[houses$sector == sector,]
  data <- group_by(data, Month) %>% summarise(median=median(Price))
  data.ts <- ts(data$median, as.numeric(as.yearmon(data$Month)))
  arima <- auto.arima(data.ts, allowdrift=T)
#  f <- as.data.frame(forecast(arima, h=12))
  #s.e <- fore$`Point Forecast`[c(1, 12)]
  
  # percentage change over forecast
  #100*((s.e[2] - s.e[1]) / s.e[1])
 # message(coef(arima))
  if("drift" %in% names(coef(arima))){
    return(coef(arima)[["drift"]])
  } else {
    return(0L)
  }
}

growth <- Vectorize(growth)

# cut out some secots with too few datapoints
secs <- group_by(houses, sector) %>% 
  summarise(counts=n()) %>% filter(counts > 500)

df <- data.frame(sector=secs$sector)

## takes ~ 5 mins to run on 8 cores
df$growth <- pvec(as.vector(df$sector), growth, mc.cores=8)

## convert raw growth vals to quantiles
df$growth.q <- ecdf(df$growth)(df$growth)

volatility <- function(sector){
  data <- houses[houses$sector == sector,]
  data <- group_by(data, Month) %>% summarise(median=median(Price))
  
  # calculate log return on assets:
  r.log <- log(data$median[-1] / data$median[-nrow(data)])
  # Historial annualised volatility
  sd(r.log) * sqrt(12) 
}

volatility <- Vectorize(volatility)

# vectorised + parallelised over 8 cores
df$vol <- pvec(as.vector(df$sector), volatility, mc.cores=8)
df$vol.q <- 1 - ecdf(df$vol)(df$vol)

df$sum <- rowSums(df[,c("growth.q", "vol.q")])
# combined vol and growth rank
df$rank <- rank(-df$sum)

grades <- c("AAA", "AA", "A", "BBB", "BB", "B", "CCC", "CC", "C")
qs <- quantile(df$rank, seq(0, 1, length.out=length(grades)))
df$letter <- with(df, ifelse(rank < qs[2], grades[1],
                             ifelse(rank < qs[3], grades[2],
                                    ifelse(rank < qs[4], grades[3],
                                           ifelse(rank < qs[5], grades[4],
                                                  ifelse(rank < qs[6], grades[5],
   ifelse(rank < qs[7], grades[6], ifelse(rank < qs[8], grades[7],
      ifelse(rank < qs[9], grades[8], grades[9])))))))))

top.grades <- df[df$letter == "AAA",]

top.grades <- top.grades[order(top.grades$rank),]
toplot <- top.grades[1:5,"sector"]
l <- lapply(toplot, modelHPs)
do.call(grid.arrange, l)

svg("plots/top5_investments.svg", 8, 7)
do.call(grid.arrange, l)
dev.off()


df <- df[,c(1,2,4,3,5,8,6:7)]
saveRDS(df, "rds/invest_grade2.rds")


