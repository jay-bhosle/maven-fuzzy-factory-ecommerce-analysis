CREATE DATABASE maven_fuzzy_factory;
USE maven_fuzzy_factory;


USE maven_fuzzy_factory;

CREATE TABLE website_sessions (
    website_session_id INT,
    created_at DATETIME,
    user_id INT,
    utm_source VARCHAR(50),
    utm_campaign VARCHAR(50),
    utm_content VARCHAR(50),
    device_type VARCHAR(20),
    http_referer VARCHAR(255)
);

CREATE TABLE website_pageviews (
    website_pageview_id INT,
    created_at DATETIME,
    website_session_id INT,
    pageview_url VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT,
    created_at DATETIME,
    website_session_id INT,
    user_id INT,
    primary_product_id INT,
    items_purchased INT,
    price_usd DECIMAL(10,2),
    cogs_usd DECIMAL(10,2)
);

CREATE TABLE order_items (
    order_item_id INT,
    created_at DATETIME,
    order_id INT,
    product_id INT,
    is_primary_item INT,
    price_usd DECIMAL(10,2),
    cogs_usd DECIMAL(10,2)
);

CREATE TABLE order_item_refunds (
    order_item_refund_id INT,
    created_at DATETIME,
    order_item_id INT,
    refund_amount_usd DECIMAL(10,2)
);

CREATE TABLE products (
    product_id INT,
    created_at DATETIME,
    product_name VARCHAR(100)
);


SET GLOBAL local_infile = 1;


USE maven_fuzzy_factory;

LOAD DATA LOCAL INFILE 'C:/Users/digvi/Desktop/Sharpener/Portfolio project/2.SQL/Maven+Fuzzy+Factory/website_sessions.csv'
INTO TABLE website_sessions
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/digvi/Desktop/Sharpener/Portfolio project/2.SQL/Maven+Fuzzy+Factory/website_pageviews.csv'
INTO TABLE website_pageviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/digvi/Desktop/Sharpener/Portfolio project/2.SQL/Maven+Fuzzy+Factory/orders.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/digvi/Desktop/Sharpener/Portfolio project/2.SQL/Maven+Fuzzy+Factory/order_items.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/digvi/Desktop/Sharpener/Portfolio project/2.SQL/Maven+Fuzzy+Factory/order_item_refunds.csv'
INTO TABLE order_item_refunds
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'C:/Users/digvi/Desktop/Sharpener/Portfolio project/2.SQL/Maven+Fuzzy+Factory/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


SELECT COUNT(*) FROM website_sessions;
SELECT COUNT(*) FROM website_pageviews;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_item_refunds;
SELECT COUNT(*) FROM products;


SELECT
    COUNT(*) AS total_rows,
    SUM(website_session_id IS NULL) AS null_session_id,
    SUM(created_at IS NULL) AS null_created_at,
    SUM(user_id IS NULL) AS null_user_id
FROM website_sessions;

SELECT
    COUNT(*) AS total_rows,
    SUM(order_id IS NULL) AS null_order_id,
    SUM(website_session_id IS NULL) AS null_session_id,
    SUM(price_usd IS NULL) AS null_price
FROM orders;

SELECT website_session_id, COUNT(*)
FROM website_sessions
GROUP BY website_session_id
HAVING COUNT(*) > 1;

SELECT order_id, COUNT(*)
FROM orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT
    MIN(created_at) AS earliest_date,
    MAX(created_at) AS latest_date
FROM website_sessions;

SELECT COUNT(*) AS orders_without_sessions
FROM orders o
LEFT JOIN website_sessions ws
    ON o.website_session_id = ws.website_session_id
WHERE ws.website_session_id IS NULL;

SELECT COUNT(*) AS pageviews_without_sessions
FROM website_pageviews wp
LEFT JOIN website_sessions ws
    ON wp.website_session_id = ws.website_session_id
WHERE ws.website_session_id IS NULL;

SELECT r.*
FROM order_item_refunds r
JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
WHERE r.refund_amount_usd > oi.price_usd;


USE maven_fuzzy_factory;

CREATE TABLE website_sessions_clean AS
SELECT
    website_session_id,
    created_at,
    user_id,
    utm_source,
    utm_campaign,
    utm_content,
    device_type,
    http_referer
FROM website_sessions
WHERE website_session_id IS NOT NULL
  AND created_at IS NOT NULL;


USE maven_fuzzy_factory;

CREATE TABLE orders_clean AS
SELECT DISTINCT *
FROM orders
WHERE order_id IS NOT NULL
  AND price_usd > 0;


USE maven_fuzzy_factory;

CREATE TABLE website_pageviews_clean AS
SELECT DISTINCT wp.*
FROM website_pageviews wp
JOIN website_sessions_clean ws
    ON wp.website_session_id = ws.website_session_id
WHERE wp.website_pageview_id IS NOT NULL
  AND wp.created_at IS NOT NULL;


USE maven_fuzzy_factory;

CREATE TABLE order_items_clean AS
SELECT DISTINCT oi.*
FROM order_items oi
JOIN orders_clean o
    ON oi.order_id = o.order_id
WHERE oi.order_item_id IS NOT NULL
  AND oi.price_usd IS NOT NULL;


