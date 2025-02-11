# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  


This project focuses on analyzing retail sales data using SQL. The objective is to demonstrate SQL skills in database setup, data exploration, data cleaning, and performing analysis to extract business insights. The project involves setting up a retail sales database, cleaning missing values, conducting exploratory data analysis (EDA), and answering key business questions.

## Objectives

- Create and set up a structured retail sales database.
- Perform data cleaning, including handling missing values.
- Conduct exploratory data analysis (EDA) using SQL.
- Generate insights through SQL queries to answer business-related questions.
- Identify trends and patterns in sales performance.

## Project Structure

### 1. Database Setup

Created a retail sales database (sql_project_p1).
Designed and implemented the retail_sales table with relevant fields such as transactions_id, sale_date, customer_id, category, quantity, price_per_unit, and total_sale.

```sql
CREATE DATABASE sql_project_p1;

-- Create retail_sales table
CREATE TABLE retail_sales(
	transactions_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,	
	customer_id INT,
	gender VARCHAR(50),	
	age	INT,
	category VARCHAR(50),	
	quantity INT,	
	price_per_unit FLOAT,
	cogs FLOAT,	
	total_sale FLOAT
);
```

### 2. Data Cleaning
- Identified and handled missing values using SQL queries.
- Used statistical methods to determine appropriate imputation techniques for missing values.
- Implemented random sampling for missing age values to preserve data distribution.
- Removed records with multiple missing values to ensure data integrity

```sql
-- Dealing With Null Values

SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
OR 
sale_date IS NULL
OR 
sale_time IS NULL
OR 
customer_id IS NULL
OR
gender IS NULL
OR 
age IS NULL
OR 
category IS NULL
OR 
quantity IS NULL
OR 
price_per_unit IS NULL
OR 
cogs IS NULL
OR 
total_sale IS NULL; 

-- Defining Age Distribution Patterns For Imputation
SELECT 
	ROUND(AVG(age),2) AS mean_age,
	PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age) AS median_age
FROM retail_sales
WHERE age IS NOT NULL;

-- Since mean ≈ median, the age distribution appears to be approximately normal
-- The difference (42 - 41.34 = 0.66) is very small, meaning the data is not significantly skewed.
-- This suggests a symmetrical distribution of ages with no extreme outliers pulling the mean too far from the median.


-- Visualisation Using A Width Bucket
SELECT 
    width_bucket(age, 18, 80, 10) AS age_group, 
	MIN(age) || '-' || MAX(age) AS age_range,
    COUNT(*) AS count
FROM retail_sales
WHERE age IS NOT NULL
GROUP BY age_group
ORDER BY age_group;

-- Imputation Using Random Sampling Other Than A Fixed Value

UPDATE retail_sales
SET age = (
	SELECT age
	FROM retail_sales
	WHERE age IS NOT NULL
	ORDER BY RANDOM()
	LIMIT 1
)
WHERE age IS NULL;

-- Verification Of Null Values
SELECT COUNT(*) 
FROM retail_sales 
WHERE age IS NULL;

SELECT age
FROM retail_sales
WHERE transactions_id IN (26, 27, 28, 29, 30,31,32,33,34,35);

-- Dealing With Other Null Values
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
OR 
sale_date IS NULL
OR 
sale_time IS NULL
OR 
customer_id IS NULL
OR
gender IS NULL
OR 
age IS NULL
OR 
category IS NULL
OR 
quantity IS NULL
OR 
price_per_unit IS NULL
OR 
cogs IS NULL
OR 
total_sale IS NULL; 

-- Delete The Null Values Since There Are Only Three Null Records

DELETE FROM retail_sales
WHERE transactions_id IS NULL
OR 
sale_date IS NULL
OR 
sale_time IS NULL
OR 
customer_id IS NULL
OR
gender IS NULL
OR 
age IS NULL
OR 
category IS NULL
OR 
quantity IS NULL
OR 
price_per_unit IS NULL
OR 
cogs IS NULL
OR 
total_sale IS NULL;

```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL query to retrieve all columns for sales made on '2022-11-05**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022**:
```sql
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
    AND
    quantity = 4
```

