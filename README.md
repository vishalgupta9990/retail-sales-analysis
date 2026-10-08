
# Retail Sales Analysis

## 📌 Project Overview

This project analyzes retail sales data using **PostgreSQL** to understand sales performance, customer behavior, category performance, purchasing patterns, and profitability.

The project includes database creation, data exploration, data cleaning, and business-focused SQL analysis.

---

## 🎯 Project Objectives

The main objectives of this project are:

* Analyze overall sales performance
* Identify the best-performing categories
* Understand customer purchasing behavior
* Analyze sales by gender
* Identify the best-selling month in each year
* Analyze sales by time of day
* Identify high-value transactions
* Identify top customers based on total sales
* Analyze revenue, cost, and profit
* Extract meaningful business insights using SQL

---

## 📊 Dataset

The dataset contains retail transaction-level information.

### Columns

| Column            | Description                   |
| ----------------- | ----------------------------- |
| `transactions_id` | Unique transaction identifier |
| `sale_date`       | Date of the transaction       |
| `sale_time`       | Time of the transaction       |
| `customer_id`     | Unique customer identifier    |
| `gender`          | Gender of the customer        |
| `age`             | Age of the customer           |
| `category`        | Product category              |
| `quantity`        | Quantity purchased            |
| `price_per_unit`  | Price per unit                |
| `cogs`            | Cost of goods sold            |
| `total_sale`      | Total sales amount            |

---

## 🛠️ Tools & Technologies

* PostgreSQL
* pgAdmin
* SQL
* CSV

---

## 🗂️ Project Structure

```text
retail-sales-analysis/
│
├── README.md
├── Retail Sales Analysis.csv
├── 01_database_setup.sql
└── Retail_Sales_Analysis_query.sql
```

### File Description

#### `Retail Sales Analysis.csv`

Contains the retail sales dataset used for the analysis.

#### `01_database_setup.sql`

Contains SQL queries for:

* Creating the `retail_sales` database
* Creating the `retail_sales` table
* Defining table columns and data types

#### `Retail_Sales_Analysis_query.sql`

Contains SQL queries for:

* Data exploration
* Data cleaning
* Sales analysis
* Customer analysis
* Category analysis
* Gender analysis
* Date and time analysis
* Profit analysis

#### `README.md`

Provides an overview of the project, dataset, methodology, SQL analysis, and business questions.

---

# 🧹 Data Cleaning

The following data-cleaning steps were performed using SQL:

* Checked for missing values
* Removed records containing NULL values
* Checked for duplicate transaction IDs
* Reviewed available categories
* Checked the date range of the dataset

### NULL Value Check

```sql
SELECT *
FROM retail_sales
WHERE
    sale_date IS NULL
    OR sale_time IS NULL
    OR customer_id IS NULL
    OR gender IS NULL
    OR age IS NULL
    OR category IS NULL
    OR quantity IS NULL
    OR price_per_unit IS NULL
    OR cogs IS NULL
    OR total_sale IS NULL;
```

### Duplicate Transaction Check

```sql
SELECT
    transactions_id,
    COUNT(*) AS duplicate_count
FROM retail_sales
GROUP BY transactions_id
HAVING COUNT(*) > 1;
```

---

# 🔍 SQL Analysis

## 1. Total Sales

```sql
SELECT
    SUM(total_sale) AS total_sales
FROM retail_sales;
```

## 2. Average Sale Amount

```sql
SELECT
    ROUND(AVG(total_sale), 2) AS average_sale
FROM retail_sales;
```

## 3. Total Quantity Sold

```sql
SELECT
    SUM(quantity) AS total_quantity_sold
FROM retail_sales;
```

## 4. Sales by Category

```sql
SELECT
    category,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;
```

## 5. Transactions by Category

```sql
SELECT
    category,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category
ORDER BY total_transactions DESC;
```

## 6. Unique Customers by Category

```sql
SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;
```

## 7. Top 5 Customers

```sql
SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

## 8. Sales by Gender

```sql
SELECT
    gender,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY gender
ORDER BY total_sales DESC;
```

## 9. Monthly Sales

```sql
SELECT
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;
```

## 10. Best-Selling Month in Each Year

This analysis uses a **CTE** and a **window function** to rank monthly sales within each year.

```sql
WITH monthly_sales AS
(
    SELECT
        EXTRACT(YEAR FROM sale_date) AS year,
        EXTRACT(MONTH FROM sale_date) AS month,
        SUM(total_sale) AS total_sales
    FROM retail_sales
    GROUP BY year, month
),

ranked_sales AS
(
    SELECT
        *,
        RANK() OVER (
            PARTITION BY year
            ORDER BY total_sales DESC
        ) AS sales_rank
    FROM monthly_sales
)

SELECT
    year,
    month,
    total_sales
FROM ranked_sales
WHERE sales_rank = 1
ORDER BY year;
```

## 11. High-Value Transactions

```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

## 12. Sales by Time of Day

Transactions are classified into Morning, Afternoon, and Evening using a `CASE` statement.

```sql
WITH hourly_sales AS
(
    SELECT
        *,
        CASE
            WHEN sale_time < '12:00:00'
                THEN 'Morning'
            WHEN sale_time <= '17:00:00'
                THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)

SELECT
    shift,
    COUNT(*) AS total_orders
FROM hourly_sales
GROUP BY shift
ORDER BY total_orders DESC;
```

## 13. Profit by Category

```sql
SELECT
    category,
    SUM(total_sale) AS total_sales,
    SUM(cogs) AS total_cogs,
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;
```

## 14. Customers with Multiple Purchases

```sql
SELECT
    customer_id,
    COUNT(*) AS number_of_purchases,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY total_sales DESC;
```

---

# 📋 Business Questions

This project answers the following business questions:

1. What is the total sales generated by the business?
2. What is the average transaction value?
3. Which category generates the highest sales?
4. Which category has the highest number of transactions?
5. Which category sells the highest quantity?
6. Who are the top 5 customers based on total sales?
7. How many unique customers purchased from each category?
8. Which gender contributes more to total sales?
9. Which month has the highest sales in each year?
10. Which time of day has the highest number of orders?
11. How many transactions have sales greater than 1000?
12. Which category generates the highest profit?
13. Which customers have made multiple purchases?

---

# 💡 Key Insights

The key findings from the analysis will be documented here after executing the SQL queries.

The analysis will identify:

* Best-performing sales category
* Highest-sales month for each year
* Top customers by revenue
* Most active time of day
* Most profitable category
* High-value transaction patterns
* Customer purchasing patterns

---

# 🚀 Future Improvements

This project can be extended into a complete Data Analytics portfolio project by:

* Performing additional data cleaning and analysis using Python/Pandas
* Connecting cleaned data to PostgreSQL
* Creating an interactive Power BI dashboard
* Connecting Power BI directly to PostgreSQL
* Adding visual KPIs and charts
* Performing deeper customer segmentation
* Adding advanced business analysis

---

# 👤 About

This project was created as part of my **Data Analyst portfolio** to demonstrate practical skills in:

* SQL
* PostgreSQL
* Data Cleaning
* Data Analysis
* Business Problem Solving

The goal is to transform raw retail transaction data into meaningful business insights using SQL.

