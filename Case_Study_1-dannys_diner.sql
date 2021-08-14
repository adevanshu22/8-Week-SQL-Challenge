/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

-- Example Query:
-- SELECT
--   	product_id,
--     product_name,
--     price
-- FROM dannys_diner.menu
-- ORDER BY price DESC
-- LIMIT 5;



-- 1. What is the total amount each customer spent at the restaurant?
SELECT s.customer_id, SUM(m.price) as total_amount_spent
FROM sales s
JOIN menu m
ON s.product_id = m.product_id
GROUP BY 1

-- 2. How many days has each customer visited the restaurant?
SELECT customer_id, COUNT(DISTINCT order_date) as num_of_days_visited FROM sales
GROUP BY customer_id

-- 3. What was the first item from the menu purchased by each customer?
SELECT 
first_order.customer_id, first_order.first_order_date
FROM
(SELECT customer_id, MIN(order_date) as first_order_date
FROM sales 
GROUP BY 1) as first_order

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT product_name, sales.product_id, COUNT(*) as total_ordered FROM 
sales 
JOIN menu
ON sales.product_id = menu.product_id
GROUP BY product_name, sales.product_id
ORDER BY total_ordered DESC
LIMIT 1

-- 5. Which item was the most popular for each customer?

SELECT t.customer_id, menu.product_name, no_orders
FROM
(SELECT customer_id, product_id, COUNT(*) as no_orders, 
RANK() OVER (
	PARTITION BY customer_id
	ORDER BY COUNT(*) DESC
) as rank
FROM sales
GROUP BY 
customer_id, product_id) as t 
JOIN menu
ON menu.product_id = t.product_id
WHERE rank = 1


-- 6. Which item was purchased first by the customer after they became a member?

SELECT sales.customer_id, menu.product_name, p.date
FROM 
(SELECT sales.customer_id, MIN(order_date) as date
FROM members
JOIN sales
ON members.customer_id = sales.customer_id
WHERE join_date < order_date
GROUP BY 
sales.customer_id
) as p 
JOIN sales
ON p.customer_id = sales.customer_id
AND p.date = sales.order_date
JOIN menu
ON sales.product_id = menu.product_id


-- 7. Which item was purchased just before the customer became a member?


SELECT p.customer_id, sales.product_id, p.order_date, menu.product_name
FROM 
(SELECT sales.customer_id, MAX(order_date) as order_date
FROM members
JOIN sales
ON members.customer_id = sales.customer_id
WHERE join_date > order_date
GROUP BY
sales.customer_id
) as p JOIN sales
ON sales.customer_id = p.customer_id
AND sales.order_date = p.order_date
JOIN menu
ON menu.product_id = sales.product_id



-- 8. What is the total items and amount spent for each member before they became a member?

SELECT sales.customer_id, COUNT(*) as total_items, SUM(price) as total_amount_spent
FROM sales
JOIN members
ON members.customer_id = sales.customer_id
JOIN menu
ON menu.product_id = sales.product_id
WHERE order_date < join_date
GROUP BY sales.customer_id



-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT customer_id, SUM(points) as total_points
FROM 
(SELECT *,
CASE
	WHEN product_name = 'sushi' THEN 20*price
	ELSE 10*price
END as points
FROM sales
JOIN menu
ON sales.product_id = menu.product_id) as p
GROUP BY
customer_id


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT customer_id, SUM(points) as total_points
FROM
(SELECT sales.customer_id, order_date, product_name, price, join_date,
CASE
	WHEN product_name = 'sushi' THEN 20*price
	ELSE 10*price
END as points
FROM sales 
JOIN menu
ON sales.product_id = menu.product_id
JOIN members
ON sales.customer_id = members.customer_id
WHERE order_date <= '2021-01-31'
AND EXTRACT(DAY FROM order_date ) - EXTRACT(DAY FROM join_date) < 7
AND EXTRACT(DAY FROM order_date ) - EXTRACT(DAY FROM join_date) >= 0) as p
GROUP BY customer_id

