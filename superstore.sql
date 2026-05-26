create database superstore_data;

use superstore_data;

select * from superstore_table
limit 10;

create table orders as select distinct
   order_id ,
   date(order_date) as order_date,
   date(ship_date) as ship_date,
   ship_mode,
   product_id,
   customer_id,
   sales,
   quantity,
   discount,
   profit
from superstore_table; 

drop table orders;
alter table orders
add column product_id varchar(100);

create table customers as select distinct
   customer_id,
   product_id
   customer_name,
   segment,
   country,
   city,
   state,
   postal_code,
   region
from superstore_table;   

create table products as select distinct
       product_id,
       category,
       sub_category,
       product_name
from superstore_table;




--  What is the overall revenue,profit and profit margin

select sum(sales) from superstore_table as total_revenue;

select sum(profit) from superstore_table as total_profit;

select sum(sales) as total_revenue,
       sum(profit) as total_profit,
       (sum(profit)/sum(sum))*100 as profit_margin from superstore_table;
       

 -- Is this business profitable or loss making
 
 select
 sum(sales) as total_revenue,
 sum(profit) as total_profit,
 
  case
     when sum(profit) > 0 then 'Profitable'
     when sum(profit) < 0 then 'Loss Making'
     else 'break even'
	end as business_status
   from superstore_table;
   
-- which region contributes the most to revenue and profit

select region,
  sum(sales) as total_sales,
  sum(profit) as total_profit
  from superstore_table
  group by region
  order by total_sales desc
  limit 1;
  
  -- What is the average order values
  
  select 
  avg(sales) as avg_order_value from superstore_table;
   
       
   -- total number of orders and customers
   
select distinct count(order_id) as total_orders, count(customer_id) as total_customers from superstore_table;   

-- Top 10 customers contributing highest revenue

select customer_id,customer_name, sum(sales) as total_sales from superstore_table
group by customer_id,customer_name
order by total_sales desc
limit 10;

-- most profitable customers

select customer_id,customer_name, sum(profit) as total_profit from superstore_table
group by customer_id,customer_name 
order by total_profit
limit 10;

-- are there customers generating high sales but low/negative profit

select customer_id,customer_name,
   round(sum(sales),2) as total_sales,
   round(sum(profit),2) as total_profit from superstore_table
group by customer_id,customer_name
having total_sales > 10000 and total_profit <= 0
order by total_sales;  

-- How many repeat customers we have

select customer_id , customer_name, count(*) as total_orders from superstore_table
group by customer_id,customer_name
having count(*) > 1
order by total_orders desc;  

-- average sales per customer

select customer_id,customer_name,avg(sales) as average_sales from superstore_table
group by customer_id,customer_name
order by average_sales desc;

-- Top 5 products by sales

select product_id,product_name, sum(sales) as total_sales from superstore_table
group by product_id,product_name
order by total_sales desc
limit 5;

-- Top 5 products by profit

select product_id,product_name, sum(profit) as total_profit from superstore_table
group by product_id,product_name
order by total_profit desc
limit 5;

-- Which products making loss

select product_id,product_name, sum(profit) as total_profit from superstore_table
group by product_id,product_name
having total_profit <= 0;

-- Which subcategory is more profitable

select sub_category, sum(profit) as total_profit from superstore_table
group by sub_category 
order by total_profit desc
limit 1;

-- Which products have high sales but low  profit

select product_id,product_name,
  round(sum(sales),2) as total_sales,
  round(sum(profit),2) as total_profit from superstore_table
group by product_id,product_name
having total_sales > 10000 and total_profit <= 0
order by total_sales desc;  

-- which city has highest sales

select city, sum(sales) as total_sales from superstore_table
group by city
order by total_sales desc
limit 1;

-- which state is making loss

select state, sum(profit) as  total_profit from superstore_table
group by state
having total_profit <= 0
order by total_profit;

-- Which region has high sales but low profit

select region,
   round(sum(sales),2) as total_sales,
   round(sum(sales),2) as total_profit from superstore_table
group by region
having total_sales > 5000 and total_profit <= 0
order by total_sales;  

-- Sales distribution across rregion

select region,sum(sales) as total_sales,
sum(sales)*100/(select sum(sales) from superstore_table) as total_percentage from superstore_table
group by region
order by total_sales desc;

-- which shipmode is most used

select ship_mode, count(*) as total_count from superstore_table
group by ship_mode
order by total_count
limit 1;

-- what is average delivery duration

 select ship_mode,round(avg(delivery_duration),2) as avg_duration from superstore_table
 group by ship_mode
 order by avg_duration;
 
 -- which shipmode has fasted delivery
 
 select ship_mode,min(delivery_duration) as shortest_duration from superstore_table
 group by ship_mode
 order by shortest_duration
 limit 1;
 
 -- Does faster delivery mean higher profit
 
 select ship_mode,avg(delivery_duration) as avg_duration,sum(profit) as total_profit from superstore_table
 group by ship_mode
 order by avg_duration desc;
 
 -- which ship mode has highest profit
 
 select ship_mode,sum(profit) as total_profit from superstore_table
 group by ship_mode
 order by total_profit desc
 limit 1;
 
 -- how does discount affect profit
 
 select discount, sum(profit) as total_profit,
                  sum(sales) as total_sales,
                  count(*) as order_count from superstore_table
group by discount
order by discount;   

-- at what profit level  discount become negative

select discount,
      sum(profit) as total_profit from superstore_table
group by discount
having total_profit <= 0
order by discount;      

-- which products loss making due to discount

select product_name,product_id,discount,
       sum(profit) as total_profit from superstore_table
group by product_name,product_id,discount
having total_profit <=0
order by total_profit;   

-- do higher discounts increase sales volume

select discount,
       count(order_id) as order_volume,
       sum(sales) as total_sales from superstore_table
group by discount
order by order_volume;    

-- should company reduce discount

select discount,
        sum(sales) as total_sales,
        sum(profit) as total_profit,
        round(sum(profit)*100/sum(sales),2) as profit_margin
from superstore_table
group by discount
order by discount;        
 
-- Top performing customers by total profit and rank based profit

with customer_profit as(
select customer_id,customer_name,
          sum(profit) as total_profit from superstore_table 
group by customer_id,customer_name)
select customer_id,customer_name,total_profit,
   rank() over(order by total_profit desc) as profit_rank
   from customer_profit
   limit 5;
   
   -- customers above average sales
   
   select customer_id,customer_name from superstore_table
   where sales < (select avg(sales) from superstore_table);
   
   -- Each regions sales contribution by %
   
   with region_sales as(
        select
         region,
         sum(sales) as total_sales from superstore_table
  group by region)     
         
 select region,total_sales,
        round(total_sales*100/(select sum(total_sales) from region_sales),2) as sales_percentage
        from region_sales
        order by total_sales desc;
        
-- most profitable  product in each category

with product_profit as(
   select category,product_id,product_name,
   sum(profit)  as total_profit from superstore_table
   group by category,product_id,product_name)
   
select * from (select category,product_id,product_name,total_profit,
rank() over(partition by category order by total_profit desc) as rnk from product_profit)ranked
where rnk = 1;

-- using joins
-- top 5 most profitable products

select p.product_id,p.product_name,p.category,sum(o.sales) as total_sales,sum(o.profit) as total_profit 
from 
orders o 
join 
products p on o.product_id = p.product_id 
group by p.product_id,
         p.product_name,
         p.category
order by total_profit desc
limit 5;       







    




   
    
       

  

 
 

