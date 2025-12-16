--Improving Query performance


------------------------------------------------------------
-- Query Performance Testing: product_id
------------------------------------------------------------

--Before the index:
	--ET: 53.722 ms
	--pt: 0.086 ms
EXPLAIN ANALYZE
SELECT * 
FROM sales s
WHERE s.product_id = 'P-44';

--Creating the index:
CREATE INDEX sales_product_id on sales(product_id);

--After the index:
	--ET: 7.434 ms
	--pt: 1.298 ms
EXPLAIN ANALYZE
SELECT * 
FROM sales s
WHERE s.product_id = 'P-44';


------------------------------------------------------------
-- Query Performance Testing: store_id
------------------------------------------------------------


--Before the index:
	--ET: 62.976 ms
	--pt: 0.098 ms
EXPLAIN ANALYZE
SELECT * 
FROM sales s
WHERE s.store_id = 'ST-31';

--Creating the index
CREATE INDEX sales_store_id ON sales(store_id);

--After the index:
	--ET: 1.616 ms
	--pt: 1.638 ms
EXPLAIN ANALYZE
SELECT * 
FROM sales s
WHERE s.store_id = 'ST-31';


------------------------------------------------------------
-- Query Performance Testing: sale_date
------------------------------------------------------------

--Before the index:
	--ET: 49.567 ms
	--pt: 0.097 ms
EXPLAIN ANALYZE
SELECT * 
FROM sales s
WHERE DATE(s.sale_date) = '2021-09-16';

--Creating the index
CREATE INDEX sales_sale_date ON sales(sale_date);

--After the index:
	--ET: 1.560 ms
	--pt: 1.051 ms
EXPLAIN ANALYZE
SELECT * 
FROM sales s
WHERE DATE(s.sale_date) = '2021-09-16';