3. **Write a SQL query to calculate the total sales (total_sale) for each category**:
```sql
SELECT category, 
	   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;
```

4. **Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category**:
```sql
SELECT category, 
	   ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;
```

5. **Write a SQL query to find all transactions where the total_sale is greater than 1000**:
```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

6. **Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category**:
```sql
SELECT category,
	   gender, 
	   COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY gender,
		 category
ORDER BY category;
```

7. **Write a SQL query to calculate the average sale for each month. Find out best selling month in each year**:
```sql
SELECT year,
	   month,
	   avg_sales
FROM 
(
	   SELECT EXTRACT(YEAR FROM sale_date)AS year,
	   EXTRACT(MONTH FROM sale_date) AS month,
       AVG(total_sale) AS avg_sales,
	   RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
	FROM retail_sales
	GROUP BY year,
 		   	 ) AS cte_1
WHERE rank = 1;

```

8. **Write a SQL query to find the top 5 customers based on the highest total sales **:
```sql
SELECT customer_id, 
	   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

9. **Write a SQL query to find the number of unique customers who purchased items from each category**:
```sql
SELECT category, 
	   COUNT(DISTINCT customer_id)
FROM retail_sales
GROUP BY category;

```

10. **Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17)**:
```sql
WITH hourly_sales
AS
(
SELECT *, 
		CASE
			WHEN EXTRACT(HOUR FROM sale_time)< 12 THEN 'Morning'
			WHEN EXTRACT(HOUR FROM sale_time)BETWEEN 12 AND 17 THEN 'Afternoon'
			ELSE 'Evening'
		END AS shift
FROM retail_sales
)
SELECT
	shift,
	COUNT(transactions_id) AS total_orders
FROM hourly_sales
GROUP BY shift;

```

## Findings

- **Product Demographics**
Identified best-performing categories by total revenue and transaction volume.
- **Customer Demographics**
Analyzed revenue contribution by age group and gender.
- **High-Value Transactions**
Identified high-value transactions exceeding 1000.
- **Who are the top 5 customers based on total purchases?**
Ranked customers by their overall spending to identify premium shoppers.
- **Seasonality**
Determined seasonality patterns to optimize inventory and marketing strategies.
- **Sales Distribution **
Analyzed gender-wise purchasing behavior across different product categories.

## Key SQL Queries Used 

- Retrieving sales data for specific time periods.
- Filtering transactions based on product categories and quantity sold.
- Calculating total and average sales per category.
- Identifying the best-performing sales month in each year.
- Ranking top customers based on total sales volume.
- Categorizing sales shifts into Morning, Afternoon, and Evening based on transaction time.
- 
## Conclusion

- Sales trends indicate seasonal variations, with peak sales in certain months.
- Product categories such as 'Clothing' and 'Beauty' exhibit strong customer demand.
- Customer segmentation by age and gender provides insights for targeted promotions.
- High-value customers present an opportunity for loyalty programs and personalized offers.
- Time-based sales segmentation assists in optimizing staffing and inventory management.

## Technologies Used
- PostgreSQL (or any SQL-based database system)
- SQL for data querying and analysis
- Statistical techniques for data cleaning and imputation
  
## How to Run the Project
- Set up a PostgreSQL (or relevant SQL database system) environment.
- Create the sql_project_p1 database.
- Run the CREATE TABLE statement to set up the retail_sales table.
- Insert the dataset into the database.
- Execute the SQL queries to explore, clean and analyze the data.

## Future Enhancements
- Develop interactive visualization dashboards using Python (Matplotlib, Seaborn) or Power BI.
- Automate data cleaning and transformation using stored procedures.
- Integrate additional features like customer preferences and location-based sales data.
- Implement predictive analytics for sales forecasting.

- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/wangari-j-maina)


