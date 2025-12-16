----------------------------------------------------------------------------
-- Query # 1 Determine how many stores have never had a warranty claim filed.
-----------------------------------------------------------------------------

CREATE VIEW sales_without_warrantyclaim AS
SELECT st.store_name, s.store_id, s.sale_id
FROM sales s, stores st
WHERE s.store_id = st.store_id
  AND s.sale_id NOT IN (
      SELECT w.sale_id
      FROM warranty w
  );

CREATE VIEW sales_with_warrantyclaim AS
SELECT st.store_name, s.store_id, s.sale_id	
FROM sales s, stores st
WHERE s.store_id = st.store_id
  AND s.sale_id IN (
      SELECT w.sale_id
      FROM warranty w
  );

-- Count stores that never had a warranty claim
SELECT COUNT(DISTINCT sww.store_id) AS stores_without_warranty_claims
FROM sales_without_warrantyclaim sww
WHERE sww.store_id NOT IN (
    SELECT swc.store_id
    FROM sales_with_warrantyclaim swc
);



------------------------------------------------------------------------------------------
-- Query # 2 For each store, identify the best-selling day based on highest quantity sold.
------------------------------------------------------------------------------------------
SELECT s.store_id, st.store_name, s.day_name, s.total_unit_sold, s.rank
FROM (SELECT s.store_id, TO_CHAR(s.sale_date, 'Day') as day_name, 
			SUM(s.quantity) as total_unit_sold, 
			RANK() OVER(PARTITION BY s.store_id ORDER BY SUM(s.quantity) DESC) as rank 
		 FROM sales s
		 GROUP BY s.store_id, TO_CHAR(s.sale_date, 'Day')) AS s, stores st
where s.store_id = st.store_id  AND rank = 1
ORDER BY total_unit_sold DESC
LIMIT 10;






--------------------------------------------------------------------------------------------------------
-- Query # 3 Identify the least selling product in each country for each year based on total units sold.
--------------------------------------------------------------------------------------------------------
WITH product_rank AS 
(SELECT st.country, EXTRACT(YEAR FROM s.sale_date) AS year, p.product_name, SUM(s.quantity) AS num_units_sold, 
RANK() OVER (PARTITION BY st.country, EXTRACT(YEAR FROM s.sale_date) ORDER BY SUM(s.quantity) ASC) as rank
FROM sales s, stores st, products p
WHERE s.store_id = st.store_id AND s.product_id = p.product_id
GROUP BY st.country, p.product_name, EXTRACT(YEAR FROM s.sale_date))


SELECT *
FROM product_rank
WHERE rank = 1
ORDER BY num_units_sold
LIMIT 10;



------------------------------------------------------------------------------------------------------------
-- Query # 4 Across all countries and all years, which products were the least-selling product the most often
-------------------------------------------------------------------------------------------------------------

WITH product_rank AS 
(SELECT st.country, EXTRACT(YEAR FROM s.sale_date) AS year, p.product_name, SUM(s.quantity) AS num_units_sold, 
RANK() OVER (PARTITION BY st.country, EXTRACT(YEAR FROM s.sale_date) ORDER BY SUM(s.quantity) ASC) as rank
FROM sales s, stores st, products p
WHERE s.store_id = st.store_id AND s.product_id = p.product_id
GROUP BY st.country, p.product_name, EXTRACT(YEAR FROM s.sale_date))

SELECT pr.product_name, COUNT(*) AS num_times_appeared
FROM product_rank pr
WHERE pr.rank = 1 
GROUP BY pr.product_name
ORDER BY num_times_appeared DESC
LIMIT 10;


---------------------------------------------------------------------------------------------------------------------------
-- Query # 5 Find all the products and count how many warranty claim each product has and include products with zero claims
---------------------------------------------------------------------------------------------------------------------------
SELECT p.product_id, p.product_name, c.category_name, count(w.claim_id) AS num_claims
FROM products P
JOIN category c ON p.category_id = c.category_id
LEFT JOIN sales s ON s.product_id = p.product_id 
LEFT JOIN warranty w ON w.sale_id = s.sale_id
GROUP BY p.product_id, p.product_name, c.category_name
ORDER BY num_claims ASC 
LIMIT 10;

----------------------------------------------------------------------------------------------------------------------------------------
-- Query # 6 Identify the top 10 sales with the most warranty claims and categorize each sale based on how severe the warranty issue is.
----------------------------------------------------------------------------------------------------------------------------------------
WITH warranty_counts AS (
    SELECT 
        s.sale_id,
        COUNT(w.claim_id) AS claim_count
    FROM sales s
    LEFT JOIN warranty w ON s.sale_id = w.sale_id
    GROUP BY s.sale_id
)

SELECT 
    wc.sale_id,
	s.product_id,
	p.product_name,
    wc.claim_count,
    CASE 
        WHEN wc.claim_count = 0 THEN 'No Claims'
        WHEN wc.claim_count = 1 THEN 'Single Claim'
        WHEN wc.claim_count BETWEEN 2 AND 4 THEN 'Repeat Repairs'
        ELSE 'Chronic Issue'
    END AS claim_severity
FROM warranty_counts wc, sales s, products p
WHERE s.sale_id	 = wc.sale_id AND s.product_id = p.product_id
ORDER BY wc.claim_count DESC
LIMIT 10;


---------------------------------------------------------------------------------------------------------------------------
-- Query # 7 This query looks at how well is each store performing based on both sales results and warranty issues
---------------------------------------------------------------------------------------------------------------------------

SELECT
    st.store_name,
    COALESCE(SUM(s.quantity), 0) AS total_units,
    COUNT(w.claim_id) AS total_claims,
    CASE 
        WHEN SUM(s.quantity) >= 5000 AND COUNT(w.claim_id) < 20 THEN 'Elite Store'
        WHEN SUM(s.quantity) BETWEEN 1000 AND 4999 THEN 'Strong Store'
        WHEN SUM(s.quantity) BETWEEN 1 AND 999 THEN 'Developing'
        ELSE 'No Sales'
    END AS store_category
FROM stores st
LEFT JOIN sales s ON st.store_id = s.store_id
LEFT JOIN warranty w ON s.sale_id = w.sale_id
GROUP BY st.store_id, st.store_name
ORDER BY total_units DESC
LIMIT 10;