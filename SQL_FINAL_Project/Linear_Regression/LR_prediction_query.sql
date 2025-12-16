-- Step 1: Aggregate total units sold per product
WITH sales_data AS (
    SELECT 
        p.product_id,
        p.price,
        SUM(s.quantity) AS total_units_sold
    FROM products p
    JOIN sales s ON s.product_id = p.product_id
    GROUP BY p.product_id, p.price
),

-- Step 2: Compute regression statistics
stats AS (
    SELECT
        COUNT(*) AS n,
        SUM(price) AS sum_x,
        SUM(total_units_sold) AS sum_y,
        SUM(price * total_units_sold) AS sum_xy,
        SUM(price * price) AS sum_x2
    FROM sales_data
),

-- Step 3: Compute β1 (slope) and β0 (intercept)
coefficients AS (
    SELECT
        -- slope (β1)
        (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x) AS slope,
        -- intercept (β0)
        (sum_y - ((n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)) * sum_x) / n AS intercept
    FROM stats
)

-- Step 4: Generate predictions for every product
SELECT
    sd.product_id,
    sd.price,
    sd.total_units_sold,
    ROUND((coeff.slope * sd.price + coeff.intercept)::numeric, 2) AS predicted_units_sold
FROM sales_data sd
CROSS JOIN coefficients coeff
ORDER BY predicted_units_sold DESC;
