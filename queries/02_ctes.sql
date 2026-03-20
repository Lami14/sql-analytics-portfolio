-- ============================================================
-- 02 — CTEs (Common Table Expressions)
-- Business Questions Answered:
--   1. Customer lifetime value (LTV) segmentation
--   2. Monthly revenue trend
--   3. Repeat vs one-time customers
--   4. Category revenue share
--   5. Customers at risk of churning (no order in 6+ months)
-- ============================================================


-- ─────────────────────────────────────────────────────────────
-- Q1. Customer Lifetime Value — segmented into tiers
-- ─────────────────────────────────────────────────────────────
WITH customer_spend AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
        c.city,
        COUNT(DISTINCT o.order_id)               AS total_orders,
        SUM(oi.quantity * oi.unit_price)         AS lifetime_value
    FROM customers   c
    JOIN orders      o  ON c.customer_id = o.customer_id
    JOIN order_items oi ON o.order_id    = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.city
),
segmented AS (
    SELECT *,
        CASE
            WHEN lifetime_value >= 20000 THEN 'VIP'
            WHEN lifetime_value >= 5000  THEN 'Loyal'
            WHEN lifetime_value >= 1000  THEN 'Regular'
            ELSE                              'New'
        END AS segment
    FROM customer_spend
)
SELECT *
FROM segmented
ORDER BY lifetime_value DESC;


-- ─────────────────────────────────────────────────────────────
-- Q2. Monthly revenue trend
-- ─────────────────────────────────────────────────────────────
WITH monthly_revenue AS (
    SELECT
        TO_CHAR(o.order_date, 'YYYY-MM')         AS month,
        COUNT(DISTINCT o.order_id)               AS total_orders,
        SUM(oi.quantity * oi.unit_price)         AS revenue
    FROM orders      o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
    GROUP BY TO_CHAR(o.order_date, 'YYYY-MM')
),
with_growth AS (
    SELECT
        month,
        total_orders,
        revenue,
        LAG(revenue) OVER (ORDER BY month)       AS prev_month_revenue,
        ROUND(
            (revenue - LAG(revenue) OVER (ORDER BY month))
            / NULLIF(LAG(revenue) OVER (ORDER BY month), 0) * 100, 2
        )                                        AS month_on_month_growth_pct
    FROM monthly_revenue
)
SELECT * FROM with_growth
ORDER BY month;


-- ─────────────────────────────────────────────────────────────
-- Q3. Repeat vs one-time customers
-- ─────────────────────────────────────────────────────────────
WITH order_counts AS (
    SELECT
        customer_id,
        COUNT(order_id) AS num_orders
    FROM orders
    WHERE status != 'cancelled'
    GROUP BY customer_id
),
classified AS (
    SELECT
        CASE
            WHEN num_orders = 1 THEN 'One-time'
            WHEN num_orders = 2 THEN 'Returning'
            ELSE                     'Loyal (3+)'
        END AS customer_type,
        COUNT(*) AS customer_count
    FROM order_counts
    GROUP BY customer_type
)
SELECT
    customer_type,
    customer_count,
    ROUND(customer_count * 100.0 / SUM(customer_count) OVER (), 2) AS percentage
FROM classified
ORDER BY customer_count DESC;


-- ─────────────────────────────────────────────────────────────
-- Q4. Revenue share by category
-- ─────────────────────────────────────────────────────────────
WITH category_revenue AS (
    SELECT
        cat.name                                AS category,
        SUM(oi.quantity * oi.unit_price)        AS revenue
    FROM order_items oi
    JOIN products   p   ON oi.product_id = p.product_id
    JOIN categories cat ON p.category_id = cat.category_id
    JOIN orders     o   ON oi.order_id   = o.order_id
    WHERE o.status != 'cancelled'
    GROUP BY cat.name
),
total AS (
    SELECT SUM(revenue) AS grand_total FROM category_revenue
)
SELECT
    cr.category,
    cr.revenue,
    ROUND(cr.revenue / t.grand_total * 100, 2) AS revenue_share_pct
FROM category_revenue cr, total t
ORDER BY revenue DESC;


-- ─────────────────────────────────────────────────────────────
-- Q5. Customers at risk of churning (last order 6+ months ago)
-- ─────────────────────────────────────────────────────────────
WITH last_orders AS (
    SELECT
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
        c.email,
        MAX(o.order_date)                        AS last_order_date
    FROM customers   c
    JOIN orders      o ON c.customer_id = o.customer_id
    WHERE o.status != 'cancelled'
    GROUP BY c.customer_id, c.first_name, c.last_name, c.email
)
SELECT
    customer_id,
    customer_name,
    email,
    last_order_date,
    CURRENT_DATE - last_order_date  AS days_since_last_order
FROM last_orders
WHERE last_order_date < CURRENT_DATE - INTERVAL '6 months'
ORDER BY days_since_last_order DESC;

