CREATE DATABASE IDC_Pizza;
USE IDC_Pizza;

-- creating the tables for the CSV files..

CREATE TABLE pizzas (
    pizza_id VARCHAR(30) PRIMARY KEY,
    pizza_type_id VARCHAR(30),
    size VARCHAR(5),
    price DECIMAL(10,2)
);

CREATE TABLE pizza_types (
    pizza_type_id VARCHAR(30) PRIMARY KEY,
    name VARCHAR(100),
    category VARCHAR(50),
    ingredients TEXT
);


CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    date DATE,
    time TIME
);


CREATE TABLE order_details (
    order_details_id INT PRIMARY KEY,
    order_id INT,
    pizza_id VARCHAR(30),
    quantity INT
);



--  Verify Data Loaded Correctly

SELECT COUNT(*) FROM pizzas;
SELECT COUNT(*) FROM pizza_types;
SELECT COUNT(*) FROM orders;

### PHASE 1: FOUNDATION AND INSPECTION

-- Q1. Install IDC_Pizza.dump as IDC_Pizza server
-- I had already completed this, So DONE..

-- Q2. List all unique pizza categories (DISTINCT).
		SELECT DISTINCT category FROM pizza_types;
        
-- Q3. Display pizza_type_id, name, and ingredients, replacing NULL ingredients with "Missing Data". Show first 5 rows.
		SELECT pizza_type_id,name,COALESCE(ingredients, 'Missing Data') AS ingredients FROM pizza_types LIMIT 5;

-- Q4. Check for pizzas missing a price (IS NULL).
SELECT * FROM pizzas WHERE price IS NULL;


### PHASE 2 — FILTERING & EXPLORATION
-- Q1. Orders placed on '2015-01-01' (SELECT + WHERE).
SELECT * FROM orders WHERE date = '2015-01-01';

-- Q2. List pizzas with price descending.
SELECT * FROM pizzas ORDER BY price DESC;

-- Q3. Pizzas sold in sizes 'L' or 'XL'.
SELECT * FROM pizzas WHERE size IN ('L', 'XL');

-- Q4. Pizzas priced between $15.00 and $17.00.
SELECT * FROM pizzas WHERE price BETWEEN 15.00 AND 17.00;

-- Q5. Pizzas with "Chicken" in the name.
--    We need to search inside pizza type name, so we join:
SELECT p.* FROM pizzas p
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id WHERE pt.name LIKE '%Chicken%';

-- Q6. Orders on '2015-02-15' or placed after 8 PM.
SELECT * FROM orders WHERE date = '2015-02-15' OR time > '20:00:00';


### Phase 3: SALES PERFORMANCE

-- Q1. Total quantity of pizzas sold (`SUM`).
			SELECT SUM(quantity) AS total_pizzas_sold FROM order_details;

-- Q2. Average pizza price (`AVG`).
			SELECT AVG(price) AS average_pizza_price FROM pizzas;

-- Q3. Total order value per order (`JOIN`, `SUM`, `GROUP BY`).
-- (order value = SUM(quantity × price))
SELECT od.order_id,
    SUM(od.quantity * p.price) AS order_value
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
GROUP BY od.order_id
ORDER BY order_value DESC;

-- Q4. Total quantity sold per pizza category (`JOIN`, `GROUP BY`).
-- Here we need to join: order_details → pizzas → pizza_types
SELECT pt.category,
    SUM(od.quantity) AS total_sold
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_sold DESC;

-- Q5. Categories with more than 5,000 pizzas sold (`HAVING`).
-- Here we are just adding 'HAVING'.
SELECT pt.category,
    SUM(od.quantity) AS total_sold
FROM order_details od
JOIN pizzas p 
    ON od.pizza_id = p.pizza_id
JOIN pizza_types pt 
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
HAVING SUM(od.quantity) > 5000
ORDER BY total_sold DESC;

-- Q6. Pizzas never ordered (`LEFT/RIGHT JOIN`).
-- (LEFT JOIN + NULL check)
SELECT p.pizza_id, p.pizza_type_id, p.size, p.price
FROM pizzas p
LEFT JOIN order_details od 
    ON p.pizza_id = od.pizza_id
WHERE od.pizza_id IS NULL;

-- Q7. Price differences between different sizes of the same pizza (`SELF JOIN`).
-- (Self join on pizza_type_id)

SELECT p1.pizza_type_id,p1.size AS size_1,p1.price AS price_1,p2.size AS size_2,p2.price AS price_2,
    (p2.price - p1.price) AS price_difference
FROM pizzas p1
JOIN pizzas p2
    ON p1.pizza_type_id = p2.pizza_type_id
    AND p1.size < p2.size   -- It ensures no duplicate reverse pairs
ORDER BY p1.pizza_type_id, size_1;