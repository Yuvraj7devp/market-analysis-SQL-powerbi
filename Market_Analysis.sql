show databases
USE project_orders
SHOW tables

SELECT * FROM aisles
SELECT * FROM departments
SELECT * FROM order_products_train
SELECT count(order_id) FROM orders
SELECT * FROM products

--Describing the Database 
DESCRIBE aisles;
DESCRIBE departments
DESCRIBE order_products_train
DESCRIBE orders;
DESCRIBE products;

--- Validating Primary Keys
--1)AISLES
	SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT aisle_id) AS unique_aisles
	FROM aisles;

--2)DEPARTMENTS
	SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT department_id) AS unique_departments
	FROM departments;
    
--3)PRODUCTS
	SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT product_id) AS unique_products
	FROM products;

--4)ORDERS
	SELECT COUNT(*) AS total_rows,
       COUNT(DISTINCT order_id) AS unique_orders
	FROM orders;


--1)What are the top 10 aisles with the highest number of products?
=> 	SELECT a.aisle_id,a.aisle,
    COUNT(p.product_id) AS product_count
	FROM aisles AS a
	JOIN products AS p ON a.aisle_id = p.aisle_id
	GROUP BY a.aisle_id, a.aisle
	ORDER BY product_count DESC
	LIMIT 10;
    

--2)How many unique departments are there in the dataset?
=>	SELECT COUNT(DISTINCT department_id) AS unique_departments
	FROM departments;
    
--3) What is the distribution of products across departments?
=>	SELECT d.department_id, d.department,
    COUNT(p.product_id) AS product_count,
    ROUND(COUNT(p.product_id) * 100.0 /
        (SELECT COUNT(*) FROM products),2)
        AS product_percentage
		FROM departments AS d
		JOIN products AS p ON d.department_id = p.department_id
		GROUP BY d.department_id, d.department
		ORDER BY product_count DESC;
        
--4)What are the top 10 products with the highest reorder rates?
=>	SELECT p.product_id, p.product_name,
    ROUND(AVG(op.reordered) * 100, 2) AS reorder_rate
	FROM products p
	JOIN order_products_train op
    ON p.product_id = op.product_id 
    GROUP BY p.product_id,p.product_name
	ORDER BY reorder_rate DESC
	LIMIT 10;
	
--5)How many unique users have placed orders in the dataset?
=>	SELECT COUNT(DISTINCT user_id) AS unique_users
	FROM orders;
    
--6)What is the average number of days between orders for each user?
	SELECT user_id,
		ROUND(AVG(days_since_prior_order),2) AS avg_days_between_orders
		FROM orders
		WHERE days_since_prior_order IS NOT NULL
		GROUP BY user_id
		ORDER BY avg_days_between_orders;
        
--7)What are the peak hours of order placement during the day?
	SELECT order_hour_of_day,
		 COUNT(*) AS order_count
		 FROM orders
		 GROUP BY order_hour_of_day
		 ORDER BY order_count DESC;
         
         
--8)How does order volume vary by day of the week?
	SELECT order_dow,
    COUNT(*) AS order_count
	FROM orders
	GROUP BY order_dow
	ORDER BY order_dow;
    
--9)What are the top 10 most ordered products?
=>	SELECT p.product_id, p.product_name,
		COUNT(op.product_id) AS order_count
		FROM products AS p
		JOIN order_products_train AS op ON p.product_id = op.product_id
		GROUP BY p.product_id, p.product_name
		ORDER BY order_count DESC
		LIMIT 10;
        
--10)How many users have placed orders in each department?
=>	SELECT d.department_id, d.department,
		COUNT(DISTINCT o.user_id) AS unique_users
		FROM orders AS o
		JOIN order_products_train AS op ON o.order_id = op.order_id
		JOIN products AS p
		ON op.product_id = p.product_id
		JOIN departments AS d ON p.department_id = d.department_id
		GROUP BY d.department_id, d.department
		ORDER BY unique_users DESC;
        
--11)What is the average number of products per order?
	SELECT ROUND(AVG(product_count), 2) 
    AS avg_products_per_order
	FROM (SELECT order_id,
        COUNT(product_id) AS product_count
		FROM order_products_train
		GROUP BY order_id) AS order_summary;

--12)What are the most reordered products in each department?
=> 	SELECT d.department,p.product_id,p.product_name,
    COUNT(*) AS reorder_count
	FROM order_products_train op
	JOIN products p ON op.product_id = p.product_id
	JOIN departments d ON p.department_id = d.department_id
	WHERE op.reordered = 1
	GROUP BY d.department_id,d.department,p.product_id,p.product_name
	HAVING COUNT(*) = (
    SELECT MAX(reorder_count)
    FROM (SELECT p2.department_id,p2.product_id,
            COUNT(*) AS reorder_count
        FROM order_products_train op2
        JOIN products p2 ON op2.product_id = p2.product_id
        WHERE op2.reordered = 1
        GROUP BY p2.department_id,p2.product_id)
        AS product_reorders
		WHERE product_reorders.department_id = d.department_id)
		ORDER BY d.department;


--13)How many products have been reordered more than once?
=> 
	SELECT COUNT(*) AS products_reordered_more_than_once
	FROM ( SELECT product_id
    FROM order_products_train
    WHERE reordered = 1
    GROUP BY product_id
    HAVING COUNT(*) > 1) AS product_reorders;
    
--14)What is the average number of products added to the cart per order?
=> SELECT ROUND(AVG(product_count), 2) AS avg_products_per_order
	FROM ( SELECT order_id,
        COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id) AS order_summary;

--15)How does the number of orders vary by hour of the day?
=>
	SELECT order_hour_of_day,
    COUNT(*) AS order_count
		FROM orders
		GROUP BY order_hour_of_day
		ORDER BY order_hour_of_day;
        
--16)What is the distribution of order sizes (number of products per order)?
=>	SELECT product_count AS products_per_order,
    COUNT(*) AS number_of_orders
	FROM ( SELECT order_id,
        COUNT(product_id) AS product_count
    FROM order_products_train
    GROUP BY order_id ) AS order_sizes
	GROUP BY product_count
	ORDER BY product_count;
    
--17)What is the average reorder rate for products in each aisle?
=> 		SELECT a.aisle_id,a.aisle,
		ROUND(AVG(op.reordered) * 100, 2) AS avg_reorder_rate
		FROM order_products_train op
		JOIN products p ON op.product_id = p.product_id
		JOIN aisles a ON p.aisle_id = a.aisle_id
		GROUP BY a.aisle_id,a.aisle
		ORDER BY avg_reorder_rate DESC;
        
--18)How does the average order size vary by day of the week?
=>		SELECT o.order_dow,
		ROUND(AVG(order_size), 2) AS avg_order_size
		FROM orders o
		JOIN (SELECT order_id,
        COUNT(product_id) AS order_size
		FROM order_products_train
		GROUP BY order_id) os
		ON o.order_id = os.order_id
		GROUP BY o.order_dow
		ORDER BY o.order_dow;
	
--19)What are the top 10 users with the highest number of orders?
	SELECT user_id,
    COUNT(order_id) AS order_count
	FROM orders
	GROUP BY user_id
	ORDER BY order_count DESC
	LIMIT 10;
    
--20)How many products belong to each aisle and department?
=>  SELECT d.department,a.aisle,
    COUNT(p.product_id) AS product_count
	FROM products AS p
	JOIN aisles AS a ON p.aisle_id = a.aisle_id
	JOIN departments AS d ON p.department_id = d.department_id
	GROUP BY d.department_id,d.department,a.aisle_id,a.aisle
	ORDER BY d.department,product_count DESC;
        
