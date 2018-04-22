library(ggplot2)
library(reshape2)

#first plot with raw data

d_first =read.csv(file="/home/data/MT/dataset1/gdp-1950-1983.csv",sep=",",header=TRUE)

d_melted = melt(d_first, id.vars='YEAR', value.name = 'GDP', variable.name = 'COUNTRIES', na.rm = TRUE)

p1<-ggplot(data=d_melted, aes(x=YEAR, y=GDP, group = COUNTRIES, colour = COUNTRIES)) + geom_line() + geom_point( size=1, shape=1) +scale_x_continuous(breaks = seq(1950, 1983, by=5)) + scale_y_continuous(breaks = seq(0, 90, by=10))

p1 + ggtitle("Raw GDP over year")

ggsave("xb306_plot1.png")

#second plot with scaled data
d_first =read.csv(file="/home/data/MT/dataset1/gdp-1950-1983.csv",sep=",",header=TRUE)

func <- function(x)
{
  (x- mean(x))/sd(x)
}

d_second = cbind(d_first[1], apply(d_first[2:10],2,func))

d_melted_new = melt(d_second, id.vars='YEAR', value.name = 'SCALED_GDP', variable.name = 'COUNTRIES', na.rm = TRUE)

p2<-ggplot(data=d_melted_new, aes(x=YEAR, y=SCALED_GDP, group = COUNTRIES, colour = COUNTRIES)) + geom_line() + geom_point( size=1, shape=1) +scale_x_continuous(breaks = seq(1950, 1983, by=5)) + scale_y_continuous(breaks = seq(-2, 2, by=0.2))

p2 + ggtitle("Scaled GDP over year")

ggsave("xb306_plot2.png")
