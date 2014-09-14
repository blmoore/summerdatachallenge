boroughs <- read.csv("datablog_data/London boroughs in numbers.csv")

# relate boroughs to postcodes via london_postcodes.csv from: http://www.doogal.co.uk/london_postcodes.php
b2pc <- read.csv("London_postcodes.csv")
head(b2pc)
boroughs$BOROUGH

# b2pc$District \approx boroughs

for( b in unique(boroughs$BOROUGH)) {
  cat(b, "\n")
  m <- unique(b2pc[agrep(b, b2pc$District),]$District)
  cat(m, b, "\n") 
}

b2pc$District[agrep(boroughs$BOROUGH[1], b2pc$District)]


earnings <- read.csv("datablog_data/Figure 3.15, Trends in median full-time gross weekly earnings of employees by gender, 1966-2008.xls.csv")

london.wards <- readShapePoly("~/TD/london_wards2013/london_wards2013.shp"
                              , proj4string=CRS(projString))
wards.count <- nrow(london.wards@data)
# assign id for each lsoa

london.wards@data$id <- 1:wards.count
wards.fort <- fortify(london.wards, region='id')