--Most popular days and time to place orders

select * from orders
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

 
 

select 
    o.order_dow,
    o.order_hour_of_day,
    count(*) num_orders
from orders o
group by o.order_dow, o.order_hour_of_day
order by num_orders desc;