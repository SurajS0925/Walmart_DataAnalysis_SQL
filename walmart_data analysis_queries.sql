create database if not exists salesDataWalmart;

create table if not exists sales(
	invoice_id varchar(30),
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(10) not null,
    product_line varchar(100) not null,
    unit_price decimal(10,2) not null,
    quantity int not null,
    VAT float(6,4) not null,
    total decimal(12,4) not null,
    date datetime not null,
    time time not null,
    payment_method varchar(15) not null,
    cogs decimal(10,2) not null,
    gross_margin_pct float(11,9),
    gross_income decimal(12,4) not null,
    rating float(2,1)
);

select * from salesdatawalmart.sales;

-- ************************************************************************
-- *******************FEATURE ENGINEERING****************************

-- time_of_day

select
	time,
    (
    case 
    when time between "00:00:00" and "12:00:00" then "Morning"
	when time between "12:01:00" and "16:00:00" then "Afternoon"
    else "Evening"
    end
    ) as time_of_date
from sales;

alter table sales add column time_of_day varchar(20);

select * from salesdatawalmart.sales;

update sales
set time_of_day = (
case 
    when time between "00:00:00" and "12:00:00" then "Morning"
	when time between "12:01:00" and "16:00:00" then "Afternoon"
    else "Evening"
    end
    );
    
select * from salesdatawalmart.sales;

-- day_name
select
	date,
    DAYNAME(date) as day_name
from sales;


ALTER TABLE sales add column day_name varchar(10);

update sales
set day_name = dayname(date);

-- month_name

select
	date,
    monthname(date)
from sales;

alter table sales add column month_name varchar(10);

update sales
set month_name = monthname(date);

select * from salesdatawalmart.sales;


-- ######################### Generic ##############################

-- How many unique cities does the data have?

select
	distinct city
    from sales;
    
select
	distinct branch
    from sales;

select
	distinct city,
    branch
from sales;


-- @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
-- @@@@@@@@@@@@@@@@@@ Product @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2

-- how many unique product lines does the data have ?
select
	distinct product_line
    from sales;
    
    
-- what is the most common payment method ?
select
payment_method,
Count(payment_method) as count
from sales
group by payment_method
order by count;


-- what is the most selling product line

select * from sales;

select
product_line,
count(product_line)
from sales
group by product_line;


-- what is the total revenue by month

select * from sales;

select
month_name,
sum(total)
from sales
group by month_name;


-- which month has the largest COGS?
select
month_name,
sum(cogs) as cogs
from sales
group by month_name
order by cogs;

-- what product line had the largest revenue ?
select
product_line,
sum(total) as total_revenue
from sales
group by product_line
order by total_revenue;


-- what is the city with the largest revenue ? 
select
branch,
city,
sum(total) as total_revenue
from sales
group by city,branch
order by total_revenue;


-- what product line had the largest VAT ? 
select
product_line,
avg(VAT) as avg_tax
from sales
group by product_line
order by avg_tax;

-- which branch sold more products than average products sold ? 
select 
branch,
sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (select avg(quantity) from sales);

-- what is the most common product line by gender ?
select 
gender,
product_line,
count(product_line) as cnt
from sales
group by product_line,gender
order by cnt;

-- what is the average rating of each product line ?

select 
product_line,
avg(rating)
from sales
group by product_line;

-- Fetch each product line and add a column to those product 
-- line showing "Good", "Bad". Good if its greater than average sales

SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN "Good"
        ELSE "Bad"
    END AS remark
FROM sales
GROUP BY product_line;

-- --------------------------------------------------------------------
-- -------------------------- Customers -------------------------------
-- --------------------------------------------------------------------

-- How many unique customer types does the data have?
SELECT
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT
	DISTINCT payment
FROM sales;


-- What is the most common customer type?
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM sales
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;
-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings
-- why is that the case, how many sales are made on these days?



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;


-- --------------------------------------------------------------------
-- --------------------------------------------------------------------

-- --------------------------------------------------------------------
-- ---------------------------- Sales ---------------------------------
-- --------------------------------------------------------------------

-- Number of sales made in each time of the day per weekday 
SELECT
	time_of_day,
	COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day 
ORDER BY total_sales DESC;
-- Evenings experience most sales, the stores are 
-- filled during the evening hours

-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
	SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT
	city,
    ROUND(AVG(tax_pct), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT?
SELECT
	customer_type,
	AVG(tax_pct) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;

-- --------------------------------------------------------------------
-- --------------------------------------------------------------------




    
