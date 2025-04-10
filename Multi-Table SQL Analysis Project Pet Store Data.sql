Create Database Onlinestore;
Use Onlinestore;
-- Customers Table
CREATE TABLE customers (
    customer_ID INT,
    order_city VARCHAR(100),
    order_postal VARCHAR(20),
    order_state VARCHAR(100),
    latitude DOUBLE,
    longitude DOUBLE
);

-- Products Table
CREATE TABLE products (
    stock_code VARCHAR(20),
    weight DOUBLE,
    landed_cost DECIMAL(10,2),
    shipping_cost_1000_mile DECIMAL(10,2),
    description TEXT,
    category VARCHAR(100)
);
drop table fact_sales;
-- Sales Fact Table
CREATE TABLE fact_sales (
    customer_id INT,
    description TEXT,
    stock_code VARCHAR(20),
    invoice_no VARCHAR(50),
    quantity INT,
    sales DECIMAL(10,2),
    unit_price DECIMAL(10,2)
);

Truncate Table fact_sales

-- State-Region Mapping Table
CREATE TABLE state_region_mapping (
    order_state VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(100)
);

select * from customers;
select * from products;
select * from state_region_mapping;
select * from fact_sales;


-- 1. Total sales per customer, ordered by total sales:
SELECT fs.customer_id,SUM(fs.sales) AS total_sales
FROM fact_sales fs
GROUP BY fs.customer_id
ORDER BY total_sales DESC;

-- 2. Products sold more than 100 times:
SELECT fs.stock_code, SUM(fs.quantity) AS total_quantity
FROM fact_sales fs
GROUP BY fs.stock_code
HAVING total_quantity > 100
ORDER BY total_quantity DESC;

-- 3. Sales with Product Details
SELECT fs.invoice_no, fs.stock_code, dp.description, fs.quantity, fs.sales
FROM fact_sales fs
INNER JOIN products dp ON fs.stock_code = dp.stock_code;

-- 4.All customers and their regions (even if region data is missing):
SELECT dc.customer_id, dc.order_state, srm.region
FROM customers dc
LEFT JOIN state_region_mapping srm ON dc.order_state = srm.order_state;

-- 5.All regions and customers from those regions (even if no customer exists):
SELECT srm.region, dc.customer_id, dc.order_state
FROM state_region_mapping srm
RIGHT JOIN customers dc ON srm.order_state = dc.order_state;

-- 6.Top 5 customers by sales using a subquery:
SELECT * FROM (
    SELECT customer_id, SUM(sales) AS total_sales
    FROM fact_sales
    GROUP BY customer_id
    ORDER BY total_sales DESC LIMIT 5) 
    AS top_customers;

-- 7.Find products that have higher-than-average unit price:
SELECT DISTINCT fs.stock_code, fs.unit_price
FROM fact_sales fs
WHERE fs.unit_price > (SELECT AVG(unit_price) FROM fact_sales);

-- 8.Total revenue and average order value:
SELECT SUM(sales) AS total_revenue, AVG(sales) AS average_order_value
FROM fact_sales;

-- 9.Create a view for total sales per customer with region info:
CREATE VIEW customer_sales_region AS
SELECT fs.customer_id, SUM(fs.sales) AS total_sales, srm.region
FROM fact_sales fs
JOIN customers dc ON fs.customer_id = dc.customer_id
LEFT JOIN state_region_mapping srm ON dc.order_state = srm.order_state
GROUP BY fs.customer_id, srm.region;

SELECT * FROM customer_sales_region WHERE region = 'west';

-- 10. Average quantity sold per product:
SELECT stock_code, AVG(quantity) AS avg_quantity
FROM fact_sales
GROUP BY stock_code;
