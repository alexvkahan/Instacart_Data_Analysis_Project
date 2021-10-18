--this file is used for describing the different tables provided by the data set and viewing the first 10 rows of each table to get an example of rows in each table.

describe demo.aisles;

describe demo.departments;

describe demo.orders;

describe DEMO.orders_products_prior;

describe Demo.products;

select *
from demo.aisles
fetch first 10 rows only;

select *
from demo.departments
fetch first 10 rows only;

select *
from demo.orders
fetch first 10 rows only;

select *
from DEMO.orders_products_prior
fetch first 10 rows only;

select *
from demo.products
fetch first 10 rows only;
