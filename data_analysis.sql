drop table df_orders;
create table df_orders(
order_id int primary key,
order_date date,
ship_mode varchar(30),
 segment varchar(30),
 country varchar(30),
 city varchar(30),
state varchar(30),
postal_code varchar(30),
region varchar(30), 
category varchar(30),
sub_category varchar(30),
product_id  varchar(30), 
cost_price int,
list_price int,
quantity int,
discount_percent int,
discount_price decimal (7,2),
Sale_price decimal (7,2),
Profit decimal (7,2)
);
select*
from df_orders;



--Statistical analysis in Myqsl
----Find Top 10 highest revenue generating product?
select  product_id ,sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
limit 10;

---Top 5 highest selling product in each region
with cte as(
select region , product_id , sum(Sale_price) as selling
from df_orders
group by region,product_id)
select *
from (select*
,row_number() over(partition by region order by selling desc) as rn
from cte) as a
where rn<=5;
-- find month over month growth comparison for 2022 and 2023 sales
with cte as(
select year(order_date) as order_year,month(order_date) as order_month
,sum(Sale_price) as sale
 from df_orders
 group by order_year,order_month
 #--order by year(order_date),month(order_date)
 )
select order_month
, sum(case when order_year = 2022 then sale else 0 end) as sale_2022
, sum(case when order_year = 2023 then sale else 0 end)as sale_2023
from cte
group by order_month
order by order_month;
##--For each category which month had highest sales
with cte as(
select category, date_format(order_date,'%Y-%m') as order_year_month,
sum(Sale_price) as sales
from df_orders
group by category , order_year_month
order by category,order_year_month desc)
select *
from (select *,
row_number() over(partition by category order by sales desc) rn
from cte) a
where rn =1 ;
##-- Which sub category had highest growth by profit in 2023 to compare to 2022
with cte as(
select sub_category, year(order_date) as order_year
,sum(Sale_price) as sale
 from df_orders
 group by sub_category,order_year
 #order by year(order_date),month(order_date)
 )
 ,cte2 as(
select sub_category
, sum(case when order_year = 2022 then sale else 0 end) as sale_2022
, sum(case when order_year = 2023 then sale else 0 end)as sale_2023
from cte
group by sub_category)
select*
from(select*,
( sale_2023-sale_2022)*100/sale_2022 as growth_percent,
row_number() over(order by ( sale_2023-sale_2022)*100/sale_2022 desc) rn
from
cte2
order by growth_percent desc) a
where rn=1;