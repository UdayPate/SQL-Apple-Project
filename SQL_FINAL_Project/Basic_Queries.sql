
------------------------------------------------------------
-- Query # 1
------------------------------------------------------------
-- This query will display all iphones from newest to oldest
SELECT p.product_id, p.product_name, p.launch_date
FROM products p
WHERE p.product_name LIKE 'iPhone%'
ORDER BY p.launch_date DESC;

------------------------------------------------------------
-- Query # 2
------------------------------------------------------------

-- This query will finds the names of all the laptops and their launch date
SELECT p.product_name, c.category_name, p.launch_date
FROM products p, category c
WHERE c.category_id = p.category_id AND c.category_name = 'Laptop';

------------------------------------------------------------
-- Query # 3
------------------------------------------------------------
-- This query will find the number of sales that occured during the month of december
SELECT count(s.sale_id)
FROM sales s
WHERE s.sale_date >= '2023-12-01' AND s.sale_date <= '2023-12-31';

------------------------------------------------------------
-- Query # 4
------------------------------------------------------------

-- This query will find the number of warranty claims filed in 2020
SELECT count(w.claim_id)
FROM warranty w
WHERE w.claim_date >= '2020-01-01' AND w.claim_date <= '2020-12-31';

------------------------------------------------------------
-- Query # 5
------------------------------------------------------------

-- This query will find the percentage of warranty claims where the status was void 
SELECT ROUND( count(w.claim_id)/(SELECT COUNT(*) FROM warranty) :: NUMERIC * 100 , 2) AS warranty_void_percentage
FROM warranty w
WHERE w.repair_status = 'Warranty Void';


------------------------------------------------------------
-- Query # 6
------------------------------------------------------------

-- This query will show the total number of units sold per store
SELECT s.store_id, st.store_name, SUM(s.quantity) AS total_units_sold
FROM stores st, sales s
WHERE st.store_id  = s.store_id
GROUP BY s.store_id, st.store_name
ORDER BY total_units_sold DESC;

------------------------------------------------------------
-- Query # 7
------------------------------------------------------------

-- Count the number of sales per store and list the top 10
SELECT st.store_id, st.store_name, count(s.sale_id) AS total_number_sales
FROM sales s, stores st
WHERE s.store_id = st.store_id
GROUP BY st.store_id, st.store_name
LIMIT 10;

------------------------------------------------------------
-- Query # 8
------------------------------------------------------------

-- Count the numer of stores per country and show the top 10
SELECT country, count(*) AS total_per_country
FROM stores s
GROUP BY country
ORDER BY total_per_country DESC
LIMIT 10;


------------------------------------------------------------
-- Query # 9
------------------------------------------------------------

-- To see which products are most expensive we did the follwing query
SELECT c. category_id, category_name, ROUND(AVG(p.price)::numeric, 2) AS avg_price
FROM category c, products p
WHERE c.category_id = p.category_id
GROUP BY c.category_id, c.category_name
ORDER BY avg_price DESC;
