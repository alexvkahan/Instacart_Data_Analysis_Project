# Instacart Data Analysis Project
Dedicated repo for the Instacart Data Analysis Project completed as part of SQL Club

Created By: Alex Kahan, Chris Muhlenkamp, Thomas Psyhogeos

Table of Contents:

The data used in this project can be found in the following link: https://www.kaggle.com/c/instacart-market-basket-analysis/data

Data Model:

![Screen Shot 2021-09-21 at 3 24 08 PM](https://user-images.githubusercontent.com/23488766/134714658-78778fc5-7e13-4fe8-967f-af1d798334de.png)

Conceptual Architecture:

![Instacart_Arch_Diagram](https://user-images.githubusercontent.com/23488766/134990739-f763575e-dc41-4878-aba2-a26974548545.png)

SQL Scripts:

[Demo_Administration_Tasks.sql](https://github.com/alexvkahan/sql-club/blob/main/Demo_Administration_Tasks.sql) - Altering user perrmissions for each contributor and creating synonyms for relevant database objects to simplify queries.

[Instacart_Data_Discovery.sql](https://github.com/alexvkahan/sql-club/blob/main/Instacart_Data_Discovery.sql) - Simple script to describe each table and query for 10 rows from each to familiarize ourselves with the dataset.

[Orders.sql](https://github.com/alexvkahan/sql-club/blob/main/Orders.sql) - Script for analysis of orders table, looking at popular order days and times, general order statistics, etc. 

[Product_Count_Order.sql](https://github.com/alexvkahan/sql-club/blob/main/Product_Count_Order.sql) - Script for analysis of order products table, looking at popular items, orders by customers & products, etc.

[Departments_Aisle_Analysis.sql](https://github.com/alexvkahan/sql-club/blob/main/Departments_Aisle_Analysis.sql) - Script for analysis of products, looking at departments and aisles, popular items, order totals, etc.

Data Loading Process:

To load the project data into our Autonomous Data Warehouse, we used the the Data Loading Tool from the SQL Workshop Utility in APEX.  APEX is a free low code development tool provided with the Oracle database and is preinstalled and configured for use in the Autonomous Database.  The steps for loading the data files into the database can be found here: [https://blogs.oracle.com/apex/post/load-data-into-existing-tables-with-apex-191](url)

