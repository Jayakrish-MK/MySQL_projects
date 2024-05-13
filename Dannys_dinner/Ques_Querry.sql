/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

select s.customer_id ,sum(price) as Total_Amount from menu m join sales s on m.product_id = s.product_id group by s.customer_id;

-- 2. How many days has each customer visited the restaurant?

select customer_id,count(distinct order_date) as No_of_days from sales group by customer_id ;

-- 3. What was the first item from the menu purchased by each customer?

with cte as
(select s.customer_id, m.product_name,rank() over(partition by customer_id order by order_date) as ranking from sales s join menu m on s.product_id = m.product_id )select customer_id,product_name from cte where ranking = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
 
select product_name,count(*) as Purchase_count from sales s join menu m on s.product_id =m.product_id group by product_name;

-- 5. Which item was the most popular for each customer?

with final as
(with cte as
(select customer_id,product_name,count(*) as total from sales s join menu m on s.product_id=m.product_id group by m.product_name,s.customer_id)
select customer_id,product_name,rank() over(partition by customer_id order by total desc) as Most_popular from cte)
select customer_id,product_name,Most_popular from final where Most_popular = 1;

-- 6. Which item was purchased first by the customer after they became a member?
with cte as
(select s.customer_id,s.order_date,s.product_id,m.join_date,rank() over(partition by s.customer_id order by order_date) as ranking,me.product_name from sales s left join members m on s.customer_id = m. customer_id join menu me on s.product_id = me.product_id where s.order_date >= m.join_date)select customer_id,product_id,product_name,order_date,join_date from cte where ranking = 1;

-- 7. Which item was purchased just before the customer became a member?

with cte as
(select s.customer_id,s.order_date,s.product_id,m.join_date,rank() over(partition by s.customer_id order by order_date) as ranking,me.product_name from sales s left join members m on s.customer_id = m. customer_id join menu me on s.product_id = me.product_id where s.order_date < m.join_date)select customer_id,product_id,product_name,order_date,join_date from cte where ranking <=2 ;

-- 8. What is the total items and amount spent for each member before they became a member?

with cte as 
(select s.customer_id,s.order_date,me.join_date,m.price,m.product_name from sales s left join members me on s.customer_id = me.customer_id join menu m on s.product_id = m.product_id where s.order_date < me.join_date) select customer_id,sum(price) as Tot_Amount,count(distinct product_name) as Prod_Name from cte group by customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

with cte as 
(select s.customer_id,s.order_date,m.price,m.product_name,
case when product_name = 'sushi' then 2*m.price
else m.price end as new_price from sales s join menu m on s.product_id = m.product_id)
select customer_id,sum(new_price)*10 as points from cte group by customer_id;

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

with finalpoints as (
select s.customer_id,s.order_date,m.product_name,m.price,
case when product_name='sushi' then 2*m.price
when s.order_date between me.join_date 
and (me.join_date+ interval 6 day) then 2*m.price
else m.price end as newprice
 from sales s
 join menu m
 on s.product_id=m.product_id
  join members me
 on s.customer_id=me.customer_id
 where s.order_date<='2021-01-31'
)
select customer_id,sum(newprice)*10 from finalpoints
group by customer_id
 