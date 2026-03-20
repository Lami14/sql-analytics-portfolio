-- ============================================================
-- 04 — Stored Procedures & Views
-- Includes:
--   VIEWS:
--     1. vw_order_summary       — full order detail view
--     2. vw_product_performance — product sales dashboard view
--     3. vw_customer_summary    — customer KPIs view
--
--   STORED PROCEDURES:
--     4. get_customer_report()     — full report for one customer
--     5. get_top_products()        — top N products by revenue
--     6. get_monthly_summary()     — monthly revenue for a given year
-- ============================================================


-- ════════════════════════════════════════════════════════════
-- VIEWS
-- ════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────
-- VIEW 1: vw_order_summary
-- Full denormalised view of every order line
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    o.order_date,
    o.status,
    CONCAT(c.first_name, ' ', c.last_name)   AS customer_name,
    c.city                                   AS customer_city,
    p.name                                   AS product_name,
    cat.name                                 AS category,
    oi.quantity,
    oi.unit_price,
    (oi.quantity * oi.unit_price)            AS line_total
FROM orders      o
JOIN customers   c   ON o.customer_id  = c.customer_id
JOIN order_items oi  ON o.order_id     = oi.order_id
JOIN products    p   ON oi.product_id  = p.product_id
JOIN categories  cat ON p.category_id  = cat.category_id;

-- Usage:
-- SELECT * FROM vw_order_summary WHERE status = 'delivered';
-- SELECT * FROM vw_order_summary WHERE customer_city = 'Cape Town';


-- ─────────────────────────────────────────────────────────────
-- VIEW 2: vw_product_performance
-- Aggregated product metrics for a sales dashboard
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.name                                   AS product_name,
    cat.name                                 AS category,
    p.price                                  AS listed_price,
    COALESCE(SUM(oi.quantity), 0)            AS units_sold,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue,
    COUNT(DISTINCT o.order_id)               AS times_ordered,
    p.stock                                  AS stock_remaining
FROM products    p
LEFT JOIN categories  cat ON p.category_id  = cat.category_id
LEFT JOIN order_items oi  ON p.product_id   = oi.product_id
LEFT JOIN orders      o   ON oi.order_id    = o.order_id
    AND o.status != 'cancelled'
GROUP BY p.product_id, p.name, cat.name, p.price, p.stock;

-- Usage:
-- SELECT * FROM vw_product_performance ORDER BY total_revenue DESC;
-- SELECT * FROM vw_product_performance WHERE stock_remaining < 50;


-- ─────────────────────────────────────────────────────────────
-- VIEW 3: vw_customer_summary
-- One row per customer with their KPIs
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE VIEW vw_customer_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name)   AS customer_name,
    c.email,
    c.city,
    c.signup_date,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS lifetime_value,
    MAX(o.order_date)                        AS last_order_date,
    CURRENT_DATE - MAX(o.order_date)         AS days_since_last_order
FROM customers   c
LEFT JOIN orders      o  ON c.customer_id = o.customer_id
    AND o.status != 'cancelled'
LEFT JOIN order_items oi ON o.order_id    = oi.order_id
GROUP BY c.customer_id, c.first_name, c.last_name,
         c.email, c.city, c.signup_date;

-- Usage:
-- SELECT * FROM vw_customer_summary ORDER BY lifetime_value DESC;
-- SELECT * FROM vw_customer_summary WHERE days_since_last_order > 180;


-- ════════════════════════════════════════════════════════════
-- STORED PROCEDURES
-- ════════════════════════════════════════════════════════════

-- ─────────────────────────────────────────────────────────────
-- PROCEDURE 1: get_customer_report(p_customer_id)
-- Returns a complete profile for a given customer
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_customer_report(p_customer_id INT)
RETURNS TABLE (
    order_id        INT,
    order_date      DATE,
    status          VARCHAR,
    product_name    VARCHAR,
    category        VARCHAR,
    quantity        INT,
    line_total      NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        o.order_date,
        o.status,
        p.name          AS product_name,
        cat.name        AS category,
        oi.quantity,
        (oi.quantity * oi.unit_price) AS line_total
    FROM orders      o
    JOIN order_items oi  ON o.order_id    = oi.order_id
    JOIN products    p   ON oi.product_id = p.product_id
    JOIN categories  cat ON p.category_id = cat.category_id
    WHERE o.customer_id = p_customer_id
    ORDER BY o.order_date DESC;
END;
$$ LANGUAGE plpgsql;

-- Usage:
-- SELECT * FROM get_customer_report(1);
-- SELECT * FROM get_customer_report(7);


-- ─────────────────────────────────────────────────────────────
-- PROCEDURE 2: get_top_products(p_limit)
-- Returns top N products by revenue
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_top_products(p_limit INT DEFAULT 5)
RETURNS TABLE (
    product_name    VARCHAR,
    category        VARCHAR,
    units_sold      BIGINT,
    total_revenue   NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.name                              AS product_name,
        cat.name                            AS category,
        SUM(oi.quantity)                    AS units_sold,
        SUM(oi.quantity * oi.unit_price)    AS total_revenue
    FROM order_items oi
    JOIN products   p   ON oi.product_id = p.product_id
    JOIN categories cat ON p.category_id = cat.category_id
    JOIN orders     o   ON oi.order_id   = o.order_id
    WHERE o.status != 'cancelled'
    GROUP BY p.product_id, p.name, cat.name
    ORDER BY total_revenue DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Usage:
-- SELECT * FROM get_top_products(5);
-- SELECT * FROM get_top_products(10);


-- ─────────────────────────────────────────────────────────────
-- PROCEDURE 3: get_monthly_summary(p_year)
-- Returns month-by-month revenue breakdown for a given year
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION get_monthly_summary(p_year INT)
RETURNS TABLE (
    month           TEXT,
    total_orders    BIGINT,
    revenue         NUMERIC,
    avg_order_value NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        TO_CHAR(o.order_date, 'Month')          AS month,
        COUNT(DISTINCT o.order_id)              AS total_orders,
        SUM(oi.quantity * oi.unit_price)        AS revenue,
        ROUND(
            SUM(oi.quantity * oi.unit_price)
            / NULLIF(COUNT(DISTINCT o.order_id), 0), 2
        )                                       AS avg_order_value
    FROM orders      o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status != 'cancelled'
      AND EXTRACT(YEAR FROM o.order_date) = p_year
    GROUP BY TO_CHAR(o.order_date, 'Month'), EXTRACT(MONTH FROM o.order_date)
    ORDER BY EXTRACT(MONTH FROM o.order_date);
END;
$$ LANGUAGE plpgsql;

-- Usage:
-- SELECT * FROM get_monthly_summary(2023);
-- SELECT * FROM get_monthly_summary(2024);
