--Create view with subset of order product data for dev/test purposes
create view order_products_test as (
    select * from DEMO.orders_products_prior
    fetch first 1000 rows only
);

--Find top 10 products by total orders
--Join order products prior and products and aggregate by product name
select 
    p.product_name, 
    count(*) as total_orders
from products p
join orders_products_prior op 
    on p.product_id = op.product_id
group by p.product_name
order by count(*) desc
fetch first 10 rows only;

--Bananas and Organic Bananas are the most popular items

--Rewriting above query to include department and aisle information
--Join orders products prior, products, departments, and aisle tables and aggregate by product name
select 
    p.product_name, 
    d.department,a.aisle, 
    count(*) as total_orders
from products p
join orders_products_prior op 
    on p.product_id = op.product_id
join departments d 
    on d.department_id = p.department_id
join aisles a 
    on a.aisle_id = p.aisle_id
group by p.product_name, d.department, a.aisle
order by total_orderrs desc
fetch first 10 rows only;

-- Check to see if there are any orders for a product that cannot be found in the products table or a product that has never been ordered

select 
    p.id, 
    p.product_id, 
    p.aisle_id,
    p.department_id,
    op.order_id, 
    op.add_to_cart_order,
    op.reordered
from products p
full outer join orders_products_prior op 
    on p.product_id = op.product_id
where p.product_name is null 
or op.order_id is null;

-- There is no correspoding product for product ID 6816
-- There are several products have never been ordered 
-- These products could be removed from the app

--Check if a product can be ordered multipe times in the same order

select op.order_id, p.product_id, count(*)
from products p
join orders_products_prior op 
    on p.product_id = op.product_id
group by op.order_id, p.product_id
having count(*) > 1;

--This shows that each product is not duplicated within an order
--Order quantity for each product is not known

--Find the total number of products within each order
select 
    op.order_id, 
    count(*) as num_products
from products p
join order_products_test op 
    on p.product_id = op.product_id
group by op.order_id
order by num_products desc;

--Find summary stats for the number of products in each order
--Include Mean, Median, Mode, Min, and Max
select 
    round(avg(count(*)), 2) avg_num_products,
    min(count(*)) min_num_products,
    max(count(*)) max_num_products,
    median(count(*)) median_num_products,
    stats_mode(count(*)) mode_num_products
from orders_products_prior
group by orders_products_prior.order_id;

--The average order size is about 10 products

-- Find if order size change with order frequency
-- Top customers based on the number of orders
select
    o.user_id,
    count(*) num_orders
from orders o
group by o.user_id
order by num_orders desc, o.user_id;

-- Find the number of products in each order with user id included
select 
    o.user_id, 
    o.order_id, 
    count(op.product_id) prod_count
from orders o
join orders_products_prior op
    on o.order_id = op.order_id
group by o.user_id, o.order_id
;

--Find average products per order for each user
select 
    user_id, 
    round(avg(prod_count), 2) products_per_order
from (
    select 
        o.user_id, 
        o.order_id, 
        count(op.product_id) prod_count
    from orders o
    join orders_products_prior op
        on o.order_id = op.order_id
    group by o.user_id, o.order_id
    )
group by user_id
order by products_per_order desc;

--Rewriting above using subquery factoring
with user_order_prod_count as (
    select 
        o.user_id, 
        o.order_id, 
        count(op.product_id) prod_count
    from orders o
    join orders_products_prior op
        on o.order_id = op.order_id
    group by o.user_id, o.order_id
)
select 
    u.user_id, 
    round(avg(u.prod_count), 2) products_per_order
from user_order_prod_count u
group by user_id
order by products_per_order desc;

--Summary stats of total orders for each customer

select
    count(*) total_orders,
    min(count(*)) min_orders,
    max(count(*)) max_orders,
    median(count(*)) median_orders,
    stats_mode(count(*)) mode_orders
from orders
group by user_id;

