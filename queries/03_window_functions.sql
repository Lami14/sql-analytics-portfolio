-- ============================================================
-- 03 — Window Functions
-- Business Questions Answered:
--   1. Rank products by revenue within each category
--   2. Running total of revenue over time
--   3. Each customer's first and latest order date
--   4. Month-over-month revenue growth with LAG
--   5. Percentile rank of customers by spend
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- Q1. Rank products by revenue WITHIN each category
--     (RANK, PARTITION BY)
-- ─────────────────────────────────────────────────────────────
SELECT
    cat.name                                          AS category,
    p.name                                            AS product,
    SUM(oi.quantity * oi.unit_price)                  AS revenue,
    RANK() OVER (
        PARTITION BY cat.category_id
        ORDER BY SUM(oi.quantity * oi.unit_price) DESC
    )                                                 AS rank_in_category,
    DENSE_RANK() OVER (
        ORDER BY SUM(oi.quantity * oi.unit_price) DESC
    )                                                 AS overall_rank
FROM order_items oi
JOIN products   p   ON oi.product_id = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
JOIN orders     o   ON oi.order_id   = o.order_id
WHERE o.status != 'cancelled'
GROUP BY cat.category_id, cat.name, p.product_id, p.name
ORDER BY cat.name, rank_in_category;


-- ─────────────────────────────────────────────────────────────
-- Q2. Running total of revenue by month
--     (SUM ... OVER with ORDER BY = cumulative)
-- ─────────────────────────────────────────────────────────────
WITH monthly AS (
    SELECT
        TO_CHAR(o.order_date, 'YYYY-MM')          AS month,
        SUM(oi.quantity * oi.unit_price)           AS monthly_revenue
    FROM orders      o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
)
SELECT
    month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )                                              AS running_total
FROM monthly
ORDER BY month;


-- ─────────────────────────────────────────────────────────────
-- Q3. Each customer's first order, latest order & order number
--     (ROW_NUMBER, FIRST_VALUE, LAST_VALUE)
-- ─────────────────────────────────────────────────────────────
SELECT DISTINCT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)            AS customer_name,
    FIRST_VALUE(o.order_date) OVER (
        PARTITION BY c.customer_id ORDER BY o.order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )                                                  AS first_order_date,
    LAST_VALUE(o.order_date) OVER (
        PARTITION BY c.customer_id ORDER BY o.order_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )                                                  AS latest_order_date,
    COUNT(o.order_id) OVER (
        PARTITION BY c.customer_id
    )                                                  AS total_orders
FROM customers   c
JOIN orders      o ON c.customer_id = o.customer_id
WHERE o.status != 'cancelled'
ORDER BY total_orders DESC;


-- ─────────────────────────────────────────────────────────────
-- Q4. Days between each customer's consecutive orders
--     (LAG to find order gaps)
-- ─────────────────────────────────────────────────────────────
WITH customer_orders AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)    AS customer_name,
        o.order_id,
        o.order_date,
        LAG(o.order_date) OVER (
            PARTITION BY c.customer_id
            ORDER BY o.order_date
        )                                          AS previous_order_date
    FROM customers c
    JOIN orders    o ON c.customer_id = o.customer_id
    WHERE o.status != 'cancelled'
)
SELECT
    customer_id,
    customer_name,
    order_id,
    order_date,
    previous_order_date,
    order_date - previous_order_date               AS days_between_orders
FROM customer_orders
WHERE previous_order_date IS NOT NULL
ORDER BY customer_id, order_date;


-- ─────────────────────────────────────────────────────────────
-- Q5. Percentile rank of customers by total spend
--     (PERCENT_RANK, NTILE)
-- ─────────────────────────────────────────────────────────────
WITH customer_spend AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)    AS customer_name,
        SUM(oi.quantity * oi.unit_price)           AS total_spend
    FROM customers   c
    JOIN orders      o  ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY c.customer_id, c.first_name, c.last_name
)
SELECT
    customer_name,
    total_spend,
    ROUND(PERCENT_RANK() OVER (ORDER BY total_spend) * 100, 2)   AS percentile,
    NTILE(4) OVER (ORDER BY total_spend)                          AS quartile,
    CASE NTILE(4) OVER (ORDER BY total_spend)
        WHEN 4 THEN 'Top 25%'
        WHEN 3 THEN 'Upper Mid'
        WHEN 2 THEN 'Lower Mid'
        ELSE        'Bottom 25%'
    END                                                           AS spend_tier
FROM customer_spend
ORDER BY total_spend DESC;

