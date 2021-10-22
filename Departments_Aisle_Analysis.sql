--This set of queries explores the popularity of different departments and aisles and the prodcuts they contain

--Find the top 10 most frequently ordered items with department and aisle information included
--Join the orders products prior, products, departments and aisles tables and aggregate based on product name to find total orders
select 
    p.product_name, 
    d.department,
    a.aisle, 
    count(*) as total_orders
from products p
join orders_products_prior op 
on p.product_id = op.product_id
join departments d 
on d.department_id = p.department_id
join aisles a 
on a.aisle_id = p.aisle_id
group by p.product_name, d.department, a.aisle
order by total_orders desc
fetch first 10 rows only;

--Bananas are the most popular item
--9 out of the top 10 items are from the produce department
--8 out of the top 10 itemsare from the fresh fruit aisle

--Find the top departments based on total orders
--Join orders products prior, products, and departments tables and aggregate based on department name
select 
    d.department, 
    count(*) as total_orders
from products p
join orders_products_prior op 
on p.product_id = op.product_id
join departments d 
on d.department_id = p.department_id
group by d.department
order by total_orders desc;

--Produce is by far the most common department while bulk is the least. 
--Based on this, Instacart would likely want to present produce most prominently in the app so users can easily order produce items

--Find top 3 items from each department
--Use multiple subqueries to join orders products prior, products, and departments tables, 
--Rank each product within each department based on total orders
--Rank each department based on total orders
--Join the subqueries to find the top 3 products per department and order the results based on the most popular departments
select 
    a.product_name, 
    a.department, 
    order_num
from 
    (
    select 
        product_name, 
        department, 
        order_num, 
        rank() over (
        partition by department 
        order by order_num desc) as product_rank
    from
        (
        select 
            p.product_name, 
            d.department, 
            count(*) order_num
        from products p
        join orders_products_prior op 
        on p.product_id = op.product_id
        join departments d 
        on d.department_id = p.department_id
        group by p.product_name, d.department
        order by count(*) desc
        ) 
    order by order_num desc
    ) a
join 
    (
    select 
        department, 
        dep_order_num,
        department_rank
    from
        (
        select 
            d.department, 
            count(*) dep_order_num,  
            rank() over (
            order by count(*) desc) as department_rank
        from products p
        join orders_products_prior op 
        on p.product_id = op.product_id
        join departments d 
        on d.department_id = p.department_id
        group by d.department
        order by count(*) desc
        )
    ) b
    on a.department = b.department
where product_rank <= 3
order by b.department_rank, a.product_rank;

--These results give insights into the most commonly ordered items across all departments
--Instacart could use these items as suggested/promoted items in the app to drive further orders

--Rewriting the above query using subquery factoring
with product_dept_orders as (
    select 
        p.product_name, 
        d.department, 
        count(*) order_num
    from products p
    join orders_products_prior op 
    on p.product_id = op.product_id
    join departments d 
    on d.department_id = p.department_id
    group by p.product_name, d.department
    order by count(*) desc
),
product_rank as (
    select 
        product_name, 
        department, 
        order_num, 
        rank() over (
        partition by department 
        order by order_num desc) as product_rank
    from product_dept_orders
),
department_rank as (
    select 
        d.department, 
        count(*) dep_order_num,  
        rank() over (order by count(*) desc) as department_rank
    from products p
    join orders_products_prior op 
    on p.product_id = op.product_id
    join departments d 
    on d.department_id = p.department_id
    group by d.department
    order by count(*) desc
)
select 
    p.product_name, 
    p.department, 
    p.order_num
from 
product_rank p
join department_rank d
on p.department = d.department
where p.product_rank <= 3
order by d.department_rank, p.product_rank;

--Find the top aisles based on total orders
select 
    a.aisle, 
    count(*) as total_orders
from products p
join orders_products_prior op 
on p.product_id = op.product_id
join aisles a 
on a.aisle_id = p.aisle_id
group by a.aisle
order by count(*) desc;

--Fresh fruits and fresh vegetables are the most popular aisles while frozen juice is the least popular


--Find the top 3 items within each aisle
--Use multiple subqueries to join orders products prior, products, and aisles tables
--Rank each product within each aisle by total orders
--Rank each aisle by total orders
--Join subqueries to find the top 3 items per aisle and order by the most popular aisle
select 
    a.product_name, 
    a.aisle, 
    a.order_num
from 
    (
    select 
        product_name, 
        aisle, 
        order_num, 
        rank() over (
        partition by aisle 
        order by order_num desc) as product_rank
    from
        (
        select 
            p.product_name, 
            aisles.aisle, 
            count(*) order_num
        from products p
        join orders_products_prior op 
        on p.product_id = op.product_id
        join aisles 
        on aisles.aisle_id = p.aisle_id
        group by p.product_name, aisles.aisle
        order by count(*) desc
        ) 
    order by order_num desc
    ) a
