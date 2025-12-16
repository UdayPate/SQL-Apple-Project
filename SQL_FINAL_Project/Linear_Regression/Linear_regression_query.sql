-- Linear Regression in SQL:
-- Predict total units sold based on product price

WITH sales_data AS (
    SELECT 
        p.product_id,
        p.price,
        SUM(s.quantity) AS total_units_sold
    FROM products p
    JOIN sales s ON s.product_id = p.product_id
    GROUP BY p.product_id, p.price
),

stats AS (
    SELECT
        COUNT(*) AS n,
        SUM(price) AS sum_x,
        SUM(total_units_sold) AS sum_y,
        SUM(price * total_units_sold) AS sum_xy,
        SUM(price * price) AS sum_x2
    FROM sales_data
)

SELECT
    -- β1 = (n * Σ(xy) - Σ(x) * Σ(y)) / (n * Σ(x²) - (Σ(x))²)
    (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x) AS slope,

    -- β0 = (Σ(y) - β1 * Σ(x)) / n
    (sum_y - ((n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)) * sum_x) / n 
        AS intercept
FROM stats;
