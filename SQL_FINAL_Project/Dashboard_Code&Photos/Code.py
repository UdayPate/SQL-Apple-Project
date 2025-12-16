import streamlit as st
import pandas as pd
import psycopg2
import plotly.express as px

# -------------------------------
# DATABASE CONNECTION
# -------------------------------
def run_query(query):
    conn = psycopg2.connect(
        host="127.0.0.1",
        database="Apple_db",
        user="postgres",
        password="Ud@y0803!",
        port="5433"
    )
    df = pd.read_sql(query, conn)
    conn.close()
    return df


# -------------------------------
# STREAMLIT PAGE SETTINGS
# -------------------------------
st.set_page_config(page_title="Sales Dashboard", layout="wide")
st.title("Interactive Sales, Warranty & Regression Dashboard")


# -------------------------------
# SIDEBAR NAVIGATION
# -------------------------------
# page = st.sidebar.radio(
#     "Navigation",
#     ["Sales Overview", "Warranty Analysis", "Time Trends", "Regression Analysis"]
# )

page = st.sidebar.radio(
    "Navigation",
    [
        "Sales Overview",
        "Warranty Analysis",
        "Time Trends",
        "Regression Analysis",
        "Store Performance",
        "Product Details"
    ]
)


# -------------------------------
# PAGE 1 — SALES OVERVIEW
# -------------------------------
if page == "Sales Overview":
    st.header("Sales Overview")

    # 1. Units sold by category
    st.subheader("Units Sold by Category")
    query1 = """
    SELECT c.category_name, SUM(s.quantity) AS total_units
    FROM products p
    JOIN category c ON p.category_id = c.category_id
    JOIN sales s ON s.product_id = p.product_id
    GROUP BY c.category_name
    ORDER BY total_units DESC;
    """
    df1 = run_query(query1)
    fig1 = px.bar(df1, x="category_name", y="total_units", color="category_name")
    st.plotly_chart(fig1, use_container_width=True)


    # 2. Top 10 stores by sales
    st.subheader("Top 10 Stores by Units Sold")
    query2 = """
    SELECT st.store_name, SUM(s.quantity) AS total_units
    FROM sales s
    JOIN stores st ON s.store_id = st.store_id
    GROUP BY st.store_name
    ORDER BY total_units DESC
    LIMIT 10;
    """
    df2 = run_query(query2)
    fig2 = px.bar(df2, x="store_name", y="total_units", color="total_units")
    st.plotly_chart(fig2, use_container_width=True)



# -------------------------------
# PAGE 2 — WARRANTY ANALYSIS
# -------------------------------
if page == "Warranty Analysis":
    st.header("Warranty Analysis")

    # Warranty claims per product
    st.subheader("Warranty Claims per Product")
    query3 = """
    SELECT p.product_name, COUNT(w.claim_id) AS claim_count
    FROM products p
    LEFT JOIN sales s ON s.product_id = p.product_id
    LEFT JOIN warranty w ON w.sale_id = s.sale_id
    GROUP BY p.product_name
    ORDER BY claim_count DESC;
    """
    df3 = run_query(query3)
    fig3 = px.bar(df3, x="product_name", y="claim_count")
    st.plotly_chart(fig3, use_container_width=True)



# -------------------------------
# PAGE 3 — TIME TRENDS
# -------------------------------
if page == "Time Trends":
    st.header("Time-Based Trends")

    # Monthly sales pattern
    st.subheader("Monthly Sales Trend")
    query4 = """
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(quantity) AS total_units
    FROM sales
    GROUP BY month
    ORDER BY month;
    """
    df4 = run_query(query4)
    fig4 = px.line(df4, x="month", y="total_units", markers=True)
    st.plotly_chart(fig4, use_container_width=True)


# -------------------------------
# GLOBAL REGRESSION DATA (available for ALL pages)
# -------------------------------
query5 = """
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
),
coefficients AS (
    SELECT
        (n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x) AS slope,
        (sum_y - ((n * sum_xy - sum_x * sum_y) / (n * sum_x2 - sum_x * sum_x)) * sum_x) / n AS intercept
    FROM stats
)
SELECT
    sd.product_id,
    sd.price,
    sd.total_units_sold,
    ROUND((coeff.slope * sd.price + coeff.intercept)::numeric, 2) AS predicted_units_sold
FROM sales_data sd
CROSS JOIN coefficients coeff
ORDER BY predicted_units_sold DESC;
"""

# Pull regression output ONCE globally
df5 = run_query(query5)

# Compute slope & intercept globally
slope = (df5["predicted_units_sold"][1] - df5["predicted_units_sold"][0]) / (df5["price"][1] - df5["price"][0])
intercept = df5["predicted_units_sold"][0] - slope * df5["price"][0]


