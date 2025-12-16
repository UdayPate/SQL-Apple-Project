# Apple Product Sales Analytics & Predictive Modeling Project

## Project Overview

This is a comprehensive **SQL-based data analytics and predictive modeling project** that analyzes Apple product sales data across multiple stores, countries, and time periods. The project demonstrates advanced SQL techniques, database optimization, statistical modeling, and interactive data visualization.

The project encompasses:
- **Complex multi-table relational database** with 5 interconnected tables
- **16+ analytical queries** ranging from basic filtering to advanced window functions
- **Performance optimization** through strategic indexing (achieving 85-97% query speed improvements)
- **Linear regression implementation** entirely in SQL for predictive analytics
- **Interactive Streamlit dashboard** with 6 distinct analytical views
- **Large-scale data processing** handling over 1 million sales records

---

## Database Architecture

### Schema Design

The project uses a **normalized relational database** with the following structure:

```
┌─────────────┐
│   stores    │
│─────────────│
│ store_id PK │
│ store_name  │
│ city        │
│ country     │
└──────┬──────┘
       │
       │ 1:N
       │
┌──────▼──────┐      ┌─────────────┐
│    sales    │      │  category   │
│─────────────│      │─────────────│
│ sale_id PK  │      │category_id  │
│ sale_date   │      │category_name│
│ store_id FK │      └──────┬──────┘
│ product_id  │             │
│ quantity    │             │ 1:N
└──────┬──────┘             │
       │                    │
       │ 1:N                │
       │                    │
┌──────▼──────┐      ┌──────▼──────┐
│  warranty   │      │  products   │
│─────────────│      │─────────────│
│ claim_id PK │      │product_id PK│
│ claim_date  │      │product_name │
│ sale_id FK  │      │category_id  │
│repair_status│      │launch_date  │
└─────────────┘      │price        │
                     └─────────────┘
```

### Tables

1. **`stores`** - Store information (store_id, store_name, city, country)
2. **`category`** - Product categories (category_id, category_name)
3. **`products`** - Product catalog (product_id, product_name, category_id, launch_date, price)
4. **`sales`** - Sales transactions (sale_id, sale_date, store_id, product_id, quantity)
5. **`warranty`** - Warranty claims (claim_id, claim_date, sale_id, repair_status)

### Data Scale
- **Sales Records**: 1,040,000+ transactions
- **Products**: 60+ Apple products across multiple categories
- **Stores**: Multiple stores across different countries
- **Time Range**: Sales data spanning multiple years (2020-2023)

---

## Query Complexity & Features

### Basic Queries (9 Queries)

Demonstrates fundamental SQL operations:
- **Pattern Matching**: Filtering products by name patterns (e.g., all iPhones)
- **Date Range Filtering**: Sales and warranty claims within specific time periods
- **Aggregations**: COUNT, SUM, AVG with GROUP BY
- **Subqueries**: Percentage calculations using correlated subqueries
- **Joins**: INNER JOINs and implicit joins across multiple tables
- **Sorting & Limiting**: ORDER BY and LIMIT clauses

### Advanced Queries (7 Complex Queries)

Demonstrates sophisticated SQL techniques:

#### 1. **Multi-View Analysis with NOT IN Logic**
   - Creates two views to identify stores with/without warranty claims
   - Uses nested subqueries and set operations
   - **Complexity**: O(n²) subquery operations

#### 2. **Window Functions with Ranking**
   - Identifies best-selling day per store using `RANK() OVER()`
   - Partitions by store and orders by total units sold
   - **Complexity**: Window function with partitioning

#### 3. **Multi-Level Aggregation with CTEs**
   - Uses Common Table Expressions (CTEs) for complex aggregations
   - Identifies least-selling products by country and year
   - **Complexity**: Multi-dimensional grouping with temporal analysis

#### 4. **Recursive Analysis Across Dimensions**
   - Finds products that were least-selling most frequently
   - Combines ranking, grouping, and counting operations
   - **Complexity**: Nested CTEs with multiple aggregation levels

#### 5. **LEFT JOIN with Zero-Value Handling**
   - Counts warranty claims per product including products with zero claims
   - Demonstrates proper NULL handling in aggregations
   - **Complexity**: Multiple LEFT JOINs preserving all products

#### 6. **CASE-Based Categorization**
   - Categorizes warranty claim severity (No Claims, Single Claim, Repeat Repairs, Chronic Issue)
   - Uses CTEs and conditional logic
   - **Complexity**: Business logic implementation in SQL

#### 7. **Multi-Criteria Store Performance Analysis**
   - Evaluates stores based on sales volume AND warranty claims
   - Creates performance categories (Elite Store, Strong Store, Developing, No Sales)
   - **Complexity**: Multi-dimensional business intelligence query


---

## Performance Optimization

### Indexing Strategy

The project includes comprehensive **query performance analysis** using `EXPLAIN ANALYZE`:

#### Indexes Created:
1. **`sales_product_id`** - Index on `sales(product_id)`
2. **`sales_store_id`** - Index on `sales(store_id)`
3. **`sales_sale_date`** - Index on `sales(sale_date)`

#### Performance Improvements:

