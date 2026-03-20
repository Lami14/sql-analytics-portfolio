# 📊 E-Commerce Business Insights Report

> Findings derived from SQL analysis of the e-commerce orders dataset.
> All queries are available in the `/queries` folder.

---

## 1. 🏆 Top Performing Products

| Product | Category | Revenue (ZAR) |
|---|---|---|
| iPhone 14 | Electronics | R56,997 |
| Samsung Galaxy A54 | Electronics | R26,997 |
| Air Fryer 5L | Home & Kitchen | R5,697 |
| Wireless Earbuds | Electronics | R5,196 |
| Men's Running Shoes | Sports | R4,796 |

**Insight:** Electronics dominates revenue, accounting for roughly 65% of total sales. The top 2 products alone (iPhone 14 and Galaxy A54) make up the majority of electronics revenue, suggesting high dependency on a small number of SKUs.

**Recommendation:** Introduce more mid-range electronics to reduce revenue concentration risk.

---

## 2. 👥 Customer Segmentation (LTV Tiers)

| Segment | Criteria | Customer Count |
|---|---|---|
| VIP | Spend ≥ R20,000 | 2 |
| Loyal | Spend R5,000–R19,999 | 4 |
| Regular | Spend R1,000–R4,999 | 9 |
| New | Spend < R1,000 | 5 |

**Insight:** Only 10% of customers are in the VIP tier, yet they contribute disproportionately to total revenue. Retention of this group should be a priority.

---

## 3. 🔁 Repeat Purchase Rate

| Customer Type | Count | % of Customers |
|---|---|---|
| Loyal (3+ orders) | 3 | 18% |
| Returning (2 orders) | 5 | 29% |
| One-time | 9 | 53% |

**Insight:** Over half of customers only ever placed one order. This signals a retention problem — the business needs stronger re-engagement strategies (email campaigns, loyalty discounts).

---

## 4. 📅 Monthly Revenue Trend (2024)

| Month | Revenue (ZAR) | MoM Growth |
|---|---|---|
| January | R10,596 | — |
| February | R18,999 | +79.3% |
| March | R9,498 | -50% |
| April | R1,198 | -87.4% |
| May | R1,747 | +45.8% |
| June | R10,795 | +517.9% |
| July | R21,396 | +98.2% |

**Insight:** Revenue is highly volatile month-to-month with no clear seasonal pattern yet — the dataset is still growing. July 2024 shows strong momentum.

---

## 5. ⚠️ Churn Risk Customers

Customers with no order in the last **6 months** who warrant a re-engagement campaign:

- Thandi Mokoena — last order 365+ days ago
- Kagiso Sithole — last order 300+ days ago
- Nomsa Zulu — last order 290+ days ago

**Recommendation:** Trigger a personalised discount email to these customers.

---

## 6. 🌍 Revenue by City

| City | Orders |
|---|---|
| Johannesburg | 8 |
| Cape Town | 7 |
| Durban | 5 |
| Pretoria | 4 |
| Other | 6 |

**Insight:** Johannesburg and Cape Town are the strongest markets. Consider targeted advertising or same-day delivery offerings in these cities to increase conversion.

---

## Key SQL Techniques Used

- **JOINs** — linking 5 tables to produce full order detail reports
- **Subqueries** — calculating average order values for threshold comparisons
- **CTEs** — multi-step customer segmentation and churn analysis
- **Window Functions** — RANK, LAG, PERCENT_RANK, NTILE for advanced analytics
- **Stored Procedures** — reusable functions for recurring business reports
- **Views** — simplified interfaces for dashboards and BI tools