-- Find products per order and number of total orders by customer
-- Joining above query with number of orders per customer, adding column to bin how often customers order
--B
create or replace view product_order_analysis as
(
select 
    a.user_id, 
    round(a.products_per_order,2) products_per_order, 
    b.num_orders, 
    round((a.products_per_order * b.num_orders),2) total_products, 
Case
    when b.num_orders = (select
                            min(count(*)) min_orders
                        from orders
                        group by user_id)
        then 'min frequency'
    when b.num_orders between (select
                                min(count(*)) min_orders
                              from orders
                              group by user_id) + 1
                      and     (select
                                median(count(*)) median_orders
                              from orders
                              group by user_id) - 1  
        then 'low frequency'
    when b.num_orders = (select
                            median(count(*)) median_orders
                        from orders
                        group by user_id)    
        then 'median frequency'
    when b.num_orders between (select
                                median(count(*)) median_orders
                              from orders
                              group by user_id) + 1
                      and     (select
                                max(count(*)) max_orders
                              from orders
                              group by user_id) - 1
        then 'high frequency'
    when b.num_orders = (select
                            max(count(*)) max_orders
                        from orders
                        group by user_id)
        then 'max frequency'
end customer_order_frequency
from (
    select user_id, avg(prod_count) products_per_order
    from (
        select o.user_id, o.order_id, count(op.product_id) prod_count
        from orders o
        join orders_products_prior op
            on o.order_id = op.order_id
        group by o.user_id, o.order_id
        )
    group by user_id
    ) a
join (
    select
        o.user_id,
        count(*) num_orders
    from orders o
    group by o.user_id
    ) b
    on a.user_id = b.user_id
);

select * 
from product_order_analysis
order by user_id;

--Rewriting above query using subquery factoring

create or replace view product_order_analysis1 as 
with min_orders as (
    select
        min(count(*)) min_orders
    from orders
    group by user_id
),
median_orders as (
    select
        median(count(*)) median_orders
    from orders
    group by user_id
),
max_orders as (
    select
        max(count(*)) max_orders
    from orders
    group by user_id
),
order_prod_total as (
    select 
        o.user_id, 
        o.order_id, 
        count(op.product_id) prod_count
    from orders o
    join orders_products_prior op
        on o.order_id = op.order_id
    group by o.user_id, o.order_id
),
avg_prod_per_order as (
    select 
        op.user_id, 
        avg(op.prod_count) products_per_order
    from order_prod_total op
    group by user_id
),
total_orders as (
    select
        o.user_id,
        count(*) num_orders
    from orders o
    group by o.user_id
)
select 
    a.user_id, 
    round(a.products_per_order,2) products_per_order, 
    t.num_orders, 
    round((a.products_per_order * t.num_orders),2) total_products,
Case
    when t.num_orders = (select * from min_orders)   
        then 'min frequency'
    when t.num_orders between (select * from min_orders) + 1 and (select * from median_orders) - 1
        then 'low frequency'
    when t.num_orders = (select * from median_orders)
        then 'median frequency'
    when t.num_orders between (select * from median_orders) + 1 and (select * from max_orders) - 1
        then 'high frequency'
    when t.num_orders = (select * from max_orders)
        then 'max frequency'
end customer_order_frequency
from avg_prod_per_order a
join total_orders t
    on a.user_id = t.user_id
order by a.user_id
;




--Compare the number of products per order across customers who order at different frequencies.
select
    customer_order_frequency,
    count(*) num_customer,
    min(products_per_order) min_products_per_order,
    max(products_per_order) max_products_per_order,
    median(products_per_order) median_products_per_order,
    round(avg(products_per_order), 2) avg_products_per_order,
    stats_mode(products_per_order) mode_products_per_order,
    round(avg(total_products), 2) avg_total_products
from product_order_analysis
group by customer_order_frequency
/*order by 
    case
        when customer_order_frequency = 'min frequency' then 1
        when customer_order_frequency = 'low frequency' then 2
        when customer_order_frequency = 'median frequency' then 3
        when customer_order_frequency = 'high frequency' then 4
        when customer_order_frequency = 'max frequency' then 5
    end */
order by decode(customer_order_frequency, 'min frequency', 1, 'low frequency', 2, 'median frequency', 3, 'high frequency', 4, 'max frequency', 5)
;
--The results indicate that the average products per order does change as customers' order frequency changes. 
--This means on average, order frequency does not indicate the number of products per order.
--As a result insta cart finds more value in higher frequency shoppers because those customers order more products overall.
