--Create view with subset of order product data for dev/test purposes
create view order_products_test as (
    select * from DEMO.orders_products_prior
    fetch first 1000 rows only
);

-- contains Order_ID, product_id, order added t0 cart, and if it was reordered, also an ID table with ids being a unique combo of product and order id
select * from orders_products_prior
fetch first 10 rows only;

--gives product ID, product_name, aisle_id, and department_id
select * from products
fetch first 10 rows only;

--shows must commonly ordered items
select p.product_name, count(*)
from products p
join orders_products_prior op on p.product_id = op.product_id
group by p.product_name
order by count(*) desc
fetch first 10 rows only;

--testing to see if there are any orders where there is a product that cannot be found in the products table and vise versa
-- this lets us know that data has some flaws, namely there is no correspoding product for product ID 6816, highlighting the importance of data integrity
-- additionally this also shows what products have not been ordered at all and there for could be usefull information for stores to decide to not carry those products once a propper time frame is reached
select *
from products p
full outer join orders_products_prior op on p.product_id = op.product_id
where p.product_name is null or op.order_id is null;

--want know if a produt can be ordered multipe times in the same order
--this shows that each product is not duplicated within an order.  Order quantity for each product is not known
select op.order_id, p.product_id, count(*)
from products p
join orders_products_prior op on p.product_id = op.product_id
group by op.order_id, p.product_id
having count(*) > 1;

select op.order_id, count(*) as num_products
from products p
join order_products_test op on p.product_id = op.product_id
group by op.order_id
order by count(*) desc;

select 
    avg(count(*)) avg_num_products,
    min(count(*)) min_num_products,
    max(count(*)) max_num_products,
    median(count(*)) median_num_products,
    stats_mode(count(*)) mode_num_products
from orders_products_prior
group by orders_products_prior.order_id;

--Does order size change with order frequency?

-- top customers, from orders spreadsheet
select
    o.user_id,
    count(*) num_orders
from orders o
group by o.user_id
order by num_orders desc, o.user_id;

-- connecting customers to products per order
select o.user_id, o.order_id, count(op.product_id) prod_count
from orders o
join orders_products_prior op
    on o.order_id = op.order_id
group by o.user_id, o.order_id
;

--average products per order by customers, sub query from query above
select user_id, round(avg(prod_count), 2) products_per_order
from (
    select o.user_id, o.order_id, count(op.product_id) prod_count
    from orders o
    join orders_products_prior op
        on o.order_id = op.order_id
    group by o.user_id, o.order_id
    )
group by user_id;

-- products per order and number of total orders by customer
-- joining above with number of orders per customer, adding column to bin how often customers order
--not to self, remember to say why the below cut offs were chosen for the different frequencies, I think the numbers come from an earlier query
create table product_order_analysis as
(
select a.user_id, round(a.products_per_order,2) products_per_order , b.num_orders, round((a.products_per_order * b.num_orders),2) total_products, 
Case
    when b.num_orders = 4   -- could even right as a further sub query
        then 'min frequency'
    when b.num_orders between 5 and 9
        then 'low frequency'
    when b.num_orders = 10
        then 'median frequency'
    when b.num_orders between 11 and 99
        then 'high frequency'
    when b.num_orders = 100
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

select * from product_order_analysis;

--this table is used to compare the number of products being ordered per order across customers who order at different frequencies
--the results indicate that the average products per order do not change as customers' order frequency changes. This means on average, customers who order more in a single site vist do not do so because they visit less reqularly and vice versa for higher frequency shoppers.
--As a result insta cart finds more value in higher frequency shoppers because those customers overall order more products.
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
