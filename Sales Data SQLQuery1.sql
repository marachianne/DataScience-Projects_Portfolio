
select * from sales_data1;

---/In---Inspecting Data/---
select distinct status from sales_data1;
select distinct YEAR_ID from sales_data1;
select distinct PRODUCTLINE from sales_data1;
select distinct COUNTRY from sales_data1;
select distinct DEALSIZE from sales_data1;
select distinct TERRITORY from sales_data1;

--ANALYSIS
-- Grouping sales by productline. which productline made large amount of sales?
select PRODUCTLINE, round(sum(SALES),2) as Revenue
from sales_data1
group by PRODUCTLINE
order by 2 desc;

--What was the best year for sales?
select YEAR_ID, round(sum(SALES),2) Revenue
from sales_data1
group by YEAR_ID
order by 2 desc;

--What DEALSIZE generetad maximum sales?
select  DEALSIZE,  round(sum(SALES),2) as Revenue
from sales_data1
group by  DEALSIZE
order by 2 desc;


--What was the best month for sales in a specific year? How much was earned that month? Answer: November
select  MONTH_ID, round(sum(SALES),2) as Revenue, count(ORDER_NUMBER) as Frequency
from sales_data1
where YEAR_ID = 2004
group by  MONTH_ID
order by 2 desc;

-- what product do they sell most in November, Answer:Classic cars
select  MONTH_ID, PRODUCTLINE, round(sum(SALES),2) Revenue, count(ORDER_NUMBER) as Frequency
from sales_data1
where YEAR_ID = 2004 and MONTH_ID = 11
group by  MONTH_ID, PRODUCTLINE
order by 3 desc;


---EXTRAs----
--What city has the highest number of sales in a specific country
select city, round(sum (SALES),2) Revenue
from sales_data1
where country = 'UK'
group by city
order by 2 desc;

--What is the best product in United States?
select country, YEAR_ID, PRODUCTLINE, round(sum(SALES),2) Revenue
from sales_data1
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc;

--What products are most often sold together? 
--select * from sales_data1 where ORDER_NUMBER =  10411

select distinct ORDER_NUMBER, stuff(

	(select ',' + PRODUCTCODE
	from sales_data1 p
	where ORDER_NUMBER in 
		(

			select ORDER_NUMBER
			from (
				select ORDER_NUMBER, count(*) rn
				FROM sales_data1
				where STATUS = 'Shipped'
				group by ORDER_NUMBER
			)m
			where rn = 3
		)
		and p.ORDER_NUMBER = s.ORDER_NUMBER
		for xml path (''))

		, 1, 1, '') ProductCodes

from sales_data1 s
order by 2 desc

drop table if exists #rfm

--Who is our best customer (this could be best answered with RFM)
with rfm as 
(
select 
		CUSTOMER_NAME, 
		round(sum(SALES),2) MonetaryValue,
		round(avg(SALES),2) AvgMonetaryValue,
		count(ORDER_NUMBER) Frequency,
		max(ORDER_DATE) last_order_date,
        (select max(ORDER_DATE) from sales_data1 ) max_order_date,
		datediff(day, max(ORDER_DATE), (select max(ORDER_DATE) from sales_data1)) Recency
        from sales_data1
        group by CUSTOMER_NAME
),
rfm_calc as
(
select r.*,
        NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
		from rfm r
		)
select c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
cast(rfm_recency as varchar) + cast(rfm_frequency as varchar) + cast(rfm_monetary  as varchar)rfm_cell_string 
into #rfm
from rfm_calc c

select* from #rfm


select CUSTOMER_NAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment
from #rfm
