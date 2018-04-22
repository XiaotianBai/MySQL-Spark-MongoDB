use xb306;

drop table if exists hayn;
create table hayn(date date, open double, high double, low double, close double, volumn double, opint integer);
load data local infile "/home/data/MT/dataset2/ndq1/hayn.us.txt" into table hayn columns terminated by ',' lines terminated by '\n' ignore 1 lines;
select date as Date, concat(truncate(abs(open-close)/open*100,2), "%") as ChangePct_hayn from hayn where abs((open-close)/open) = (select max(abs((open-close)/open)) from hayn);

drop table if exists elgx;
create table elgx(date date, open double, high double, low double, close double, volumn double, opint integer);
load data local infile "/home/data/MT/dataset2/ndq1/elgx.us.txt" into table elgx columns terminated by ',' lines terminated by '\n' ignore 1 lines;
select date as Date, concat(truncate(abs(open-close)/open*100,2), "%") as ChangePct_elgx from elgx where abs((open-close)/open) = (select max(abs((open-close)/open)) from elgx);

drop table if exists amed;
create table amed(date date, open double, high double, low double, close double, volumn double, opint integer);
load data local infile "/home/data/MT/dataset2/ndq1/amed.us.txt" into table amed columns terminated by ',' lines terminated by '\n' ignore 1 lines;
select date as Date, concat(truncate(abs(open-close)/open*100,2), "%") as ChangePct_amed from amed where abs((open-close)/open) = (select max(abs((open-close)/open)) from amed);
