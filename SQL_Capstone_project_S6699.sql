create database amazon;

use amazon;


CREATE TABLE `amazon`.`amazon` (
  `invoice_id` VARCHAR(30) NOT NULL,
  `branch` VARCHAR(5) NOT NULL,
  `city` VARCHAR(30) NOT NULL,
  `customer_type` VARCHAR(30) NOT NULL,
  `gender` VARCHAR(10) NOT NULL,
  `product_line` VARCHAR(100) NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  `quantity` INT NOT NULL,
  `VAT` FLOAT NOT NULL,
  `total` DECIMAL(10,2) NOT NULL,
  `date` DATE NOT NULL,
  `time` TIME NOT NULL,
  `payment_method` TEXT NOT NULL,
  `cogs` DECIMAL(10,2) NOT NULL,
  `gross_margin_percentage` FLOAT NOT NULL,
  `gross_income` DECIMAL(10,2) NOT NULL,
  `rating` FLOAT NOT NULL);



##  1. Product Analysis
# Total there are 6 different product lines , in that  
# The count of Fashion accessories are more compare to others 
# Electronic accessories quantity of sales are more compared to other
# Food and beverages are generating more revenue so Food and beverages are Best-Performing Product Line
# Health and beauty is getting low revenue and sales need to improve in all areas

## 2. Sales Analysis
# Best-Performing Product Line is Food and beverages
# Afternoon time, sales are more compare to different time in a day
# There are 3 diffent types of payment methods
# In Food and beverages gross income is more
# By female customers income is more
# Health and beauty products need to improve by quantity and quality

## 3. Customer Analysis
# When compare to male customers, female customers are dominating in all segments like purchasing products , generating revnue.



select * from amazon;
select count(*) from amazon;
-- Adding a new column named timeofday to give insight of sales in the Morning, Afternoon and Evening.  
alter table amazon add column time_of_day varchar(30);
update amazon
set time_of_day = 
    case 
        when CAST(SUBSTRING(time, 1, 2) as time) >= 6 and CAST(SUBSTRING(time, 1, 2) as time) < 12 then 'Morning'
        when CAST(SUBSTRING(time, 1, 2) as time) >= 12 and CAST(SUBSTRING(time, 1, 2) as time) < 18 then 'Afternoon'
        else 'Evening'
    end;

-- Adding a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri)
alter table amazon add column day_name varchar(30);
update amazon
set day_name = 
    case 
        when DAYOFWEEK(date) = 1 then 'Sun'
        when DAYOFWEEK(date) = 2 then 'Mon'
        when DAYOFWEEK(date) = 3 then 'Tue'
        when DAYOFWEEK(date) = 4 then 'Wed'
        when DAYOFWEEK(date) = 5 then 'Thu'
        when DAYOFWEEK(date) = 6 then 'Fri'
        when DAYOFWEEK(date) = 7 then 'Sat'
    end;

select date,day_name from amazon;

-- Adding a new column named monthname that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). 
alter table amazon add column month_name varchar(15);
update amazon
set month_name = 
    case 
        when month(date) = 1 then 'Jan'
        when month(date) = 2 then 'Feb'
        when month(date) = 3 then 'Mar'
        when month(date) = 4 then 'Apr'
        when month(date) = 5 then 'May'
        when month(date) = 6 then 'Jun'
        when month(date) = 7 then 'Jul'
        when month(date) = 8 then 'Aug'
        when month(date) = 9 then 'Sep'
        when month(date) = 10 then 'Oct'
        when month(date) = 11 then 'Nov'
        when month(date) = 12 then 'Dec'
    end;

select date,month_name from amazon;




# 1. What is the count of distinct cities in the dataset?

select count(distinct city) as count_of_cities from amazon;
select city, count(city) as count_of_cities from amazon
group by city;


# 2. For each branch, what is the corresponding city?

select branch,city from amazon 
group by branch,city 
order by branch;



# 3. What is the count of distinct product lines in the dataset?

select count(distinct product_line) from amazon;
select Product_line, count(Product_line) as count_of_distinct_product_lines from amazon 
group by Product_line;



# 4. Which payment method occurs most frequently?`Invoice ID`
select payment_method, count(payment_method) as no_of_times from amazon 
group by payment_method 
order by no_of_times 
desc limit 1 ;



# 5. Which product line has the highest sales?
select product_line, sum(quantity)as sales from amazon   -- quantity wise highest sales
group by product_line 
order by sales 
desc limit 1;   



# 6. How much revenue is generated each month?
select month(date)as month, month_name , sum(total) as revenue from amazon 
group by month, month_name 
order by month ;



# 7. In which month did the cost of goods sold reach its peak?
select month_name, sum(cogs) as cost_of_goods from amazon 
group by month_name 
order by cost_of_goods 
desc limit 1;



