-- ============================================================
-- OLIST E-COMMERCE ANALYSIS
-- DATABASE TABLE CREATION
-- ============================================================
-- ============================================================
-- 1. CUSTOMERS
-- customer_id = primary key for customer records
-- customer_unique_id = actual customer identifier and may repeat
-- ============================================================

CREATE TABLE customers (
    customer_id VARCHAR(32) PRIMARY KEY,
    customer_unique_id VARCHAR(32),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(10)
);
-- ============================================================
-- 2. ORDERS
-- order_id = primary key
-- customer_id = foreign key referencing customers
-- ============================================================

CREATE TABLE orders (
    order_id VARCHAR(32) PRIMARY KEY,
    customer_id VARCHAR(32),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP,
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);
 
 -- ============================================================
-- 3. ORDER ITEMS
-- Each row represents one product/item within an order.
-- An order can contain multiple items.
 -- ============================================================

CREATE TABLE order_items (
    order_id VARCHAR(32),
    order_item_id INT,
    product_id VARCHAR(32),
    seller_id VARCHAR(32),
    shipping_limit_date TIMESTAMP,
    price NUMERIC(12,2),
    freight_value NUMERIC(12,2),
    PRIMARY KEY (order_id, order_item_id)
);

-- ============================================================
-- 4. PAYMENTS
-- Stores payment information associated with orders.
-- One order can have multiple payment records.
-- ============================================================

CREATE TABLE payments (
    order_id VARCHAR(32),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value NUMERIC(12,2),
    PRIMARY KEY (order_id, payment_sequential)
);

-- ============================================================
-- 5. REVIEWS
-- Stores customer reviews and ratings associated with orders.
-- ============================================================

