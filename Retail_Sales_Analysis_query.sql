/* ============================================================
   STEP 1: DATA EXPLORATION
   ============================================================ */

-- 1.1 View the complete dataset

SELECT *
FROM retail_sales;


-- 1.2 Count total number of records

SELECT COUNT(*) AS total_records
FROM retail_sales;


-- 1.3 Check the date range of the dataset

SELECT
    MIN(sale_date) AS first_sale_date,
    MAX(sale_date) AS last_sale_date
FROM retail_sales;


-- 1.4 Check the number of unique customers

SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;


-- 1.5 Check available categories

SELECT DISTINCT category
FROM retail_sales;


/* ============================================================
   STEP 2: DATA CLEANING
   ============================================================ */

-- 2.1 Check for NULL values

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


-- 2.2 Delete records containing NULL values

DELETE FROM retail_sales
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


-- 2.3 Check for duplicate transaction IDs

SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM retail_sales
GROUP BY transaction_id
HAVING COUNT(*) > 1;


/* ============================================================
   STEP 3: BASIC DATA ANALYSIS
   ============================================================ */

-- 3.1 Total number of transactions

SELECT COUNT(*) AS total_transactions
FROM retail_sales;


-- 3.2 Total sales/revenue

SELECT
    SUM(total_sale) AS total_sales
FROM retail_sales;


-- 3.3 Average sale amount

SELECT
    ROUND(AVG(total_sale), 2) AS average_sale
FROM retail_sales;


-- 3.4 Total quantity sold

SELECT
    SUM(quantity) AS total_quantity_sold
FROM retail_sales;


/* ============================================================
   STEP 4: CATEGORY ANALYSIS
   ============================================================ */

-- 4.1 Total sales by category

SELECT
    category,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;


-- 4.2 Number of transactions by category

SELECT
    category,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category
ORDER BY total_transactions DESC;


-- 4.3 Average sale amount by category

SELECT
    category,
    ROUND(AVG(total_sale), 2) AS average_sale
FROM retail_sales
GROUP BY category
ORDER BY average_sale DESC;


-- 4.4 Total quantity sold by category

SELECT
    category,
    SUM(quantity) AS total_quantity
FROM retail_sales
GROUP BY category
ORDER BY total_quantity DESC;


/* ============================================================
   STEP 5: CUSTOMER ANALYSIS
   ============================================================ */

-- 5.1 Average age of customers who purchased Beauty products

SELECT
    ROUND(AVG(age), 2) AS average_age
FROM retail_sales
WHERE category = 'Beauty';


-- 5.2 Number of unique customers in each category

SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;


-- 5.3 Top 5 customers based on total sales

SELECT
    customer_id,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;


/* ============================================================
   STEP 6: GENDER ANALYSIS
   ============================================================ */

-- 6.1 Number of transactions by gender

SELECT
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY gender;


-- 6.2 Total sales by gender

SELECT
    gender,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY gender
ORDER BY total_sales DESC;


-- 6.3 Average sale amount by gender

SELECT
    gender,
    ROUND(AVG(total_sale), 2) AS average_sale
FROM retail_sales
GROUP BY gender;


/* ============================================================
   STEP 7: GENDER + CATEGORY ANALYSIS
   ============================================================ */

-- 7.1 Number of transactions by gender in each category

SELECT
    gender,
    category,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY gender, category
ORDER BY category, total_transactions DESC;


-- 7.2 Total sales by gender and category

SELECT
    gender,
    category,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY gender, category
ORDER BY total_sales DESC;


/* ============================================================
   STEP 8: DATE ANALYSIS
   ============================================================ */

-- 8.1 Sales made on 2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- 8.2 Total sales by year

SELECT
    EXTRACT(YEAR FROM sale_date) AS year,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY year
ORDER BY year;


-- 8.3 Total sales by month

SELECT
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;


/* ============================================================
   STEP 9: BEST-SELLING MONTH IN EACH YEAR
   ============================================================ */

-- Calculate total sales for every month

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


/* ============================================================
   STEP 10: HIGH-VALUE TRANSACTIONS
   ============================================================ */

-- 10.1 Transactions where total sale is greater than 1000

SELECT *
FROM retail_sales
WHERE total_sale > 1000;


-- 10.2 Number of high-value transactions

SELECT
    COUNT(*) AS high_value_transactions
FROM retail_sales
WHERE total_sale > 1000;


/* ============================================================
   STEP 11: CLOTHING ANALYSIS
   ============================================================ */

-- Clothing transactions with quantity >= 4
-- during November 2022

SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND quantity >= 4
  AND sale_date >= '2022-11-01'
  AND sale_date < '2022-12-01';


/* ============================================================
   STEP 12: SALES BY TIME OF DAY
   ============================================================ */

-- Classify transactions into Morning, Afternoon and Evening

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


/* ============================================================
   STEP 13: SALES BY TIME OF DAY WITH REVENUE
   ============================================================ */

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
    COUNT(*) AS total_orders,
    SUM(total_sale) AS total_sales,
    ROUND(AVG(total_sale), 2) AS average_sale
FROM hourly_sales
GROUP BY shift
ORDER BY total_sales DESC;


/* ============================================================
   STEP 14: PROFIT ANALYSIS
   ============================================================ */

-- Total Cost of Goods Sold

SELECT
    SUM(cogs) AS total_cogs
FROM retail_sales;


-- Total profit

SELECT
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales;


-- Profit by category

SELECT
    category,
    SUM(total_sale) AS total_sales,
    SUM(cogs) AS total_cogs,
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_profit DESC;


/* ============================================================
   STEP 15: TOP 5 PRODUCTS / ITEMS BY SALES
   ============================================================ */

-- If product information is not available in this table,
-- we can rank transactions/categories instead.

-- Top 5 individual transactions by sales

SELECT
    transaction_id,
    customer_id,
    category,
    total_sale
FROM retail_sales
ORDER BY total_sale DESC
LIMIT 5;


/* ============================================================
   STEP 16: CUSTOMERS WITH MULTIPLE PURCHASES
   ============================================================ */

SELECT
    customer_id,
    COUNT(*) AS number_of_purchases,
    SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
HAVING COUNT(*) > 1
ORDER BY total_sales DESC;


/* ============================================================
   STEP 17: CATEGORY PERFORMANCE SUMMARY
   ============================================================ */

SELECT
    category,
    COUNT(*) AS total_transactions,
    COUNT(DISTINCT customer_id) AS unique_customers,
    SUM(quantity) AS total_quantity,
    SUM(total_sale) AS total_sales,
    ROUND(AVG(total_sale), 2) AS average_sale,
    SUM(total_sale - cogs) AS total_profit
FROM retail_sales
GROUP BY category
ORDER BY total_sales DESC;


/* ============================================================
   END OF PROJECT
   ============================================================ */