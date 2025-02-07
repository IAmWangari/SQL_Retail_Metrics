-- SQL Retail Sales Analysis

-- Create a database
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

-- Data Cleaning
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

-- Data Exploratory Analysis

-- How Many Sales Are There?
SELECT COUNT(total_sale) AS  total_sales
FROM retail_sales;

-- How Many Customers Are There?
SELECT COUNT (customer_id) AS customers
FROM retail_sales;

-- How Many Unique Customers Are There?
SELECT COUNT (DISTINCT customer_id) AS unique_customers
FROM retail_sales;

-- How Many Product Categories Are There?
SELECT DISTINCT category AS product_category
FROM retail_sales;

-- Answering Key Business Questions

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is 4 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year.
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales.
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)


-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05'

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is 4 in the month of Nov-2022
SELECT *
FROM retail_sales
WHERE 
	  category = 'Clothing'
	  AND
	  quantity = 4 
	  AND
	  TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- Q.3 Write a SQL query to calculate the total sales for each category.
SELECT category, 
	   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
SELECT category, 
	   ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions made by each gender in each category.
SELECT category,
	   gender, 
	   COUNT(transactions_id) AS total_transactions
FROM retail_sales
GROUP BY gender,
		 category
ORDER BY category;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
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


--year Q.8 Write a SQL query to find the top 5 customers based on the highest total sales.
SELECT customer_id, 
	   SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
SELECT category, 
	   COUNT(DISTINCT customer_id)
FROM retail_sales
GROUP BY category;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

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


-- End Of Project
	  