--Basic:

-----------Retrieve the total number of orders placed-------------------------
select COUNT(order_id) as total_orders from orders


---------Calculate the total revenue generated from pizza sales-------------------------
select   round(sum(order_details.quantity*pizzas.price),2) as total_revinue
from order_details
join pizzas 
on order_details.pizza_id = pizzas.pizza_id
;  


-----------Identify the highest-priced pizza.------------------
select top 1 name,price  
from pizza_types 
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc;


select top 1 name,max(price) as max_price 
from pizza_types 
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by name
order by max_price desc;


-----------Identify the most common pizza size ordered------------------
select top 1 size, COUNT(size) as most_ordered
from pizzas  
join order_details
on pizzas.pizza_id = order_details.pizza_id
group by size
order by most_ordered desc;


-----------List the top 5 most ordered pizza types along with their quantities.---------
select top 2 * 
from order_details
order by order_details_id asc;
select top 2 *
from orders;
select top 2 *
from pizza_types;
select top 2 *
from pizzas;

select top 5 pizza_id, sum(quantity) as total_quantity
from order_details
group by pizza_id
order by total_quantity desc

 
select top 5 pizza_types.name, sum(order_details.quantity) as total_pizza
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by total_pizza desc



--Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category , sum(order_details.quantity) as total_quantity 
from pizza_types 
join pizzas on 
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on 
pizzas.pizza_id = order_details.pizza_id
group by pizza_types.category 
order by total_quantity desc 


--Determine the distribution of orders by hour of the day.
 select datepart(hour,time) as hour_of_the_day, count(order_id) as total_orders
 from orders
 group by datepart(hour,time)
 order by total_orders desc


--Join relevant tables to find the category-wise distribution	of pizzas.
SELECT category , count(pizza_type_id) as total 
from pizza_types 
group by category
order by total desc



--Group the orders by date and 
--calculate the average number of pizzas ordered per day.
select orders.date, sum(quantity) as average 
from order_details 
join orders 
on order_details.pizza_id = orders.order_id
group by orders.date
order by average desc



--Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name , SUM(order_details.quantity*pizzas.price) as total
from pizza_types join 
pizzas on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id= order_details.pizza_id
group by pizza_types.name
order by total desc


--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category, round((sum(order_details.quantity * pizzas.price)/(select  sum(order_details.quantity* pizzas.price) from order_details join pizzas on order_details.pizza_id= pizzas.pizza_id)*100),2) as percentage_
from pizza_types
join pizzas 
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details 
on pizzas.pizza_id= order_details.pizza_id
group by pizza_types.category
order by percentage_ desc



--Analyze the cumulative revenue generated over time.
select sales.date, round(SUM(sales.rev) over(order by sales.date ),0) as cummulative_revenue
from
(select orders.date , sum(order_details.quantity * pizzas.price ) as rev
from orders 
join order_details 
on orders.order_id= order_details.order_id
join pizzas 
on order_details.pizza_id= pizzas.pizza_id
group by orders.date) as sales
order by cummulative_revenue desc


--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select * from
(select category, name, rev, RANK()over (partition by category order by rev desc) as numbering
from 
(select pizza_types.category, pizza_types.name, round(sum(order_details.quantity*pizzas.price),0) as rev
from pizza_types join pizzas on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details on pizzas.pizza_id=order_details.pizza_id
group by pizza_types.category,pizza_types.name)as a)  as b 
where numbering<=3;


--------------------------------------------------------------------------------------------------------------------------------

--Q1: retreve the total number of order placed
select COUNT(distinct order_id) as total_order
from order_details



-- Q2 Calcualte the total revenue generated from pizza sales
select round(SUM(quantity*price),2) as total_revenue
from order_details join pizzas 
on order_details.pizza_id= pizzas.pizza_id


--Q3: Identify the highest priced pizza 
--using top/limit function 
select top 1 name, MAX(price) as Price 
from pizza_types
join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by name
order by Price desc

-- use window function (without using the top function)
with cte as (
select name, price,
RANK() over (order by price desc) as ranking

from pizza_types
join pizzas on pizzas.pizza_type_id=pizza_types.pizza_type_id
)
select name, price 
from cte
where ranking =1;

-- Q4: identify the most common pizza size ordered 
select size, sum(quantity) as total 
from order_details join pizzas
on order_details.pizza_id= pizzas.pizza_id
group by size
order by total desc

--Q5 list the top 5 most ordered pizza types along with their quantities
select top 5 pizza_types.name, sum(order_details.quantity) as total_pizza
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by total_pizza desc


--Q6: join the necessory tables to find the total quantity of each pizza catagory ordered
select pizza_types.category, sum(order_details.quantity) as total_pizza
from pizza_types 
join pizzas 
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category
order by total_pizza desc

 
 --Q7: determine the distribution of orders by hour of the day 
 select datepart(hour,time) as hour_of_the_day, count(order_id) as total_orders
 from orders
 group by datepart(hour,time)
 order by total_orders desc

 --Q8 find the catagory wise distribution of pizzas
select pizza_types.category, SUM(order_details.quantity) as total_pizzas
from pizza_types join pizzas
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details on order_details.pizza_id= pizzas.pizza_id
group by pizza_types.category
order by total_pizzas desc

--Q9: calculate the average number of pizzas ordered per day 
with cte as( select date,sum(quantity) as total
from order_details join orders
on order_details.order_id=orders.order_id
group by date

)
select round((AVG(total)),0) as avg_pizzas
from cte


--Q10: determine the top 3 most ordered pizzas based on the revenue 
select top 3 name, round(sum(quantity*price),0) as total_sales
from pizza_types join pizzas 
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details on 
order_details.pizza_id= pizzas.pizza_id
group by name
order by total_sales desc

--do using window function (without top/limit)
with cte as(
select name, round(sum(quantity*price),0) as total_sales
from pizza_types join pizzas 
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details on 
order_details.pizza_id= pizzas.pizza_id
group by name
)
select name, total_sales, RANK() over(order by total_sales desc) as final_sales 
from cte;


-- Advance
--Q11: calculate the percentage contribution of each pizza type to toal revenue
select category, (concat(round(sum(quantity*price)/
--subquery to get the total revenue
(select SUM(order_details.quantity*pizzas.price) from order_details join pizzas on order_details.pizza_id= pizzas.pizza_id)
*100,2),'%'))
as total_sales
from pizza_types join pizzas 
on pizza_types.pizza_type_id= pizzas.pizza_type_id
join order_details on 
order_details.pizza_id= pizzas.pizza_id
group by category
order by total_sales desc;

--Q12: analyze the cummulative revenue generated  over time 
-- use aggregate window function to get the cummulative sum 
with cte as (
select date, round(SUM(quantity*price),0) as revenue
from orders join order_details on orders.order_id=order_details.order_id
join pizzas on order_details.pizza_id=pizzas.pizza_id
group by date
)
select date, revenue, round(sum(revenue)over (order by date),0) as cummulative_sum
from cte
group by date, revenue ;


--Business Problem 13
--determine the top 3 most ordered pizzas based on the revenue for each pizza category 
with cte as (
select category,name, SUM(quantity* price ) as revenue
from pizza_types join pizzas on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details on order_details.pizza_id=pizzas.pizza_id
group by category, name
)
, cte1 as (
select category, name, revenue,
RANK()over (partition by category order by revenue) as rnk
from cte
)
select category, name, round(revenue,0)as total_revnue
from cte1
where rnk<=3


