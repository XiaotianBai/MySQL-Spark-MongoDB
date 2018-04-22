use xb306;
drop table if exists pollutants;
create table pollutants(state_code integer, county_code integer, site_num integer, parameter_code integer, poc integer, latitude double, longitude double, datum varchar(255), parameter_name varchar(255), sample_duration varchar(255), pollutant_standard varchar(255), date_local date, units_of_measure varchar(255), event_type varchar(255), observation_count integer, observation_percent float, arithmetic_mean float, first_max_value float, first_max_hour integer, aqi varchar(255), method_code integer, method_name varchar(255), local_site_name varchar(255), address varchar(255), state_name varchar(255), county_name varchar(255), city_name varchar(255), cbsa_name varchar(255), date_of_last_change date);
#create table pollutants(arithmetic_mean float, parameter_name varchar(255), date_local date, city_name varchar(255));

#load data local infile "e:/classes/bigdata/simplified_datasets.csv" into table pollutants columns terminated by ',' lines terminated by '\n' ignore 1 lines;
#load data local infile "e:/classes/bigdata/epa_hap_daily_summary.csv" into table pollutants columns terminated by ',' lines terminated by '\n' ignore 1 lines;

load data local infile "/home/2018/spring/nyu/6513/xb306/HW1/epa_hap_daily_summary.csv" into table pollutants columns terminated by ',' lines terminated by '\n' ignore 1 lines;
