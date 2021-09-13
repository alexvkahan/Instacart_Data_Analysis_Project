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

--tesing to see if there are any orders where there is a product that cannot be found in the products table and vise versa
-- this lets us know that data has some flaws, namely there is no correspoding product for product ID 6816, highlighting the importance of data integrity
-- additionally this olso shows what products have not been ordered at all and there for could be usefull information for stores to decide to not carry those products once a propper time frame is reached
select *
from products p
full outer join orders_products_prior op on p.product_id = op.product_id
where p.product_name is null or op.order_id is null;

--want know if a produt can be ordere multipe times in the same order
select *
from products p
join orders_products_prior op on p.product_id = op.product_id
    select order_id, product_id count(*)
    orders_products_prior op
