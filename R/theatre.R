sales <- read.csv("theatre//london2012-theatre-v2//Sales Data.csv",
                  colClasses=c(rep("character", 3),
                               "integer", "numeric", 
                               rep("integer", 2)))
str(sales)

sales$sale_date <- as.Date(sales$sale_date)
sales$performance_date <- as.Date(sales$performance_date)

hist(sales$total_tickes)
