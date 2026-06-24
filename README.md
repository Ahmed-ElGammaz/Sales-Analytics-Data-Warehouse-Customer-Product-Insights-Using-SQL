# Sales-Analytics-Data-Warehouse-Customer-Product-Insights-Using-SQL
SQL Server Data Warehouse project featuring sales analytics, customer segmentation, product performance analysis, and business KPI reporting.
# Sales Analytics Data Warehouse Project

## 📊 Project Overview

This project demonstrates the design and implementation of a modern SQL-based Sales Analytics Data Warehouse. The solution transforms raw sales data into meaningful business insights through data modeling, analytical SQL queries, customer segmentation, product performance analysis, and reporting views.

The project follows a layered architecture:

* Bronze Layer: Raw data ingestion
* Silver Layer: Data cleansing and transformation
* Gold Layer: Business-ready reporting tables and views

---

## 🎯 Objectives

The main objectives of this project are:

* Build a scalable sales data warehouse.
* Analyze sales trends over time.
* Evaluate customer purchasing behavior.
* Measure product performance.
* Generate business KPIs.
* Create reusable reporting views for decision-makers.

---

## 🧱 Database Schema

### Fact Table

**fact_sales**

* order_number
* order_date
* customer_key
* product_key
* quantity
* sales_amount

### Dimension Tables

**dim_customers**

* customer_key
* customer_number
* first_name
* last_name
* birthdate

**dim_products**

* product_key
* product_name
* category
* subcategory
* cost

### Reporting Views

**report_customers**

* Customer KPIs
* Segmentation
* Lifetime value metrics

**report_products**

* Product KPIs
* Product segmentation
* Revenue performance metrics

---

## 📈 Key Business KPIs

### Customer KPIs

* Total Sales
* Total Orders
* Total Products Purchased
* Customer Lifespan
* Recency
* Average Order Value
* Average Monthly Spend

### Product KPIs

* Total Sales
* Total Orders
* Total Quantity Sold
* Total Customers
* Product Lifespan
* Recency
* Average Selling Price
* Average Order Revenue
* Average Monthly Revenue

---

## 🔍 Analysis Performed

### Time-Based Analysis

* Yearly sales trends
* Monthly sales trends
* Customer growth over time
* Quantity sold over time
* Running sales totals
* Moving average calculations

### Performance Analysis

* Product performance by year
* Comparison against average sales
* Year-over-Year growth analysis
* Previous year sales comparison using window functions

### Part-to-Whole Analysis

* Category contribution to total revenue
* Revenue percentage by category

### Customer Segmentation

Customers were classified into:

* VIP
* Regular
* New

based on spending behavior and customer lifespan.

### Product Segmentation

Products were classified into:

* High-Performer
* Mid-Range
* Low-Performer

based on generated revenue.

### Cost Segmentation

Products were grouped into cost ranges:

* Below 100
* 100–500
* 500–1000
* Above 1000

---

## 🛠️ Tools & Technologies

* SQL Server
* T-SQL
* Window Functions
* Common Table Expressions (CTEs)
* Views
* Data Warehousing Concepts
* Git
* GitHub

---

## 📁 Project Structure

```text
datasets/
scripts/
screenshots/
README.md
```

---

## 📊 Example Insights

* Identified top-performing products generating the highest revenue.
* Segmented customers based on purchasing behavior.
* Measured customer retention using recency and lifespan metrics.
* Determined category contribution to total company revenue.
* Tracked sales growth trends across multiple years.
* Calculated average monthly revenue per product.

---

## 🎓 Learning Source

This project was built as part of my continuous learning journey in:

* Data Analytics
* SQL Development
* Business Intelligence
* Data Warehousing
* Customer Analytics

---

## 📌 Notes

This project is intended for educational and portfolio purposes. The analytical logic can be extended further using Power BI, Python, ETL pipelines, and cloud-based data warehouse solutions.
