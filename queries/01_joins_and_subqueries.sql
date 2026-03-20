-- ============================================================
-- 01 — JOINs & Subqueries
-- Business Questions Answered:
--   1. Full order details with customer and product info
--   2. Customers who have never placed an order
--   3. Top 5 best-selling products by revenue
--   4. Orders above the average order value
--   5. Customers who ordered from more than one category
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- Q1. Full order details — customer name, product, quantity, total
-- ─────────────────────────────────────────────────────────────
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name)    AS customer_name,
    c.city,
    p.name                                     AS product,
    cat.name                                   AS category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)              AS line_total,
    o.order_date,
    o.status
FROM orders o
JOIN customers   c   ON o.customer_id  = c.customer_id
JOIN order_items oi  ON o.order_id     = oi.order_id
JOIN products    p   ON oi.product_id  = p.product_id
JOIN categories  cat ON p.category_id  = cat.category_id
ORDER BY o.order_date DESC;


-- ─────────────────────────────────────────────────────────────
-- Q2. Customers who have NEVER placed an order (LEFT JOIN + NULL check)
-- ─────────────────────────────────────────────────────────────
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    c.signup_date
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL
ORDER BY c.signup_date;


-- ─────────────────────────────────────────────────────────────
-- Q3. Top 5 products by total revenue
-- ─────────────────────────────────────────────────────────────
SELECT
    p.name                              AS product,
    cat.name                            AS category,
    SUM(oi.quantity)                    AS units_sold,
    SUM(oi.quantity * oi.unit_price)    AS total_revenue
FROM order_items oi
JOIN products   p   ON oi.product_id  = p.product_id
JOIN categories cat ON p.category_id  = cat.category_id
JOIN orders     o   ON oi.order_id    = o.order_id
WHERE o.status != 'cancelled'
GROUP BY p.product_id, p.name, cat.name
ORDER BY total_revenue DESC
LIMIT 5;


-- ─────────────────────────────────────────────────────────────
-- Q4. Orders with value ABOVE the average order value (subquery)
-- ─────────────────────────────────────────────────────────────
SELECT
    o.order_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    o.order_date,
    SUM(oi.quantity * oi.unit_price)         AS order_value
FROM orders o
JOIN customers   c  ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id    = oi.order_id
WHERE o.status != 'cancelled'
GROUP BY o.order_id, c.first_name, c.last_name, o.order_date
HAVING SUM(oi.quantity * oi.unit_price) > (
    -- Subquery: calculate average order value
    SELECT AVG(order_total)
    FROM (
        SELECT SUM(quantity * unit_price) AS order_total
        FROM order_items
        GROUP BY order_id
    ) sub
)
ORDER BY order_value DESC;


-- ─────────────────────────────────────────────────────────────
-- Q5. Customers who ordered products from more than one category
-- ─────────────────────────────────────────────────────────────
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    COUNT(DISTINCT cat.category_id)          AS categories_bought_from,
    STRING_AGG(DISTINCT cat.name, ', ')      AS categories
FROM customers   c
JOIN orders      o   ON c.customer_id  = o.customer_id
JOIN order_items oi  ON o.order_id     = oi.order_id
JOIN products    p   ON oi.product_id  = p.product_id
JOIN categories  cat ON p.category_id  = cat.category_id
WHERE o.status != 'cancelled'
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(DISTINCT cat.category_id) > 1
ORDER BY categories_bought_from DESC;
