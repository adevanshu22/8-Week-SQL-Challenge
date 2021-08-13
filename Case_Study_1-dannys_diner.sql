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


SELECT customer_id, order_date, product_name
FROM dannys_diner.sales
LEFT JOIN dannys_diner.menu ON sales.product_id = menu.product_id
GROUP BY customer_id
ORDER BY order_date


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





