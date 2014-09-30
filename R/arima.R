## ARIMA forecasting
library("dplyr")
library("forecast")
library("ggplot2")
library("zoo")

s <- sw184[sw184$Postcode == "SW18 4HU",]
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
  annotate("text", x=as.Date("2010-06-01"), size=8,
           y=650, label="SW18 4HU", col=I("grey40"))
dev.off()