join 
    (
    select 
        aisle, 
        aisle_order_num, 
        aisle_rank
    from
        (
        select 
            a.aisle, 
            count(*) aisle_order_num,  
            rank() over (
            order by count(*) desc) as aisle_rank
        from products p
        join orders_products_prior op 
        on p.product_id = op.product_id
        join aisles a 
        on a.aisle_id = p.aisle_id
        group by a.aisle
        order by count(*) desc
        )
    ) b
    on a.aisle = b.aisle
where product_rank <= 3
order by b.aisle_rank, a.product_rank;

--The most common aisle centers around fresh produce
--The least common aisles by orders is the frozen juice


--Rewriting the above query using subquery factoring

with aisle_orders as (
    select 
        p.product_name, 
        a.aisle, 
        count(*) order_num
    from products p
    join orders_products_prior op 
    on p.product_id = op.product_id
    join aisles a 
    on a.aisle_id = p.aisle_id
    group by p.product_name, a.aisle
    order by count(*) desc
),
aisle_orders_rank as (
    select 
        ao.product_name, 
        ao.aisle, 
        ao.order_num, 
        rank() over (
            partition by ao.aisle 
            order by ao.order_num desc) as product_rank
    from aisle_orders ao
),
aisle_rank as (
    select 
        a.aisle, 
        count(*) aisle_order_num,  
        rank() over (
            order by count(*) desc) as aisle_rank
    from products p
    join orders_products_prior op 
    on p.product_id = op.product_id
    join aisles a 
    on a.aisle_id = p.aisle_id
    group by a.aisle
    order by count(*) desc
)
select 
    aor.product_name, 
    aor.aisle, 
    aor.order_num
from aisle_orders_rank aor
join aisle_rank ar
on aor.aisle = ar.aisle
where aor.product_rank <= 3
order by ar.aisle_rank, aor.product_rank;

--Rewriting the above query to include aisles and departments
select 
    a.product_name, 
    a.aisle, 
    d.department, 
    a.order_num
from 
    (
    select 
        product_name, 
        aisle, 
        order_num, 
        rank() over (
        partition by aisle 
        order by order_num desc) as product_rank
    from
        (
        select 
            p.product_name, 
            a.aisle, 
            count(*) order_num
        from products p
        join orders_products_prior op 
        on p.product_id = op.product_id
        join aisles a 
        on a.aisle_id = p.aisle_id
        group by p.product_name, a.aisle
        order by count(*) desc
        ) 
    order by order_num desc
    ) a
join 
    (
    select 
        aisle, 
        aisle_order_num, 
        aisle_rank
    from
        (
        select 
            a.aisle, 
            count(*) aisle_order_num,  
            rank() over (
            order by count(*) desc) as aisle_rank
        from products p
        join orders_products_prior op 
        on p.product_id = op.product_id
        join aisles a
        on a.aisle_id = p.aisle_id
        group by a.aisle
        order by count(*) desc
        )
    ) b
    on a.aisle = b.aisle
join products p
    on p.product_name = a.product_name  
join departments d
    on p.department_id = d.department_id
where product_rank <= 3
and (department = 'frozen' or department = 'bulk')
order by b.aisle_rank, a.product_rank;

--Frozen juice is the least frequented aisle 
--Other aisles in the frozen department are much more popular
--This results in the frozen department appearing above the bulk department in the department rank despite the unpopularity of frozen juice 


--Rewriting the above query using subquery factoring
with aisle_orders as (
    select 
        p.product_name, 
        a.aisle, 
        count(*) order_num
    from products p
    join orders_products_prior op on p.product_id = op.product_id
    join aisles a on a.aisle_id = p.aisle_id
    group by p.product_name, a.aisle
    order by count(*) desc
),
aisle_orders_rank as (
    select 
        ao.product_name, 
        ao.aisle, 
        ao.order_num, 
        rank() over (
            partition by ao.aisle 
            order by ao.order_num desc) as product_rank
    from aisle_orders ao
),
aisle_rank as (
    select 
        a.aisle, 
        count(*) aisle_order_num,  
        rank() over (
            order by count(*) desc) as aisle_rank
    from products p
    join orders_products_prior op 
    on p.product_id = op.product_id
    join aisles a 
    on a.aisle_id = p.aisle_id
    group by a.aisle
    order by count(*) desc
)
select 
    aor.product_name, 
    aor.aisle, 
    d.department, 
    aor.order_num
from aisle_orders_rank aor
join aisle_rank ar
on aor.aisle = ar.aisle
join products p
on aor.product_name = p.product_name
join departments d 
on p.department_id = d.department_id
where aor.product_rank <= 3
--and (d.department = 'frozen' or d.department = 'bulk')
order by ar.aisle_rank, aor.product_rank;