USE maven_fuzzy_factory;

CREATE TABLE order_item_refunds_clean AS
SELECT DISTINCT
    r.order_item_refund_id,
    r.created_at,
    r.order_item_id,
    r.refund_amount_usd,
    CASE
        WHEN r.refund_amount_usd > oi.price_usd THEN 1
        ELSE 0
    END AS refund_exceeds_item_price
FROM order_item_refunds r
JOIN order_items_clean oi
    ON r.order_item_id = oi.order_item_id
WHERE r.order_item_refund_id IS NOT NULL;


USE maven_fuzzy_factory;

CREATE TABLE products_clean AS
SELECT DISTINCT *
FROM products
WHERE product_id IS NOT NULL
  AND product_name IS NOT NULL;


SELECT
    refund_exceeds_item_price,
    COUNT(*) AS refund_count,
    SUM(refund_amount_usd) AS total_refund_usd
FROM order_item_refunds_clean
GROUP BY refund_exceeds_item_price;


SELECT COUNT(*) FROM website_sessions_clean;
SELECT COUNT(*) FROM website_pageviews_clean;
SELECT COUNT(*) FROM orders_clean;
SELECT COUNT(*) FROM order_items_clean;
SELECT COUNT(*) FROM order_item_refunds_clean;
SELECT COUNT(*) FROM products_clean;


SELECT
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(*) AS sessions
FROM website_sessions_clean
GROUP BY 1, 2
ORDER BY 1, 2;


SELECT
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    COUNT(*) AS orders
FROM orders_clean
GROUP BY 1, 2
ORDER BY 1, 2;


SELECT
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id
GROUP BY 1, 2
ORDER BY 1, 2;


SELECT
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT o.order_id) * 1.0
        / COUNT(DISTINCT ws.website_session_id) AS session_to_order_cvr
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id
GROUP BY 1, 2
ORDER BY 1, 2;


SELECT
    COUNT(DISTINCT o.order_id) * 1.0
    / COUNT(DISTINCT ws.website_session_id) AS overall_cvr
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id;


SELECT
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) * 1.0
        / COUNT(DISTINCT ws.website_session_id) AS session_to_order_cvr
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id
GROUP BY 1, 2
ORDER BY 1, 2;


SELECT
    YEAR(ws.created_at) AS yr,
    QUARTER(ws.created_at) AS qtr,
    COUNT(DISTINCT o.order_id) * 1.0
        / COUNT(DISTINCT ws.website_session_id) AS session_to_order_cvr
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id
GROUP BY 1, 2
ORDER BY 1, 2;


SET SQL_SAFE_UPDATES = 0;

UPDATE website_sessions_clean 
SET utm_source = NULL 
WHERE utm_source = '';

SET SQL_SAFE_UPDATES = 1;


SELECT
    CASE
        WHEN utm_source = 1 THEN 'Paid / Tagged Traffic'
        WHEN utm_source = 0 AND http_referer IS NOT NULL THEN 'Organic Search'
        WHEN utm_source = 0 AND http_referer IS NULL THEN 'Direct'
        ELSE 'Other'
    END AS channel,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) * 1.0
        / COUNT(DISTINCT ws.website_session_id) AS conversion_rate
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id
GROUP BY channel
ORDER BY sessions DESC;


SELECT
    CASE
        WHEN utm_source = 1 THEN 'Paid / Tagged Traffic'
        WHEN utm_source = 0 AND http_referer IS NOT NULL THEN 'Organic Search'
        WHEN utm_source = 0 AND http_referer IS NULL THEN 'Direct'
        ELSE 'Other'
    END AS channel,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(o.price_usd) AS revenue_usd,
    SUM(o.price_usd) / COUNT(DISTINCT o.order_id) AS revenue_per_order
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id
GROUP BY channel
ORDER BY revenue_usd DESC;


SELECT
    SUM(price_usd) / COUNT(DISTINCT order_id) AS avg_order_value
FROM orders_clean;


SELECT
    YEAR(created_at) AS yr,
    MONTH(created_at) AS mo,
    SUM(price_usd) / COUNT(DISTINCT order_id) AS avg_order_value
FROM orders_clean
GROUP BY 1, 2
ORDER BY 1, 2;


SELECT
    SUM(o.price_usd) * 1.0
        / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id;


SELECT
    YEAR(ws.created_at) AS yr,
    MONTH(ws.created_at) AS mo,
    SUM(o.price_usd) * 1.0
        / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id
GROUP BY 1, 2
ORDER BY 1, 2;


SELECT
    CASE
        WHEN utm_source = 1 THEN 'Paid / Tagged Traffic'
        WHEN utm_source = 0 THEN 'Organic Search'
        ELSE 'Other'
    END AS channel,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(o.price_usd) AS revenue_usd,
    SUM(o.price_usd) / COUNT(DISTINCT o.order_id) AS revenue_per_order,
    SUM(o.price_usd) * 1.0
        / COUNT(DISTINCT ws.website_session_id) AS revenue_per_session
FROM website_sessions_clean ws
LEFT JOIN orders_clean o
    ON ws.website_session_id = o.website_session_id
GROUP BY channel
ORDER BY revenue_usd DESC;


