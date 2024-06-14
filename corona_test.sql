CREATE DATABASE IF NOT EXISTS corona_project;

use  corona_project;

# Setting up  for loading the data files
# if the data file is small ,we can use data wizard to import csv data
# The data files almost 20 thousand records, therefore we use the function load infile which loads the csv data into tables in no time.

show variables like 'local_infile';
SET GLOBAL local_infile = true; 

SELECT @@GLOBAL.secure_file_priv;

# create the table  before we load the csv file in the table
create table  corona_tested_006 (
 Ind_ID int,
 Test_date varchar(25),
 Cough_symptoms varchar(10),
 Fever varchar(10),
 Sore_throat varchar(10) ,
 Shortness_of_breath varchar(10),
 Headache varchar(10), 
 Corona varchar(10),
Age_60_above varchar(10),
Sex varchar(10),
Known_contact varchar(25)
);
 
# load the data using local infile function

load data local infile 'C:/Users/ADMIN/Desktop/corona_tested_006.csv'
into table corona_tested_006
fields terminated by ','
ignore 1 rows;

select * from corona_tested_006
where sex='female'
limit 20;

#  1) Find the number of corona patients who faced shortness of breath.
select count(*) as no_shortness_breath from corona_tested_006
where Shortness_of_breath='TRUE';


# 2) Find the number of negative corona patients who have fever and sore_throat.
select count(*) as cneg_fev_soretht from corona_tested_006
where corona='negative' and
fever='True' and 
sore_throat='True';

# 3)Group the data by month and rank the number of positive cases

select  count(corona) as no_of_pos_cases,monthname((str_to_date(test_date,'%d-%m-%y'))) as test_month,
rank() over (order by count(Corona) desc) as rank_positive_cases
from corona_tested_006
where Corona='positive'
group by test_month;


# 4 )Find the female negative corona patients who faced cough and headache
select count(*) as fm_cng_cgh_hd from corona_tested_006
where  Sex='female'
and Corona='negative' 
and Headache='TRUE'
and Cough_symptoms='TRUE'
;

#5) How many elderly corona patients have faced breathing problems?

select count(*) from corona_tested_006
where Age_60_above='Yes'
and Shortness_of_breath='True';


#6)Which three symptoms were more common among COVID positive patients?

with sympts as (select 'symptoms' ,'count' 
union
select 'cough',
count(case when corona='positive' and Cough_symptoms='True' then 1 end) 
from corona_tested_006
union
select 'fever',count(case when corona='positive' and fever='True' then 1 end)
from corona_tested_006
union
select 'Sore_throat',count(case when corona='positive' and Sore_throat='True' then 1 end)
from corona_tested_006
union 
select 'Shortness_of_breath', count(case when corona='positive' and Shortness_of_breath='True' then 1 end)
from corona_tested_006
union
select 'Headache',count(case when corona='positive' and Headache='True' then 1 end)
from corona_tested_006)
select count,symptoms as 'Three most common symptoms'
from sympts
where symptoms !='symptoms'
order by count desc
limit 3
;


# 8) What are the most common symptoms among COVID positive males whose known contact was abroad? 

with sympts as (select 'symptoms', 'counts' 
union
select 'cough',
count(case when corona='positive' and Cough_symptoms='TRUE' and sex='male' and Known_contact like 'A%' then 1 end) 
from corona_tested_006
union
select 'fever',count(case when corona='positive' and fever='TRUE' and sex='male' and Known_contact like 'A%' then 1 end)
from corona_tested_006
union
select 'sore_throat',count(case when corona='positive' and Sore_throat='TRUE' and sex='male' and Known_contact like 'A%' then 1 end)
from corona_tested_006
union 
select 'shortness_of_breath', count(case when corona='positive' and Shortness_of_breath='TRUE' and sex='male' and Known_contact like 'A%' then 1 end)
from corona_tested_006
union
select 'headache',count(case when corona='positive' and Headache='TRUE'  and sex='male' and Known_contact like 'A%'then 1 end)
from corona_tested_006)
select symptoms,counts
from sympts
where symptoms !='symptoms' and counts!='counts'


