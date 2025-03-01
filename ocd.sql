create database Health_records;
select * from ocd_patient_data;
-- Count of FEMALE VS MALE that have OCD & average obsession score by Gender *
with data as (
select Gender, 
count(`Patient ID`) as patient_count,
round(avg(`Y-BOCS Score (Obsessions)`),2) as avg_obs_score
from ocd_patient_data 
group by 1
order by 2
)

-- percentage of female vs male that have OCD
select 
sum(case when Gender = 'Female' then patient_count else 0 end) AS count_female,
sum(case when Gender = 'Male' then patient_count else 0 end) AS count_male,

ROUND(sum(case when Gender = 'Female' then patient_count else 0 end)/
(sum(case when Gender = 'Female' then patient_count else 0 end) 
+ sum(case when Gender = 'Male' then patient_count else 0 end))*100,2)
AS PCT_FEMALE,
ROUND(sum(case when Gender = 'Male' then patient_count else 0 end)/
(sum(case when Gender = 'Female' then patient_count else 0 end) 
+ sum(case when Gender = 'Male' then patient_count else 0 end))*100,2)
AS PCT_MALE
 from data;

-- COUNT AND AVERAGE OBSESSION SCORE BY ETHNICITY THAT HAVE OCD
SELECT Ethnicity,
count(`Patient ID`) AS COUNT_ID,
avg(`Y-BOCS Score (Obsessions)`) AS AVG_OBS
FROM ocd_patient_data 
group by 1
order by 2;

-- 3. NUMBER OF PEOPLE DIGNOSED BY OCD MoM
alter table health_records.ocd_patient_data
modify `OCD Diagnosis Date` date;

-- select date format (`OCD Diagnosis Date`,'%Y-%M-01 00:00:00') AS MONTH, count(`Patient ID`) as patient_count FROM ocd_patient_data group by 1 order by 1;--

-- what is the most common obsession type(count) & its respective average obsession score
select `Obsession Type`,
count(`Patient ID`) as patient_count,
round(avg(`Y-BOCS Score (Obsessions)`),2) as obsession_score
from ocd_patient_data 
group by 1
order by 2;

-- what is the most common compulsion type (count) & its respective average obsession score
select `Compulsion Type`,
count(`Patient ID`) as patient_count,
round(avg(`Y-BOCS Score (Obsessions)`),2) as obsession_score
from ocd_patient_data 
group by 1
order by 2;







