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