CREATE TABLE reviews (
    review_id VARCHAR(32) PRIMARY KEY,
    order_id VARCHAR(32),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- ============================================================
-- 6. PRODUCTS
-- Stores product details such as category, dimensions and weight.
-- ============================================================

CREATE TABLE products (
    product_id VARCHAR(32) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g NUMERIC(10,2),
    product_length_cm NUMERIC(10,2),
    product_height_cm NUMERIC(10,2),
    product_width_cm NUMERIC(10,2)
);

-- ============================================================
-- 7. SELLERS
-- Stores seller location information.
-- ============================================================

CREATE TABLE sellers (
    seller_id VARCHAR(32) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(10)
);
-- ============================================================
-- 8. CATEGORY TRANSLATION
-- Maps Portuguese product categories to English names.
-- ============================================================

CREATE TABLE category_translation (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);
-------
ALTER TABLE order_items
ADD COLUMN item_total NUMERIC(12,2);
==========
ALTER TABLE products
    ALTER COLUMN product_name_lenght TYPE NUMERIC,
    ALTER COLUMN product_description_lenght TYPE NUMERIC,
    ALTER COLUMN product_photos_qty TYPE NUMERIC;



------------------------------------ CORE KPIs--------------------------------------


-- 1. Total Orders
SELECT
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;


-- 2. Total Customers
SELECT
    COUNT(DISTINCT customer_unique_id) AS total_customers
FROM customers;


-- 3. Total Revenue
SELECT
    ROUND(SUM(price + freight_value), 2) AS total_revenue
FROM order_items;


-- 4. Total Items Sold
SELECT
    COUNT(*) AS total_items_sold
FROM order_items;


-- 5. Average Order Value
SELECT
    ROUND(
        SUM(price + freight_value) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value
FROM order_items;


------------------------------------------ SALES PERFORMANCE-----------------------------------------------------


-- 1. Revenue by year
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY order_year
ORDER BY order_year;


-- 2. Order volume by year
SELECT
    EXTRACT(YEAR FROM order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY order_year
ORDER BY order_year;


-- 3. Average Order Value by year
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    ROUND(
        SUM(oi.price + oi.freight_value) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY order_year
ORDER BY order_year;


-- 4. Monthly revenue
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    EXTRACT(MONTH FROM o.order_purchase_timestamp) AS month_number,
    TRIM(TO_CHAR(o.order_purchase_timestamp, 'Month')) AS month_name,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    order_year,
    month_number,
    month_name
ORDER BY
    order_year,
    month_number;


-- 5. Revenue, orders and AOV by year
SELECT
    EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue,
    ROUND(
        SUM(oi.price + oi.freight_value) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY order_year
ORDER BY order_year;

-------------------------------------- PRODUCT & CATEGORY ANALYSIS-------------------------------------

-- 1. Categories generating highest revenue
SELECT
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY total_revenue DESC;


-- 2. Categories selling most items
SELECT
    ct.product_category_name_english AS category,
    COUNT(*) AS items_sold
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
ORDER BY items_sold DESC;


-- 3. Top products by revenue
SELECT
    oi.product_id,
    ct.product_category_name_english AS category,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY
    oi.product_id,
    ct.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;


-- 4. Categories with highest AOV
SELECT
    ct.product_category_name_english AS category,
    ROUND(
        SUM(oi.price + oi.freight_value) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
HAVING COUNT(DISTINCT oi.order_id) >= 100
ORDER BY average_order_value DESC;


------------------------------------------- CUSTOMER ANALYSIS-------------------------------------------------


-- 1. How many orders does each customer place?
SELECT
    customer_unique_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY customer_unique_id
ORDER BY total_orders DESC;


-- 2. Who are the highest-spending customers?
SELECT
    c.customer_unique_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY c.customer_unique_id
ORDER BY total_spent DESC
LIMIT 10;


-- 3. What percentage of customers are repeat customers?
WITH customer_orders AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE total_orders > 1) AS repeat_customers,
    ROUND(
        COUNT(*) FILTER (WHERE total_orders > 1)::NUMERIC
        * 100 / COUNT(*),
        2
    ) AS repeat_customer_percentage
FROM customer_orders;


---------------------------------------------- SELLER ANALYSIS---------------------------------------------


-- 1. Which sellers generate the most revenue?
SELECT
    oi.seller_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS total_revenue
FROM order_items oi
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;


-- 2. Which sellers sell the most items?
SELECT
    seller_id,
    COUNT(*) AS items_sold
FROM order_items
GROUP BY seller_id
ORDER BY items_sold DESC
LIMIT 10;


-- 3. Which sellers have the highest average order value?
SELECT
    seller_id,
    ROUND(
        SUM(price + freight_value) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) >= 100
ORDER BY average_order_value DESC
LIMIT 10;


-------------------------------------------- PAYMENT ANALYSIS---------------------------------------------


-- 1. Which payment methods are most popular?
SELECT
    payment_type,
    COUNT(*) AS payment_count,
    ROUND(
        COUNT(*)::NUMERIC * 100 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM payments
GROUP BY payment_type
ORDER BY payment_count DESC;


-- 2. Which payment methods generate the most payment value?
SELECT
    payment_type,
    ROUND(SUM(payment_value), 2) AS total_payment_value,
    ROUND(
        SUM(payment_value) * 100 /
        SUM(SUM(payment_value)) OVER (),
        2
    ) AS percentage
FROM payments
GROUP BY payment_type
ORDER BY total_payment_value DESC;


-- 3. How do customers use installments?
SELECT
    payment_installments,
    COUNT(*) AS payment_count,
    ROUND(
        COUNT(*)::NUMERIC * 100 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM payments
GROUP BY payment_installments
ORDER BY payment_installments;


-------------------------------------------- DELIVERY & LOGISTICS ANALYSIS--------------------------------------


-- 1. What is the average delivery time?
SELECT
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    order_delivered_customer_date
                    - order_purchase_timestamp
                )
            ) / 86400
        ),
        2
    ) AS average_delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL;


-- 2. How many orders were Early, On Time, Late, or Not Delivered?
SELECT
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        WHEN order_delivered_customer_date < order_estimated_delivery_date
            THEN 'Early'
        WHEN order_delivered_customer_date = order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END AS delivery_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    CASE
        WHEN order_delivered_customer_date IS NULL
            THEN 'Not Delivered'
        WHEN order_delivered_customer_date < order_estimated_delivery_date
            THEN 'Early'
        WHEN order_delivered_customer_date = order_estimated_delivery_date
            THEN 'On Time'
        ELSE 'Late'
    END
ORDER BY total_orders DESC;


-- 3. Does delivery performance affect customer satisfaction?
WITH delivery_status AS (
    SELECT
        order_id,
        CASE
            WHEN order_delivered_customer_date IS NULL
                THEN 'Not Delivered'
            WHEN order_delivered_customer_date < order_estimated_delivery_date
                THEN 'Early'
            WHEN order_delivered_customer_date = order_estimated_delivery_date
                THEN 'On Time'
            ELSE 'Late'
        END AS status
    FROM orders
)
SELECT
    d.status AS delivery_status,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM delivery_status d
JOIN reviews r
    ON d.order_id = r.order_id
GROUP BY d.status
ORDER BY average_review_score DESC;


--------------------------------------- CUSTOMER SATISFACTION / REVIEW ANALYSIS-------------------------------------


-- 1. What is the overall customer satisfaction?
SELECT
    ROUND(AVG(review_score), 2) AS average_review_score
FROM reviews;


-- 2. How are customer ratings distributed?
SELECT
    review_score,
    COUNT(*) AS review_count,
    ROUND(
        COUNT(*)::NUMERIC * 100 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM reviews
GROUP BY review_score
ORDER BY review_score;


-- 3. Which product categories have lower customer ratings?
SELECT
    ct.product_category_name_english AS category,
    COUNT(r.review_id) AS review_count,
    ROUND(AVG(r.review_score), 2) AS average_review_score
FROM reviews r
JOIN order_items oi
    ON r.order_id = oi.order_id
JOIN products p
    ON oi.product_id = p.product_id
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name
GROUP BY ct.product_category_name_english
HAVING COUNT(r.review_id) >= 100
ORDER BY average_review_score ASC
LIMIT 10;