| Query Type | Before Index | After Index | Improvement |
|------------|--------------|-------------|-------------|
| **product_id lookup** | 53.722 ms | 7.434 ms | **86.2% faster** |
| **store_id lookup** | 62.976 ms | 1.616 ms | **97.4% faster** |
| **sale_date lookup** | 49.567 ms | 1.560 ms | **96.9% faster** |

**Key Achievement**: Achieved **85-97% query performance improvement** through strategic indexing on foreign keys and frequently queried columns.

---

## Linear Regression in SQL

### Mathematical Implementation

The project implements **linear regression entirely in SQL** using mathematical formulas:

**Regression Formula:**
- **Slope (β₁)**: `(n * Σ(xy) - Σ(x) * Σ(y)) / (n * Σ(x²) - (Σ(x))²)`
- **Intercept (β₀)**: `(Σ(y) - β₁ * Σ(x)) / n`


### Features:
- **Pure SQL Implementation**: No external libraries required
- **Predictive Analytics**: Predicts units sold based on product price
- **Mathematical Accuracy**: Implements standard least squares regression
- **Scalable**: Works with any dataset size

### Validation:
- Python comparison using scikit-learn (included in `Linear_Regression/SQL.ipynb`)
- Results validated against Python's LinearRegression model
- Demonstrates SQL's capability for statistical computing

---

## Interactive Dashboard

### Streamlit Application

A comprehensive **6-page interactive dashboard** built with Streamlit and Plotly:

#### Pages:

1. **Sales Overview**
   - Units sold by category (bar charts)
   - Top 10 stores by sales volume
   - Interactive visualizations

2. **Warranty Analysis**
   - Warranty claims per product
   - Product reliability metrics
   - Claim frequency analysis

3. **Time Trends**
   - Monthly sales trends (line charts)
   - Temporal pattern analysis
   - Seasonal trend identification

4. **Regression Analysis**
   - Price vs. units sold scatter plot
   - Regression line overlay
   - Interactive prediction tool
   - Real-time unit prediction based on price input

5. **Store Performance**
   - Store-specific analytics
   - Best-selling products per store
   - Warranty claims per store
   - Customizable store selection

6. **Product Details**
   - Individual product analytics
   - Price, sales, and warranty information
   - Monthly sales trends per product
   - Regression-based predictions

### Technical Stack:
- **Backend**: PostgreSQL database connection via `psycopg2`
- **Frontend**: Streamlit for web interface
- **Visualization**: Plotly Express for interactive charts
- **Data Processing**: Pandas for data manipulation

### Dashboard Features:
- **Real-time Database Queries**: Direct connection to PostgreSQL
- **Interactive Filters**: Dropdown selections for stores and products
- **Dynamic Visualizations**: Responsive charts that update based on selections
- **Predictive Interface**: User-input price prediction tool
- **Multi-page Navigation**: Sidebar navigation between analytical views

---

## 📁 Project Structure

```
SQL_FINAL_Project/
│
├── Schema.sql                          # Database schema creation
├── Basic_Queries.sql                   # 9 fundamental SQL queries
├── Advanced_queries.sql                # 7 complex analytical queries
├── Creating_index.sql                  # Performance optimization with indexes
│
├── Linear_Regression/
│   ├── Linear_regression_query.sql     # Regression coefficients calculation
│   ├── LR_prediction_query.sql         # Prediction generation query
│   └── SQL.ipynb                       # Python validation notebook
│
├── Dashboard_Code&Photos/
│   ├── Code.py                         # Streamlit dashboard application
│   └── Photos/                         # Dashboard screenshots
│       ├── Dashboard_1.png
│       ├── Dashboard_2.png
│       ├── Dashboard_3.png
│       ├── Dashboard4.png
│       ├── Dashboard_5.png
│       ├── Dashboard_6.png
│       ├── Dashboard_7.png
│       ├── Dashboard_8.png
│       └── Proof_of_Dashboard.png
│
├── Data_folder/
│   ├── category.csv                    # Category data
│   ├── products.csv                    # Product catalog
│   ├── sales.csv                       # Sales transactions (1M+ records)
│   ├── stores.csv                      # Store information
│   └── warranty.csv                    # Warranty claims
│
└── ReportSQL.pdf                       # Comprehensive project report
```

---

## Key Achievements

 **Comprehensive Database Design**: Normalized schema with proper foreign key relationships  
 **16+ Analytical Queries**: From basic to advanced SQL operations  
 **85-97% Performance Improvement**: Through strategic indexing  
 **Pure SQL Regression**: Mathematical implementation without external libraries  
**Interactive Dashboard**: 6-page analytical interface with real-time queries  
**Large-Scale Processing**: Efficient handling of 1M+ sales records  
**Multi-dimensional Analysis**: Country, time, product, and store dimensions  
**Predictive Analytics**: Price-based sales prediction model  

---

## Technologies Used

- **Database**: PostgreSQL
- **SQL**: Advanced SQL with window functions, CTEs, subqueries
- **Python**: Data processing and visualization
- **Streamlit**: Web application framework
- **Plotly**: Interactive data visualization
- **Pandas**: Data manipulation and analysis
- **Jupyter Notebook**: Data validation and comparison
---


