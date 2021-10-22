
--granting permissions on all tables to different project members 
GRANT ALL ON demo.aisles TO alkahan, camuhl, thompsy;
GRANT ALL ON demo.departments TO alkahan, camuhl, thompsy;
GRANT ALL ON demo.order_products_train TO alkahan, camuhl, thompsy;
GRANT ALL ON demo.orders TO alkahan, camuhl, thompsy;
GRANT ALL ON demo.orders_products_prior TO alkahan, camuhl, thompsy;
GRANT ALL ON demo.products TO alkahan, camuhl, thompsy;

--giving users ablitity to create tables
ALTER USER alkahan quota unlimited on data;
ALTER USER camuhl quota unlimited on data;
ALTER USER thompsy quota unlimited on data;

--giving permission to create public synonym 
GRANT CREATE PUBLIC SYNONYM TO alkahan, camuhl, thompsy;

--creating synonyms for easier querying
CREATE OR REPLACE PUBLIC SYNONYM aisles 
   FOR demo.aisles;
   
CREATE OR REPLACE PUBLIC SYNONYM departments
   FOR demo.departments;
  
CREATE OR REPLACE PUBLIC SYNONYM order_products_train 
   FOR demo.order_products_train;
 
CREATE OR REPLACE PUBLIC SYNONYM orders 
   FOR demo.orders;
   
CREATE OR REPLACE PUBLIC SYNONYM orders_products_prior 
   FOR demo.orders_products_prior;
   
CREATE OR REPLACE PUBLIC SYNONYM products 
   FOR demo.products;
   
