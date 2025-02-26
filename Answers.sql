select * from daily_activity;
select * from weight_log;
select * from sleep_day;

1) Identify the day of the week when the customers are most active and least active. 
Active is determined based on the no of steps.

select distinct most_active,least_Active from
(select day_of_week,sum(total_steps),
first_value(day_of_week) over(order by sum(total_steps) desc) as most_active,
first_value(day_of_week) over(order by sum(total_steps)) as least_active
from daily_activity
group by 1)

2) Identify the customer who has the most effective sleep. 
Effective sleep is determined based on is customer spent most of the time in bed sleeping.

select x.customer_id from 
(select customer_id,sum(total_time_in_bed) as total_time_in_bed,
rank()over(order by sum(total_time_in_bed) desc) as rnk
from sleep_day
group by 1) x
where x.rnk = 1

3) Identify customers with no sleep record.

select d.customer_id 
from daily_activity d
where d.customer_id not in (select customer_id from sleep_day)

4) Fetch all customers whose daily activity, sleep and weight logs are all present.

select customer_id from daily_activity
intersect
select customer_id from sleep_day

5) For each customer, display the total hours they slept for each day of the week. 
Your output should contains 8 columns, first column is the customer id and 
the next 7 columns are the day of the week (like monday, tuesday etc)


select customer_id,
sum(case when day_of_week='Monday' then total_sleep_records else 0 end) as Monday,
sum(case when day_of_week='Tuesday' then total_sleep_records else 0 end) as Tuesday,
sum(case when day_of_week='Wednesday' then total_sleep_records else 0 end) as Wednesday,
sum(case when day_of_week='Thursday' then total_sleep_records else 0 end) as Thursday,
sum(case when day_of_week='Friday' then total_sleep_records else 0 end) as Friday,
sum(case when day_of_week='Saturday' then total_sleep_records else 0 end) as Saturday,
sum(case when day_of_week='Sunday' then total_sleep_records else 0 end) as Sunday
from sleep_day
group by 1
order by 1

select customer_id
	, sum(case when day_of_week='Monday' then concat(round(total_minutes_asleep::decimal/60,2),' ','hours') else 0 end) as Monday
	, sum(case when day_of_week='Tuesday' then  concat(round(total_minutes_asleep::decimal/60,2),' ','hours') else 0 end) as Tuesday
	, sum(case when day_of_week='Wednesday' then  concat(round(total_minutes_asleep::decimal/60,2),' ','hours') else 0 end) as Wednesday
	, sum(case when day_of_week='Thursday' then  concat(round(total_minutes_asleep::decimal/60,2),' ','hours') else 0 end) as Thursday
	, sum(case when day_of_week='Friday' then  concat(round(total_minutes_asleep::decimal/60,2),' ','hours') else 0 end) as Friday
	, sum(case when day_of_week='Saturday' then  concat(round(total_minutes_asleep::decimal/60,2),' ','hours') else 0 end) as Saturday
	, sum(case when day_of_week='Sunday' then  concat(round(total_minutes_asleep::decimal/60,2),' ','hours') else 0 end) as Sunday
	from sleep_day
	group by 1
	order by 1;

6) For each customer, display the following:
customer_id
date when they had the highest_weight(also mention weight in kg) 
date when they had the lowest_weight(also mention weight in kg)

with cte as
(select customer_id,
dates,
weight_kg,
rank() over(partition by customer_id order by weight_kg desc) as high_weight,
rank()over(partition by customer_id order by weight_kg asc) as low_weight
from weight_log)
select customer_id,
max(case when high_weight = 1 then weight_kg else 0 end) as highest_weight,
max(case when high_weight = 1 then cte.dates else 0 end) as highest_date,
max(case when low_weight = 1 then weight_kg else 0 end) as low_weight,
max(case when low_weight = 1 then cte.dates else 0 end) as lowest_date
from cte
group by customer_id

7) Fetch the day when customers sleep the most.

select day_of_week from
(select day_of_week,sum(total_minutes_asleep) as total_sleep,
rank() over(order by sum(total_minutes_asleep) desc) as rnk
from sleep_day
group by 1) x
where x.rnk = 1

8) For each day of the week, determine the percentage of time customers spend lying on bed without sleeping.

select * from daily_activity;
select * from weight_log;
select * from sleep_day;

select day_of_week,round((sum(total_time_in_bed)-sum(total_minutes_asleep))::decimal/sum(total_time_in_bed)::decimal*100,2) as no_sleep
from sleep_day
group by 1

9) Identify the most repeated day of week. 
Repeated day of week is when a day has been mentioned the most in entire database.

with cte as
(select day_of_week from daily_activity
union all
select day_of_week from sleep_day)
, cte_final as
(select day_of_week,count(*),
rank() over (order by count(*) desc) as rnk
from cte
group by 1)
select day_of_week 
from cte_final
where rnk =1

10) Based on the given data, identify the average kms a customer walks based on 6000 steps.

select customer_id,round(avg(total_distance)::decimal,2) as total_distance
from daily_activity
where total_steps > 6000
group by 1
order by 2 desc



