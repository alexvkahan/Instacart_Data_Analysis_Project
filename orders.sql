--Most popular days and time to place orders
select * 
from orders
fetch first 10 rows only;


--Create lookup table for day of week to convert numberic value to text
create table dow_lookup
(
    dow_id number primary key,
    day_of_week varchar2(15)
 );
 
 Insert into dow_lookup (dow_id, day_of_week) 
 values (0, 'Sunday');
 
 Insert into dow_lookup (dow_id, day_of_week) 
 values (1, 'Monday');
 
 Insert into dow_lookup (dow_id, day_of_week) 
 values (2, 'Tuesday');
 
 Insert into dow_lookup (dow_id, day_of_week) 
 values (3, 'Wednesday');
 
 Insert into dow_lookup (dow_id, day_of_week) 
 values (4, 'Thursday');
 
 Insert into dow_lookup (dow_id, day_of_week) 
 values (5, 'Friday');
 
 Insert into dow_lookup (dow_id, day_of_week) 
 values (6, 'Saturday');


-- Below are various methods of showing the number of orders in a specific hour of a specific day as well as roll ups for total orders on a given day and overall

-- Option 1: this approach uses a case statement and joins on the previously created lookup table for day of week.
--It also does not create duplicates for the subtotal for each day of the week
select 
    dl.day_of_week,
    o.order_hour_of_day,
    count(*) num_orders
from orders o
join dow_lookup dl 
    on o.order_dow = dl.dow_id
group by rollup(dl.day_of_week, o.order_hour_of_day)
order by
     CASE
          WHEN dl.day_of_week = 'Sunday' THEN 1
          WHEN dl.day_of_week = 'Monday' THEN 2
          WHEN dl.day_of_week = 'Tuesday' THEN 3
          WHEN dl.day_of_week = 'Wednesday' THEN 4
          WHEN dl.day_of_week = 'Thursday' THEN 5
          WHEN dl.day_of_week = 'Friday' THEN 6
          WHEN dl.day_of_week = 'Saturday' THEN 7
     END ASC,
     o.order_hour_of_day;



--Option 2: Using a subquery. This Method creates duplicate rows for the subtotal of each day of the week
select 
    a.day_of_week,
    a.order_hour_of_day,
    a.num_orders
from (
    select 
        dl.dow_id,
        dl.day_of_week,
        o.order_hour_of_day,
        count(*) num_orders
    from orders o
    join dow_lookup dl 
        on o.order_dow = dl.dow_id
    group by rollup(dl.dow_id, dl.day_of_week, o.order_hour_of_day)
    order by dl.dow_id, o.order_hour_of_day
) a;



--Option 3: Similar to option 2 but us subquery factoring. 
--Also creates duplicate rows for the subtotal of each day of the week
with a as (
    select 
        dl.dow_id,
        dl.day_of_week,
        o.order_hour_of_day,
        count(*) num_orders
    from orders o
    join dow_lookup dl 
        on o.order_dow = dl.dow_id
    group by rollup(dl.dow_id, dl.day_of_week, o.order_hour_of_day)
    order by dl.dow_id, o.order_hour_of_day
    )
select 
    a.day_of_week,
    a.order_hour_of_day,
    a.num_orders
from a;


--Top 10 Order Times
select 
    dl.day_of_week,
    o.order_hour_of_day,
    count(*) num_orders
from orders o
join dow_lookup dl 
    on o.order_dow = dl.dow_id
group by dl.day_of_week, o.order_hour_of_day
order by num_orders desc
fetch first 10 rows only;

--The most popular time to order groceries is Sunday Afternoon and Monday Morning


--Bottom 10 Order Times
select 
    dl.day_of_week,
    o.order_hour_of_day,
    count(*) num_orders
from orders o
join dow_lookup dl 
    on o.order_dow = dl.dow_id
group by dl.day_of_week, o.order_hour_of_day
order by num_orders asc
fetch first 10 rows only;

--The least popular time to order groceries is 3-4 am most days of the week


--Top 3 order times for each day of the week
--This inner query finds the total order count for each hour of each day of the week
with order_day_time as ( 
    select 
        dl.day_of_week,
        o.order_hour_of_day,
        count(*) num_orders
    from orders o
    join dow_lookup dl 
        on o.order_dow = dl.dow_id
    group by dl.day_of_week, o.order_hour_of_day
    order by num_orders asc
), 
--This middle query ranks each hour of each day based on the total orders
hour_ranks as (
    select
        day_of_week,
        order_hour_of_day,
        num_orders,
        rank() over (
        partition by day_of_week
        order by num_orders desc) as hour_rank
    from order_day_time
)
--This outer query selects the top three hours for each day based on the ranking of total orders
select 
    day_of_week,
    order_hour_of_day,
    num_orders
from hour_ranks
where hour_rank <=3
order by
     CASE
          WHEN day_of_week = 'Sunday' THEN 1
          WHEN day_of_week = 'Monday' THEN 2
          WHEN day_of_week = 'Tuesday' THEN 3
          WHEN day_of_week = 'Wednesday' THEN 4
          WHEN day_of_week = 'Thursday' THEN 5
          WHEN day_of_week = 'Friday' THEN 6
          WHEN day_of_week = 'Saturday' THEN 7
     END ASC,
     num_orders desc;
     
--Results show that the most common time to place an order is from 10am-3pm



--Most popular day of week to order
select 
    dl.day_of_week,
    count(*) num_orders
from orders o
join dow_lookup dl 
    on o.order_dow = dl.dow_id
group by dl.day_of_week
order by num_orders desc;

--Monday is the most popular day to order groceries and Thursday is the least


--Most popular time of day to order
select 
    o.order_hour_of_day,
    count(*) num_orders
from orders o
group by o.order_hour_of_day
order by num_orders desc;

select
    count(*) total_orders,
    min(count(*)) min_orders,
    max(count(*)) max_orders,
    median(count(*)) median_orders,
    stats_mode(count(*)) mode_orders
from orders
group by user_id;

--10am is the most common order time and 3am is the least common


--Top customers based on total orders
select
    o.user_id,
    count(*) num_orders
from orders o
group by o.user_id
order by num_orders desc, o.user_id;


