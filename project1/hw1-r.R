library(RMySQL);
library(ggplot2)
library(reshape2)

mydb = dbConnect(RMySQL::MySQL(), user='xb306', password='xb306123', dbname='xb306', host='localhost')

rs1 = dbSendQuery(mydb, "select avg(temp.arithmetic_mean) as AVERAGE_MEAN, temp.pollutant as POLLUTANTS, temp.yr as YEAR from (select arithmetic_mean, year(date_local) as yr, parameter_name as pollutant from pollutants where city_name = 'New York' and parameter_name like '%PM2.5%') temp group by temp.yr, temp.pollutant;");
avgPolNYC = fetch(rs1, n=-1)
p1<-ggplot(data=avgPolNYC, aes(x=YEAR, y=AVERAGE_MEAN, group = POLLUTANTS, colour = POLLUTANTS)) + geom_line() + geom_point( size=1, shape=1)
p1<-p1 + labs(title = "Average Concentration of Various PM2.5 Pollutants in NYC (2000-2016)", x="Year", y = "Average Arithmetic Mean (Micrograms/cubic meter)")
ggsave("HW1_plot1_xb306.png")

rs2 = dbSendQuery(mydb, "select avg(temp.arithmetic_mean) as AVERAGE_MEAN, temp.pollutant as POLLUTANTS, temp.yr as YEAR from (select arithmetic_mean, year(date_local) as yr, parameter_name as pollutant from pollutants where parameter_name like '%PM2.5%') temp group by temp.yr, temp.pollutant;")
avgPolUS = fetch(rs2, n=-1)
p2<-ggplot(data=avgPolUS, aes(x=YEAR, y=AVERAGE_MEAN, group = POLLUTANTS, colour = POLLUTANTS)) + geom_line() + geom_point( size=1, shape=1) 
p2<-p2 + labs(title = "Average Concentration of Various PM2.5 Pollutants in US (1990-2017)", x="Year", y = "Average Arithmetic Mean (Micrograms/cubic meter)")
ggsave("HW1_plot2_xb306.png")

rs3 = dbSendQuery(mydb, "select * from (select avg(temp.arithmetic_mean) as AVERAGE_MEAN_NY, temp.yr as yr from (select arithmetic_mean, year(date_local) as yr, parameter_name as pollutant from pollutants where city_name = 'New York' and parameter_name like '%PM2.5%') temp group by temp.yr) as a natural join (select avg(temp2.arithmetic_mean) as AVERAGE_MEAN_US, temp2.yr as yr from (select arithmetic_mean, year(date_local) as yr, parameter_name as pollutant from pollutants where parameter_name like '%PM2.5%') temp2 group by temp2.yr) as b;")
avgPolCompare = fetch(rs3, n=-1)
avgPolCompare_melted = melt(avgPolCompare, id.vars='yr', value.name = 'AAM', variable.name = 'Lines', na.rm = TRUE)
p3<-ggplot(data=avgPolCompare_melted, aes(x=yr, y=AAM, group = Lines, colour = Lines)) + geom_line() + geom_point( size=1, shape=1)
p3<-p3 + labs(title = "Overall Average Concentration of PM2.5 Pollutants in US vs NYC (2000-2016)", x="Year", y = "Average Arithmetic Mean (Micrograms/cubic meter)")
ggsave("HW1_plot3_xb306.png")

rs4 = dbSendQuery(mydb, "select temp.pollutant as pollutants, avg(temp.arithmetic_mean) as AVERAGE_MEAN_NY from (select arithmetic_mean, parameter_name as pollutant, year(date_local) as yr from pollutants where city_name = 'New York' and parameter_name like '%PM2.5%' and year(date_local) = 2016) temp group by temp.pollutant, temp.yr;")
avgPolNYC2016 = fetch(rs4, n=-1)

func <- function(x)
{
  x/sum(x)
}

avgPolNYC2016_b <- cbind(avgPolNYC2016[1], apply(avgPolNYC2016[2], 2, func))
p4<-ggplot(avgPolNYC2016, aes(x = "", y = AVERAGE_MEAN_NY, fill=factor(pollutants))) + geom_bar(width = 1, stat = "identity") + coord_polar("y")
p4<-p4 +theme_void()
p4<-p4 + labs(title = "Proportion of PM2.5 Pollutants in New York in 2016")
ggsave("HW1_plot4_xb306.png")
