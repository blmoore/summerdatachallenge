## ARIMA forecasting
library("dplyr")
library("forecast")
library("ggplot2")
library("gridExtra")
library("zoo")
source("R/functions.R")

houses <- loadHouses()

## Background work, time series munging and tests
s <- sw184
s <- group_by(s, Month) %>% summarise(median=median(Price))

# n.b. non-stationary time series

# check for (partial) auto-correlation, look at detrended etc.
plot(swpc, lag(swpc, 12))

# no detectable periodicity in monthly data
decompose(swpc)
seasadj(stl(swpc))

# residuals OK; pacf, acf PASS
tsdisplay(diff(swpc))

# positive reasonably linear trend, can be detrended
m <- lm(coredata(swpc) ~ index(swpc))
detr <- zoo(resid(m), index(swpc))
plot(swpc)
plot(detr)
decompose(detr)

## ARIMA model fitting and forecasting
swpc <- ts(s$median, as.numeric(as.yearmon(s$Month)))

aa <- auto.arima(swpc)
plot(swpc)
lines(fitted(aa), col="blue")
plot(forecast(aa, h=12), axes=F, main="ARIMA drift forecasts")
lines(swpc)

summary(aa)
summary(forecast(aa, h=12))

f <- forecast(aa, h=12)
fore <- as.data.frame(f)

#starting dates:
sdates <- as.Date(paste0(s$Month,"-01"))
newdates <- seq(sdates[length(sdates)]+31, length.out=12, by="month")

sdf <- s
sdf$type <- "measured"
sdf$Month <- sdates

new <- data.frame(Month=newdates, median=fore$`Point Forecast`, 
                  type="forecast")
pdf <- rbind(sdf, new)

vars <- data.frame(Month=new$Month, 
                   l80=fore$`Lo 80`,
                   l95=fore$`Lo 95`,
                   h80=fore$`Hi 80`,
                   h95=fore$`Hi 95`)

afit <- data.frame(Month=sdf$Month, median=as.vector(fitted(aa)))

pdf$type <- factor(pdf$type, levels=c("measured", "forecast"))

## hacky ggplot abuse
pdf("plots/forecast.pdf", 5, 3)
ggplot(pdf, aes(x=Month, y=median/1e3)) +
  geom_point(data=subset(pdf, type=="measured")) +
  geom_line(data=subset(pdf, type=="forecast")) + theme_sdc() +
  #scale_color_manual() +
  # arima model fit
  geom_line(data=afit, col=I("grey40"), linetype=2) +
  # forecase bounds
  geom_ribbon(data=vars, inherit.aes=F,
              aes(x=Month, ymin=l80/1e3, ymax=h80/1e3),
              alpha=I(.2)) +
  geom_ribbon(data=vars, inherit.aes=F,
              aes(x=Month, ymin=l95/1e3, ymax=h95/1e3),
              alpha=I(.1)) +
  labs(y="Median house price (£k)", x="") +
  theme(legend.position=c(.2,.8)) +
  annotate("text", x=as.Date("2010-01-01"), size=8,
           y=550, label="SW18 4", col=I("grey40"))
dev.off()


plotForecast <- function(out){
  pdf <- out$pdf
  afit <- out$fit
  vars <- out$var
  
  p <- ggplot(pdf, aes(x=Month, y=median/1e3)) +
    geom_point(data=subset(pdf, type=="measured")) +
    geom_line(data=subset(pdf, type=="forecast")) + theme_sdc() +
    #scale_color_manual() +
    # arima model fit
    geom_line(data=afit, col=I("grey40"), linetype=2) +
    # forecase bounds
    geom_ribbon(data=vars, inherit.aes=F,
                aes(x=Month, ymin=l80/1e3, ymax=h80/1e3),
                alpha=I(.2)) +
    geom_ribbon(data=vars, inherit.aes=F,
                aes(x=Month, ymin=l95/1e3, ymax=h95/1e3),
                alpha=I(.1)) +
    #labs(y="Median house price (£k)", x="") +
    labs(y="", x="") + 
    # axes hack: min of forecast min or otherwise
    ylim(min(c(min(vars$l95/1e3),min(pdf$median/1e3)*.95)), 
         max(c(max(vars$h95/1e3), max(pdf$median/1e3)*1.15))) +
    theme(legend.position=c(.2,.8)) +
    annotate("text", x=as.Date("2010-01-01"), size=7,
             y=max(pdf$median/1e3)*1.1, label=unique(pdf$pc), col=I("grey40"))
  p
}

modelHPs <- function(sector){
  #sector="W6 7"
  data <- houses[houses$sector == sector,]
  data <- group_by(data, Month) %>% summarise(median=median(Price))
  data.ts <- ts(data$median, as.numeric(as.yearmon(data$Month)))
  arima <- auto.arima(data.ts)
  # inspect fit
  # summary(arima)
  f <- forecast(arima, h=12)
  fore <- as.data.frame(f)
  
  #starting dates:
  sdates <- as.Date(paste0(data$Month,"-01"))
  newdates <- seq(sdates[length(sdates)], length.out=13, by="month")[-1]
  data$type <- "measured"
  data$Month <- sdates
  
  new <- data.frame(Month=newdates, median=fore$`Point Forecast`, 
                    type="forecast")
  pdf <- rbind(data, new)
  vars <- data.frame(Month=new$Month, 
                     l80=fore$`Lo 80`,
                     l95=fore$`Lo 95`,
                     h80=fore$`Hi 80`,
                     h95=fore$`Hi 95`)
  
  afit <- data.frame(Month=data$Month, median=as.vector(fitted(arima)))
  pdf$type <- factor(pdf$type, levels=c("measured", "forecast"))
  pdf$pc <- sector
  return(plotForecast(list(pdf=pdf, fit=afit, var=vars)))
}

# random selection of sectors:
set.seed(42)
sectors <- c("SW18 4", sample(houses$sector, 15))

l <- lapply(sectors, modelHPs)

svg("plots/grid_forecasts.svg", 16, 10)
do.call(grid.arrange, l)
dev.off()


