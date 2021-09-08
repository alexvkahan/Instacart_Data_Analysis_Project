--Most popular days and time to place orders

select * from orders
fetch first 10 rows only;

--Create lookup table for day of week to convert numberic value to text
-- look into doing it with the small plsql block found here https://stackoverflow.com/questions/39576/best-way-to-do-multi-row-insert-in-oracle
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


 
--.423, .389
select 
    dl.day_of_week,
    o.order_hour_of_day,
    count(*) num_orders
from orders o
join dow_lookup dl on o.order_dow = dl.dow_id
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

--.403, .391
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
    join dow_lookup dl on o.order_dow = dl.dow_id
    group by dl.dow_id, dl.day_of_week, o.order_hour_of_day
    order by dl.dow_id, o.order_hour_of_day
) a;

--.413, .382
--roll up gives strange results, when inside the subquery will repeat, when outside switches the order by back to alphebetical for day_of_week
with a as (
    select 
        dl.dow_id,
        dl.day_of_week,
        o.order_hour_of_day,
        count(*) num_orders
    from orders o
    join dow_lookup dl on o.order_dow = dl.dow_id
    group by  dl.dow_id, dl.day_of_week, o.order_hour_of_day
    order by dl.dow_id, o.order_hour_of_day
    )
select 
    a.day_of_week,
    a.order_hour_of_day,
    max(a.num_orders)
from a
group by rollup(a.day_of_week, a.order_hour_of_day);