# -------------------------------
# PAGE 4 — REGRESSION ANALYSIS
# -------------------------------
if page == "Regression Analysis":
    st.header("Regression: Price vs Units Sold")
    # df5 = run_query(query5)
    # # Compute slope & intercept globally for use in all pages
    # slope = (df5["predicted_units_sold"][1] - df5["predicted_units_sold"][0]) / (df5["price"][1] - df5["price"][0])
    # intercept = df5["predicted_units_sold"][0] - slope * df5["price"][0]


    # Scatter plot: actual vs predicted
    st.subheader("Actual vs Predicted Units Sold")
    fig5 = px.scatter(df5, x="price", y="total_units_sold", size="total_units_sold",
                      title="Price vs Units Sold (Actual Data)")
    fig5.add_scatter(x=df5["price"], y=df5["predicted_units_sold"],
                     mode="lines", name="Regression Line")
    st.plotly_chart(fig5, use_container_width=True)

    # Show data table
    st.subheader("Regression Prediction Table")
    st.dataframe(df5)

    # -------------------------
    # Prediction Tool
    # -------------------------
    st.subheader("🔮 Predict Units Sold Based on Price")

    # Get slope & intercept from SQL output
    # (Using two data points to derive line equation)
    # slope = (df5["predicted_units_sold"][1] - df5["predicted_units_sold"][0]) / (df5["price"][1] - df5["price"][0])
    # intercept = df5["predicted_units_sold"][0] - slope * df5["price"][0]

    price_input = st.number_input("Enter a price to predict units sold:", min_value=0.0, value=500.0)

    predicted_units = slope * price_input + intercept
    st.write(f"### Predicted Units Sold: **{round(predicted_units, 2)}**")

# ----------------------------------
# PAGE 5 — STORE PERFORMANCE
# ----------------------------------
if page == "Store Performance":
    st.header("Store Performance Dashboard")

    # Store list
    store_list = run_query("""SELECT store_name FROM stores ORDER BY store_name;""")["store_name"].tolist()
    selected_store = st.selectbox("Select Store:", store_list)

    # Total sales
    query_store_sales = f"""
        SELECT 
            st.store_name,
            SUM(s.quantity) AS total_units
        FROM sales s
        JOIN stores st ON st.store_id = s.store_id
        WHERE st.store_name = '{selected_store}'
        GROUP BY st.store_name;
    """
    df_store_sales = run_query(query_store_sales)
    st.subheader("Total Units Sold")
    st.metric(label="Total Units Sold", value=int(df_store_sales["total_units"][0]))

    # Best selling products
    query_best_products = f"""
        SELECT 
            p.product_name,
            SUM(s.quantity) AS units_sold
        FROM sales s
        JOIN products p ON p.product_id = s.product_id
        JOIN stores st ON st.store_id = s.store_id
        WHERE st.store_name = '{selected_store}'
        GROUP BY p.product_name
        ORDER BY units_sold DESC
        LIMIT 10;
    """
    df_best_products = run_query(query_best_products)
    st.subheader("Top 10 Products in This Store")
    fig_best = px.bar(df_best_products, x="product_name", y="units_sold")
    st.plotly_chart(fig_best, use_container_width=True)

    # Warranty claims
    query_store_claims = f"""
        SELECT 
            COUNT(*) AS warranty_claims
        FROM warranty w
        JOIN sales s ON s.sale_id = w.sale_id
        JOIN stores st ON st.store_id = s.store_id
        WHERE st.store_name = '{selected_store}';
    """
    df_claims = run_query(query_store_claims)
    st.subheader("Warranty Claims in This Store")
    st.metric("Total Warranty Claims", int(df_claims["warranty_claims"][0]))


# ----------------------------------
# PAGE 6 — PRODUCT DETAILS
# ----------------------------------
if page == "Product Details":
    st.header("Product Details Page")

    # Product dropdown
    product_list = run_query("""SELECT product_name FROM products ORDER BY product_name;""")["product_name"].tolist()
    selected_product = st.selectbox("Select Product:", product_list)

    # Product info
    query_info = f"""
        SELECT 
            p.product_id,
            p.product_name,
            p.price
        FROM products p
        WHERE p.product_name = '{selected_product}';
    """
    df_info = run_query(query_info)
    product_id = df_info["product_id"][0]
    price = df_info["price"][0]

    st.subheader("Product Information")
    col1, col2 = st.columns(2)
    col1.metric("Price", f"${price}")

    # Units sold
    query_units = f"""
        SELECT SUM(quantity) AS total_sold
        FROM sales
        WHERE product_id = '{product_id}';
    """
    df_units = run_query(query_units)
    col2.metric("Total Units Sold", int(df_units["total_sold"][0]))

    # Warranty claims
    query_claims = f"""
        SELECT COUNT(*) AS warranty_count
        FROM warranty w
        JOIN sales s ON s.sale_id = w.sale_id
        WHERE s.product_id = '{product_id}';
    """
    df_claims = run_query(query_claims)
    st.metric("Warranty Claims", int(df_claims["warranty_count"][0]))

    # Monthly sales
    query_monthly = f"""
        SELECT 
            DATE_TRUNC('month', sale_date) AS month,
            SUM(quantity) AS units
        FROM sales
        WHERE product_id = '{product_id}'
        GROUP BY month
        ORDER BY month;
    """
    df_monthly = run_query(query_monthly)
    st.subheader("Monthly Sales Trend")
    fig_month = px.line(df_monthly, x="month", y="units", markers=True)
    st.plotly_chart(fig_month, use_container_width=True)

    # Regression prediction
    st.subheader("Predicted Units Sold (Regression Model)")
    predicted = slope * price + intercept
    st.write(f"### Predicted Units Sold: **{round(predicted, 2)}**")