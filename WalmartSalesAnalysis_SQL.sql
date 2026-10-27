CREATE DATABASE walmartsales;
USE walmartsales;


CREATE TABLE sales (
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,                                        #The amount of tax on purchase
    total_revenue DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,                                     #Cost Of Goods Sold
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
    );
    
    
SELECT * FROM sales;       #Imported data from CSV File

--------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- Feature Engineering---------------------------------------------------------------------------------------------------------------
-- Feature engineering in SQL is the process of creating new columns, transforming 
-- existing data, and extracting useful information from raw data to make it easier to analyze and use for machine learning.

-- time_of_day (Added the column time_of_the_day using case statement
SELECT 
	time,
    (CASE 
		WHEN time BETWEEN "00:00:00" AND "11:59:59" THEN "Morning"
        WHEN time BETWEEN "12:00:00" AND "15:59:59" THEN "Afternoon"
        ELSE 'Evening'
        END
    ) AS time_of_day
FROM sales;

ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20);                #Added the column to sales table using ALTER command

UPDATE sales
SET time_of_day = (
CASE 
		WHEN time BETWEEN "00:00:00" AND "11:59:59" THEN "Morning"
        WHEN time BETWEEN "12:00:00" AND "15:59:59" THEN "Afternoon"
        ELSE 'Evening'
        END
);
    
-- day_name                                          #Created day column
SELECT date,
	DAYNAME(date) AS day_name
    FROM sales;
    
ALTER TABLE sales                                    #Added column to sales table
ADD COLUMN day_name VARCHAR(15);


UPDATE sales
SET day_name = DAYNAME(date);                        -- Updated data

SELECT * FROM sales;

SELECT date,
	monthname(date) AS month_name
    FROM sales;
    
ALTER TABLE sales                                   -- Added month_name column
ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = monthname(date);                   -- Updated month_name column

SELECT * FROM sales;
    
--------------------------------------------------------------------------------------------------------------------------------------
-- BUISNESS QUESTIONS -- Exploratory Data Analysis
--------------------------------------------------------------------------------------------------------------------------------------
-- Generic Question
-- How many unique cities does the data have?
SELECT DISTINCT city FROM sales;

-- In which city is each branch?
SELECT DISTINCT city,branch FROM sales;

-- Product
-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) FROM sales;

-- What is the most common payment method?
SELECT payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY COUNT(payment_method) DESC;

-- What is the most selling product line?
SELECT product_line,
	COUNT(quantity) AS total_quantity
FROM sales
GROUP BY product_line
ORDER BY MAX(quantity) DESC;

-- What is the total revenue by month?
SELECT month_name,
	SUM(total_revenue)
FROM sales
GROUP BY month_name;

-- What month had the largest COGS?
SELECT month_name,
	SUM(cogs)
FROM sales
GROUP BY month_name;

-- What product line had the largest revenue?
SELECT product_line,
	SUM(total_revenue)
FROM sales
GROUP BY product_line
ORDER BY SUM(total_revenue) DESC;

-- What is the city with the largest revenue?
SELECT city,
	SUM(total_revenue) 
FROM sales
GROUP BY city
ORDER BY SUM(total_revenue) DESC;

-- What product line had the largest VAT?
SELECT product_line,
	AVG(VAT)
FROM sales
GROUP BY product_line
ORDER BY AVG(VAT) DESC;
	
-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

    
-- Which branch sold more products than average product sold?
SELECT branch,
	SUM(quantity) 
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity));

-- What is the most common product line by gender?
SELECT gender,
	product_line,
    COUNT(gender) AS total_count
FROM sales
GROUP BY gender,product_line
ORDER BY COUNT(gender) DESC;

-- What is the average rating of each product line?
SELECT product_line,
	ROUND(AVG(rating),2) as Average_Rating
FROM sales
GROUP BY product_line
ORDER BY AVG(rating) DESC;


-- Sales
-- Number of sales made in each time of the day per weekday
SELECT time_of_day,COUNT(*) AS time_of_day
FROM sales
WHERE day_name = 'Sunday'
GROUP BY time_of_day;

-- Which of the customer types brings the most revenue?
SELECT customer_type,ROUND(SUM(total_revenue),2) AS total_revenue	
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city,ROUND(AVG(VAT),2) as VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type,AVG(VAT) AS VAT
	FROM sales
GROUP BY customer_type;
	
-- Customer
-- How many unique customer types does the data have?
SELECT DISTINCT customer_type FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment_method FROM sales;

-- What is the most common customer type?
SELECT customer_type,COUNT(*) 
FROM sales
GROUP BY customer_type;

-- Which customer type buys the most?
SELECT customer_type,COUNT(*) 
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT gender,COUNT(*) AS gen_count FROM sales
GROUP BY gender
ORDER BY gen_count DESC;

-- What is the gender distribution per branch?
SELECT gender,COUNT(*) AS gen_count FROM sales
WHERE branch = 'C'
GROUP BY gender
ORDER BY gen_count DESC;

-- Which time of the day do customers give most ratings?
SELECT time_of_day,AVG(rating) as avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day,AVG(rating) as avg_rating
FROM sales
WHERE branch = 'A'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT day_name,AVG(rating) as avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT day_name,AVG(rating) as avg_rating
FROM sales
WHERE branch = 'C'
GROUP BY day_name
ORDER BY avg_rating DESC;
    