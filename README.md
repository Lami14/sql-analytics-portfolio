# 🛒 E-Commerce SQL Analytics Portfolio

A structured SQL analytics portfolio built on a realistic e-commerce dataset. Demonstrates mastery of advanced PostgreSQL concepts through real business questions — from customer segmentation to revenue trend analysis.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15-336791?logo=postgresql)
![SQL](https://img.shields.io/badge/SQL-Advanced-orange)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

---

## 📋 Business Questions Answered

| # | Question | Technique |
|---|---|---|
| 1 | Full order details across all tables | Multi-table JOINs |
| 2 | Customers who never placed an order | LEFT JOIN + NULL |
| 3 | Top 5 products by revenue | JOIN + GROUP BY |
| 4 | Orders above average order value | Subquery in HAVING |
| 5 | Customers who bought across 2+ categories | JOIN + HAVING |
| 6 | Customer lifetime value segmentation | CTEs + CASE |
| 7 | Monthly revenue trend with growth % | CTE + LAG |
| 8 | Repeat vs one-time customer breakdown | CTE + CASE |
| 9 | Revenue share by category | CTE + window |
| 10 | Customers at churn risk | CTE + date logic |
| 11 | Product rankings within each category | RANK + PARTITION BY |
| 12 | Running total of revenue over time | SUM OVER cumulative |
| 13 | Days between consecutive orders | LAG window function |
| 14 | Customer percentile by spend | PERCENT_RANK + NTILE |
| 15 | Reusable business reporting | Stored Procedures + Views |

---

## 📁 Project Structure

```
sql-analytics-portfolio/
├── schema/
│   └── create_tables.sql           # Database schema & indexes
├── data/
│   └── seed_data.sql               # Realistic e-commerce seed data
├── queries/
│   ├── 01_joins_and_subqueries.sql # JOINs & subquery analysis
│   ├── 02_ctes.sql                 # CTE-based business analysis
│   ├── 03_window_functions.sql     # Rankings, running totals, LAG
│   └── 04_stored_procedures_and_views.sql  # Reusable SQL objects
├── reports/
│   └── insights.md                 # Business findings & recommendations
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- PostgreSQL 15+ installed
- psql CLI or pgAdmin

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/sql-analytics-portfolio.git
cd sql-analytics-portfolio
```

### 2. Create the database
```bash
psql -U postgres -c "CREATE DATABASE ecommerce_db;"
```

### 3. Run the schema
```bash
psql -U postgres -d ecommerce_db -f schema/create_tables.sql
```

### 4. Load the seed data
```bash
psql -U postgres -d ecommerce_db -f data/seed_data.sql
```

### 5. Run any query file
```bash
psql -U postgres -d ecommerce_db -f queries/01_joins_and_subqueries.sql
```

Or open in **pgAdmin** and run queries interactively.

---

## 🗂️ Dataset Overview

| Table | Rows | Description |
|---|---|---|
| customers | 20 | Customer profiles across SA cities |
| categories | 5 | Product categories |
| products | 15 | Product catalogue with pricing |
| orders | 30 | Customer orders with status |
| order_items | 40 | Line items per order |

---

## 🛠️ SQL Concepts Demonstrated

| Concept | File |
|---|---|
| INNER, LEFT, multi-table JOINs | `01_joins_and_subqueries.sql` |
| Correlated & nested subqueries | `01_joins_and_subqueries.sql` |
| CTEs (`WITH` clause) | `02_ctes.sql` |
| Chained / multi-step CTEs | `02_ctes.sql` |
| `RANK`, `DENSE_RANK`, `ROW_NUMBER` | `03_window_functions.sql` |
| `LAG`, `FIRST_VALUE`, `LAST_VALUE` | `03_window_functions.sql` |
| `PERCENT_RANK`, `NTILE` | `03_window_functions.sql` |
| Cumulative `SUM OVER` | `03_window_functions.sql` |
| `CREATE VIEW` | `04_stored_procedures_and_views.sql` |
| `CREATE FUNCTION` (stored procedures) | `04_stored_procedures_and_views.sql` |

---

## 📊 Key Findings

- **Electronics** accounts for ~65% of total revenue
- **53%** of customers are one-time buyers — retention is the biggest growth lever
- **Top 2 products** (iPhone 14, Galaxy A54) drive the majority of electronics revenue
- **Johannesburg** and **Cape Town** are the strongest markets
- Full findings in [`reports/insights.md`](reports/insights.md)

---

## 💡 What I Learned

- Structuring a multi-table relational schema with proper foreign keys and indexes
- Writing production-quality SQL with readable formatting and comments
- Using window functions to answer complex analytical questions without subqueries
- Building reusable Views and Stored Procedures for business reporting
- Translating SQL results into actionable business recommendations

---

*Built by [Lamla](https://github.com/Lami14) · SQL Analytics Portfolio*
