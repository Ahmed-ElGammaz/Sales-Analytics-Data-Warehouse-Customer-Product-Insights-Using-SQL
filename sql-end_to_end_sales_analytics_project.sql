
-- 20/06/2026
-- Change Over Time
SELECT 
	YEAR( order_date)	AS order_year,
	SUM(sales_amount) AS total_sales,
	COUNT( DISTINCT customer_key) AS total_customers,
	SUM (quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR( order_date)
ORDER BY order_year


SELECT 
	MONTH( order_date)	AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT( DISTINCT customer_key) AS total_customers,
	SUM (quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY MONTH( order_date)
ORDER BY order_month

SELECT 
	YEAR( order_date)	AS order_year,
	MONTH( order_date)	AS order_month,
	SUM(sales_amount) AS total_sales,
	COUNT( DISTINCT customer_key) AS total_customers,
	SUM (quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
	YEAR( order_date),
	MONTH( order_date)
ORDER BY 
	order_year,
	order_month


SELECT 
	DATETRUNC( MONTH, order_date) AS order_dis_month,
	SUM(sales_amount) AS total_sales,
	COUNT( DISTINCT customer_key) AS total_customers,
	SUM (quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
	DATETRUNC( MONTH, order_date)
ORDER BY 
	order_dis_month


SELECT order_date
FROM gold.fact_sales


SELECT 
	FORMAT(order_date, 'yyyy-MMM') AS order_date,
	SUM(sales_amount) AS total_sales,
	COUNT( DISTINCT customer_key) AS total_customers,
	SUM (quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
	FORMAT(order_date, 'yyyy-MMM')
ORDER BY 
	order_date

-- Cumulative Analysis
-- Calculate the total sales per month and the running total of sales over time.
-- moving average of price

SELECT
	order_date,
	total_sales,
	SUM(total_sales) OVER(ORDER BY order_date) AS running_sales,
	AVG(avg_price) OVER(ORDER BY order_date) AS moving_average_price
FROM
(
SELECT 
	DATETRUNC(YEAR, order_date) AS order_date,
	SUM(sales_amount) total_sales,
	AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(YEAR, order_date)
)t

-- 21/06/2026
-- Performance Analysis

/* Analyze the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales */

WITH yearly_product_sales AS (
	SELECT 
		YEAR(f.order_date) AS order_year,
		p.product_name,
		SUM(f.sales_amount) AS current_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p
	ON f.product_key = p.product_key
	WHERE f.order_date IS NOT NULL
	GROUP BY 
		YEAR(f.order_date),
		p.product_name
)

SELECT	
	order_year,
	product_name,
	current_sales,
	AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
	CASE
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'	
		ELSE 'Avg'
	END avg_change,
	LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS py_sales,
	current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) AS diff_py,
	CASE
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN ' Increase '
		WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_year) < 0 THEN ' Decrease '	
		ELSE 'No Change'
	END avg_change
FROM yearly_product_sales
ORDER BY product_name, order_year

-- Part to Whole Analysis
-- Which categories contribute the most to overall sales

WITH category_sales AS (
SELECT
	P.category,
	SUM(F.sales_amount) AS total_sales

FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
GROUP BY P.category)


SELECT 
	category,
	total_sales,
	SUM(total_sales) OVER() AS overall_sales,
	CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC

-- 22/06/2026
-- Data Segmentation
-- Segment product into cost ranges and count how many products fall into each segment
WITH product_segment AS (
SELECT 
	product_key,
	product_name,
	cost,
	CASE
		WHEN cost < 100 THEN ' Below 100 '
		WHEN cost BETWEEN 100 AND 500 THEN ' 100 - 500 '
		WHEN cost BETWEEN 500 AND 1000 THEN ' 500 - 1000 '
		ELSE ' Above 1000 '
	END cost_range
FROM gold.dim_products)

SELECT	
	cost_range,
	COUNT( product_key) AS total_product
FROM product_segment
GROUP BY cost_range
ORDER BY total_product DESC

-- Group customers into three segments based on their spending behavoir (VIP - Regular - New) and find the total number of customers by each group
WITH customer_spending AS(
	SELECT 
		c.customer_key,
		SUM(f.sales_amount) AS total_spending,
		MIN(f.order_date) AS first_order,
		MAX(f.order_date) AS last_order,
		DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
	FROM gold.dim_customers c
	LEFT JOIN gold.fact_sales f
	ON c.customer_key = f.customer_key
	GROUP BY c.customer_key
)

SELECT 
	customer_segment,
	COUNT(customer_key) AS total_customers
FROM (
SELECT
	customer_key,
	CASE
		WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment
FROM customer_spending)t
GROUP BY customer_segment
ORDER BY total_customers DESC

-- 22/06/2026
-- Build Customer Report

/*
================================================================================
Customer Report
================================================================================

Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
       - total orders
       - total sales
       - total quantity purchased
       - total products
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last order)
       - average order value
       - average monthly spend

================================================================================
*/
CREATE VIEW gold.report_customers AS
WITH base_query AS(
-- 1) Base Query: Retrieves core columns from tables
SELECT
	f.order_number,
	f.product_key,
	f.order_date,
	f.sales_amount,
	f.quantity,
	c.customer_key,
	c.customer_number,
	CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE f.order_date IS NOT NULL)

, customer_aggregation AS(
-- 2) Customer Aggregations: Summarizes key metrics at the customer level
SELECT 
	customer_key,
	customer_number,
	customer_name,
	age,
	COUNT(DISTINCT order_number) AS total_order,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	COUNT(DISTINCT product_key) AS total_products,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_query
Group by 
	customer_key,
	customer_number,
	customer_name,
	age)

SELECT	
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29' 
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49' 
		ELSE '50 and above'
	END AS age_group,
	CASE
		WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment,
	DATEDIFF(month, last_order_date, GETDATE()) AS recency,
	total_order,
	total_sales,
	total_quantity,
	total_products,
	lifespan,
	-- Compuate average order value
	CASE
		WHEN total_sales = 0 THEN 0
		ELSE total_sales / total_order
	END avg_order_value,
	-- Compuate average month spend
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales / lifespan
	END avg_monthly_spend
FROM customer_aggregation



SELECT 
	age_group,
	COUNT(customer_number) AS total_customers,
	SUM(total_sales) AS total_sales
FROM gold.report_customers
GROUP BY age_group

SELECT 
	customer_segment,
	COUNT(customer_number) AS total_customers,
	SUM(total_sales) AS total_sales
FROM gold.report_customers
GROUP BY customer_segment


/*
================================================================================
Product Report
================================================================================

Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue

================================================================================
*/

CREATE VIEW gold.report_products AS
WITH base_query2 AS(
-- 1) Base Query: Retrieves core columns from tables
SELECT 
	f.order_number,
	f.order_date,
	F.customer_key,
	f.sales_amount,
	f.quantity,
	P.product_key,
	p.product_name,
	P.category,
	p.subcategory,
	p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE f.order_date IS NOT NULL) -- Only consider valid sales dates

,product_aggregations AS(
-- 2) Product Aggregations: Summarizes key metrics at the product level
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
	MAX(order_date) AS last_sale_order,
	COUNT(DISTINCT order_number) AS total_order,
	COUNT (DISTINCT customer_key) AS total_customers,
	SUM(sales_amount) AS total_sales,
	SUM(quantity) AS total_quantity,
	ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)),1) AS avg_selling_price
FROM base_query2
GROUP BY 	
	product_key,
	product_name,
	category,
	subcategory,
	cost
)

-- 3) Final Query: Combien all product results into one output
SELECT 
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_sale_order,
	DATEDIFF(month, last_sale_order, GETDATE()) AS recency_in_month,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment,
	lifespan,
	total_order,
	total_sales,
	total_quantity,
	total_customers,
	avg_selling_price,
	-- Average Order Revenue (AOR)
	CASE
		WHEN total_order = 0 THEN 0
		ELSE total_sales / total_order
	END AS avg_order_revenue,

	-- Average Monthly Revenue
	CASE
		WHEN lifespan = 0 THEN 0
		ELSE total_sales / lifespan
	END AS avg_monthly_revenue

FROM product_aggregations

SELECT *
FROM gold.report_products