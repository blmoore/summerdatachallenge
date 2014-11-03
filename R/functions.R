## Repo of functions for use across scripts
library("gpclib")
library("ggplot2")
library("mapdata")
library("maps")
library("maptools")
library("rgeos")
library("zoo")

loadHouses <- function(){
  h <- read.csv("houseprices/Houseprice_2009_100km_London.csv", 
                stringsAsFactors=F)
  
  # remove underscores, convert to number
  h$Price <- as.numeric(gsub("_", "", h$Price))
  h$Trdate <- as.Date(h$Trdate)
  
  # area level (e.g. NW)
  h$area <- factor(gsub("^(\\D+?)\\d.*", "\\1", as.character(h$Postcode)))
  
  # district (e.g. NW9)
  h$district <- factor(do.call(rbind, strsplit(h$Postcode, " "))[,1])
  
  # sector (e.g. NW9 6)
  h$sector <- paste(as.character(h$district),
                    gsub(".*?\\s(\\d+).+", "\\1", h$Postcode), sep=" ")
  
  h$month <- months(h$Trdate)
  h$yearmon <- as.factor(as.yearmon(h$Trdate))
  
  return(h)
}

## ggplot2 theme

theme_sdc_null <- function(base_size=12, base_family="sans") {
  ## Base courtesy of: https://github.com/jrnold/ggthemes
  theme(
    line = element_line(colour = "grey95", size = 0.5,
                        linetype = 1, lineend = "butt"),
    rect = element_rect(fill = "white", colour = "grey90",
                        size = 0.5, linetype = 1),
    text =  element_text(family = base_family, face = "plain",
                         colour = "grey20", size = base_size,
                         hjust = 0.5, vjust = 0.5, angle = 0, lineheight = 0.9),
    axis.text = element_text(),
    strip.text = element_text(),
    axis.line = element_blank(),
    axis.title = element_text(size=14, face=2),
    axis.title.x = element_text(),
    axis.title.y = element_text(angle=90),
    axis.text = element_text(size=10),
    axis.text.x = element_text(),
    axis.text.y = element_text(),
    axis.ticks = element_line(),
    axis.ticks.x = element_line(),
    axis.ticks.y = element_line(),
    axis.ticks.length =  grid::unit(0.15, "cm"),
    axis.ticks.margin =  grid::unit(0.1, "cm"),
    axis.line = element_line(color="grey80"),
    axis.line.x = element_line(),
    axis.line.y = element_line(),
    legend.background = element_rect(colour = "grey95", fill="grey95"),
    legend.margin = grid::unit(0.2, "cm"),
    legend.key = element_blank(),
    legend.key.size = grid::unit(1.2, "lines"),
    legend.key.height = NULL,
    legend.key.width = NULL,
    legend.text = element_text(),
    legend.text.align = NULL,
    legend.title = element_text(face=2, color="grey25"),
    legend.title.align = .5,
    legend.position = "right",
    legend.direction = NULL,
    legend.justification = "center",
    legend.box = NULL,
    ## Must have colour=NA or covers the plot
    panel.background = element_rect(fill = "transparent", colour = NA),
    panel.border = element_blank(), 
    panel.margin = grid::unit(0.25, "lines"),
    panel.grid = element_line(),
    panel.grid.major = element_line(size=.4),
    panel.grid.major.x = element_line(),
    panel.grid.major.y = element_line(),
    # removed:
    panel.grid.minor = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    ## transparent bg?
    plot.background = element_rect(fill = "transparent", colour = NA),
    plot.title = element_text(color="grey60", face=2, size=20),
    plot.margin = grid::unit(c(1, 1, 0.5, 0.5), "lines"),
    strip.background = element_rect(fill="grey90", color="grey90"),
    strip.text = element_text(color="grey25"),
    strip.text.x = element_text(),
    strip.text.y = element_text(angle = -90),
    complete = TRUE)
}

theme_sdc_sizes <- function() {
  theme(
    axis.text.y = element_text(hjust = 1),
    strip.text = element_text(size = rel(0.8)),
    axis.text = element_text(size = rel(0.8)),
    axis.text.x = element_text(vjust = 1),
    legend.text = element_text(size = rel(0.8)),
    legend.title = element_text(size = rel(0.8), hjust = 0),
    panel.grid.minor = element_line(size = 0.25),
    plot.title = element_text(size = rel(1.2)),
    strip.text.y = element_text(angle = -90)
  )
}

theme_sdc <- function(base_size=12, base_family="", use_sizes=TRUE) {
  thm <- theme_sdc_null(base_size=base_size, base_family=base_family)
  if (use_sizes) {
    thm + theme_sdc_sizes()
  }
  thm
}

## blank theme, from: https://gist.github.com/dsparks/3711166#file-new_theme_empty-r
new_theme_empty <- theme_bw()
new_theme_empty$line <- element_blank()
new_theme_empty$rect <- element_blank()
new_theme_empty$strip.text <- element_blank()
new_theme_empty$axis.text <- element_blank()
new_theme_empty$plot.title <- element_blank()
new_theme_empty$axis.title <- element_blank()
new_theme_empty$plot.margin <- structure(c(0, 0, -1, -1), unit = "lines", valid.unit = 3L, class = "unit")