# 8. Which product line generated the highest revenue?
select product_line, sum(total) as revenue from amazon 
group by product_line 
order by revenue 
desc limit 1;



# 9. In which city was the highest revenue recorded?
select city , sum(total) as revenue from amazon 
group by city 
order by revenue 
desc limit 1;



# 10. Which product line incurred the highest Value Added Tax?
select product_line , sum(vat)as total_vat from amazon 
group by product_line 
order by total_vat 
desc limit 1;




# 11. For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."

with cte1 as (
select product_line, sum(total)as sales from amazon 
group by product_line
) 
select product_line, sales, 
case 
	when sales > (select avg(sales) from cte1) then 'good'
    else 'bad'
    end as sales_performance 
from cte1;





# 12. Identify the branch that exceeded the average number of products sold.

select branch, avg(quantity) as total_sold from amazon 
group by branch 
having total_sold > (select avg(quantity) from amazon);


# 13. Which product line is most frequently associated with each gender?

-- select product_line, gender, count(gender) as count_of_gender from amazon group by product_line, gender order by gender,count_of_gender desc ;
with cte1 as (
with cte2 as (
	select product_line, gender, count(gender) as count_of_gender from amazon 
    group by product_line, gender 
    order by product_line,count_of_gender desc
) 
select row_number() over (partition by gender order by count_of_gender desc)as sno ,product_line, gender, count_of_gender from cte2
) 
select gender, product_line from cte1 where sno=1;



# 14. Calculate the average rating for each product line.
select product_line, avg(rating) as avg_rating from amazon
group by product_line;



# 15. Count the sales occurrences for each time of day on every weekday.
select day_name, time_of_day, count(*)as sales_occurrences from amazon 
group by day_name, time_of_day 
order by day_name,time_of_day;



# 16. Identify the customer type contributing the highest revenue.
select Customer_type, sum(total)as revenue from amazon 
group by Customer_type 
order by revenue 
desc limit 1;



# 17. Determine the city with the highest VAT percentage.
select city, sum(vat)as total_vat from amazon 
group by city 
order by total_vat 
desc limit 1;



# 18. Identify the customer type with the highest VAT payments.
select Customer_type, sum(vat)as total_vat from amazon 
group by Customer_type 
order by total_vat 
desc limit 1;



# 19. What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as customer_types from amazon;
select Customer_type, count(*)as count from amazon 
group by Customer_type;



# 20. What is the count of distinct payment methods in the dataset?
select count(distinct Payment_method) as Payment_methods from amazon;
select Payment_method, count(*)as count from amazon 
group by Payment_method;



# 21. Which customer type occurs most frequently?
select Customer_type, count(*)as no_of_occurs from amazon 
group by Customer_type 
order by no_of_occurs 
desc limit 1;



# 22. Identify the customer type with the highest purchase frequency.
select Customer_type, count(*)as purchase_frequency from amazon 
group by Customer_type 
order by purchase_frequency 
desc limit 1;



# 23. Determine the predominant gender among customers.
select gender, count(*) as no_of_customers from amazon 
group by gender 
order by no_of_customers 
desc limit 1;



# 24. Examine the distribution of genders within each branch.
select branch, gender, count(*) as count , sum(total)as total_revenue from amazon 
group by gender, branch 
order by branch;



# 25. Identify the time of day when customers provide the most ratings.
select time_of_day, count(rating) as ratings_count from amazon 
group by time_of_day 
order by ratings_count 
desc limit 1;



# 26. Determine the time of day with the highest customer ratings for each branch.
-- select time_of_day, branch, count(rating) as total_ratings from amazon 
-- group by time_of_day, Branch 
-- order by branch,total_ratings desc;
with cte1 as (
with cte2 as (
	select time_of_day, branch, count(rating) as total_ratings from amazon 
    group by time_of_day, Branch 
    order by branch,total_ratings desc
)
select row_number() over (partition by branch order by total_ratings desc )as sno , time_of_day, branch, total_ratings from cte2
)
select branch,time_of_day,total_ratings from cte1 where sno=1;




# 27. Identify the day of the week with the highest average ratings.
select day_name, avg(rating)as avg_ratings from amazon 
group by day_name 
order by avg_ratings 
desc limit 1;



# 28. Determine the day of the week with the highest average ratings for each branch.


with final as (
with day_of_week as
(
	select day_name, branch, avg(rating)as avg_ratings from amazon 
    group by day_name, branch 
    order by branch, avg_ratings desc
)
select row_number() over (partition by branch order by avg_ratings desc )as sno , day_name, branch, avg_ratings from day_of_week  
)
select  branch, day_name, avg_ratings from final where sno = 1;








