-- ============================================================
-- E-Commerce Analytics Portfolio
-- Schema: customers, products, categories, orders, order_items
-- ============================================================

-- Drop tables if rebuilding
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS categories CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

-- ─── Customers ────────────────────────────────────────────────
CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) UNIQUE NOT NULL,
    city          VARCHAR(50),
    country       VARCHAR(50) DEFAULT 'South Africa',
    signup_date   DATE NOT NULL,
    is_active     BOOLEAN DEFAULT TRUE
);

-- ─── Categories ───────────────────────────────────────────────
CREATE TABLE categories (
    category_id   SERIAL PRIMARY KEY,
    name          VARCHAR(50) NOT NULL,
    description   TEXT
);

-- ─── Products ─────────────────────────────────────────────────
CREATE TABLE products (
    product_id    SERIAL PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    category_id   INT REFERENCES categories(category_id),
    price         NUMERIC(10, 2) NOT NULL,
    stock         INT DEFAULT 0,
    created_at    DATE DEFAULT CURRENT_DATE
);

-- ─── Orders ───────────────────────────────────────────────────
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INT REFERENCES customers(customer_id),
    order_date    DATE NOT NULL,
    status        VARCHAR(20) CHECK (status IN ('pending', 'shipped', 'delivered', 'cancelled')),
    shipping_city VARCHAR(50)
);

-- ─── Order Items ──────────────────────────────────────────────
CREATE TABLE order_items (
    item_id       SERIAL PRIMARY KEY,
    order_id      INT REFERENCES orders(order_id),
    product_id    INT REFERENCES products(product_id),
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    NUMERIC(10, 2) NOT NULL
);

-- ─── Indexes ──────────────────────────────────────────────────
CREATE INDEX idx_orders_customer   ON orders(customer_id);
CREATE INDEX idx_orders_date       ON orders(order_date);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_products_category ON products(category_id);

