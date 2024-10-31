-- What is the total amount each customer spent at the restaurant?
select s.customer_id, sum(m.price)
from sales s join menu m on s.product_id = m.product_id 
group by s.customer_id

--How many days has each customer visited the restaurant?
select count(distinct order_date), customer_id 
from sales s 
group by customer_id 
order by 1 desc

--What was the first item from the menu purchased by each customer?
with cte as (
select distinct customer_id, product_name, rank () over (partition by customer_id order by s.order_date) as rnk 
from sales s join menu m on s.product_id = m.product_id )
select distinct customer_id, product_name
from cte
where rnk = 1


--What is the most purchased item on the menu and how many times was it purchased by all customers?
select count(s.product_id), m.product_name 
from sales s join menu m on s.product_id = m.product_id 
group by m.product_name 
order by 1 desc
limit 1

--Which item was the most popular for each customer?
with cte as (
select s.customer_id, count(s.order_date), m.product_name, rank () over (partition by s.customer_id order by count(s.order_date)) as rnk
from sales s join menu m on s.product_id = m.product_id 
group by m.product_name, s.customer_id 
order by 2 desc )
select * from cte where rnk = 1

--Which item was purchased first by the customer after they became a member?
with cte as (
select product_name, s.customer_id, order_date, rank() over (partition by s.customer_id order by order_date) as rnk 
from sales s join members m on s.customer_id = m.customer_id 
join menu m2 on s.product_id = m2.product_id
where s.order_date >= join_date )
select customer_id, product_name
from cte
where rnk = 1


--Which item was purchased just before the customer became a member?
with cte as (
select s.customer_id, m2.product_name, order_date, join_date, rank() over (partition by s.customer_id order by order_date) as rnk 
from sales s join members m on s.customer_id = m.customer_id 
join menu m2 on m2.product_id = s.product_id 
where order_date < join_date )
select * from cte where rnk = 1

--What is the total items and amount spent for each member before they became a member?
select s.customer_id, count(s.customer_id), sum(price)
from sales s join members m on s.customer_id = m.customer_id 
join menu m2 on s.product_id = m2.product_id 
where order_date < join_date 
group by s.customer_id 


--If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id, sum(m.price), sum(
case product_name when 'sushi' then price*2*10
else price*10
end ) as Points
from sales s join menu m on s.product_id = m.product_id 
group by s.customer_id 


--In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

