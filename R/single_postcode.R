library("dplyr")
head(houses)

median(table(houses$Postcode))

# EC2Y 9AP - 228 house sales over 5 year period

## Sector: 2640 groups, 511 datapoints per
median(table(houses$sector)) 
