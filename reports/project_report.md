# Project Report: E-Commerce Sales & Customer Analytics

---

## 1. Introduction

This project analyzes a synthetic-but-realistic e-commerce transactional dataset to
demonstrate an end-to-end data analytics workflow: raw data ingestion, data cleaning,
exploratory data analysis, SQL-based analysis, customer segmentation, KPI reporting, and
dashboard design. It is built as a portfolio-ready project for a Data Analyst / Business
Analyst fresher role.

## 2. Business Problem

An e-commerce company wants to understand:
- Where its revenue and profit actually come from (categories, regions, products)
- Whether its discounting strategy is helping or hurting profitability
- Who its most valuable customers are, and which customers are at risk of churning
- What concrete, data-backed actions would improve profitability and retention

## 3. Objectives

1. Clean and validate a messy, realistic raw dataset.
2. Explore sales, profit, customer, and product patterns visually.
3. Answer 20+ analytical business questions using SQL.
4. Segment customers using RFM analysis into actionable groups.
5. Design a 3-page Power BI dashboard with the key KPIs and DAX measures.
6. Translate findings into concrete, non-generic business recommendations.

## 4. Dataset Description

- **Source:** Synthetically generated (`src/data_generation.py`, seed = 42) to mirror
  realistic e-commerce order-line data, since a suitably-sized clean public dataset with
  the exact required schema and quality issues was not available.
- **Raw size:** 42,504 order-line records, 17 columns.
- **Cleaned size:** 41,262 records, 24 columns (after cleaning and feature engineering).
- **Key columns:** `Order_ID`, `Order_Date`, `Customer_ID`, `Customer_Name`, `Product_ID`,
  `Product_Name`, `Category`, `Sub_Category`, `Quantity`, `Sales`, `Discount`, `Profit`,
  `Region`, `State`, `City`, `Payment_Mode`, `Shipping_Mode`.
- **Time range:** January 2022 - December 2023.
- **Intentional data-quality issues:** missing values, exact and near-duplicate rows,
  inconsistent text casing/whitespace, invalid numeric values (negative quantity, >100%
  discount), multiple date formats, future/impossible dates, and a mix of genuine bulk-order
  outliers versus data-error outliers - detailed in Section 5.

## 5. Data Cleaning

Performed in `notebooks/01_data_cleaning.ipynb`. Key steps:

| Step | Action | Rationale |
|---|---|---|
| Duplicates | Removed exact duplicate rows and duplicate `Order_ID`s (kept first) | Prevent double-counting revenue |
| Missing categorical values | Filled with `'Unknown'` / `'Unknown Customer'` | Preserve otherwise-valid records |
| Missing `Discount` | Imputed with category median | Discount is a continuous field; median is robust to skew |
| Missing/zero `Sales` | Dropped | A record with no revenue is unusable for revenue analysis |
| Text formatting (`Region`, `Payment_Mode`) | Standardized casing/whitespace, mapped synonyms | Prevent the same value being counted as multiple categories |
| Negative `Quantity` | Converted to absolute value | Clear sign-entry error, not a reason to discard the row |
| `Discount` > 100% | Treated as missing, then imputed | Logically impossible value |
| Multiple date formats / future dates / unparseable dates | Parsed with multi-format logic; dropped unparseable and future dates | Dates outside the valid range cannot be trusted for any time-based analysis |
| Sales outliers | **Investigated, not blindly deleted** - kept outliers where Quantity was proportionally high (genuine bulk orders), removed outliers where Quantity was low (likely data errors) | Avoids destroying real signal while still removing likely errors |

Final cleaned dataset: **41,262 rows, 0 missing values**, saved to `data/cleaned/ecommerce_cleaned.csv`.

**Feature engineering added:** `Year`, `Month`, `Month_Name`, `Quarter`, `Day_of_Week`,
`Profit_Margin`, `Unit_Price`.

## 6. Exploratory Data Analysis

Performed in `notebooks/02_eda.ipynb`, covering:
- Overall KPIs (revenue, profit, orders, customers, AOV, margin)
- Monthly/yearly sales and profit trends, with visible Oct-Nov-Jan seasonality
- Sales and profit by category, sub-category, region, state, and city
- Customer-level metrics: orders per customer, revenue per customer, repeat vs one-time
- Product-level metrics: top/bottom performers by sales, profit, and quantity
- Discount-vs-profit relationship, quantified with box plots, scatter plots, and correlation
- A category x region heatmap to spot combined effects

All charts are saved as PNGs in `reports/` for reuse in the README or a slide deck.

## 7. SQL Analysis

Performed in `sql/analysis_queries.sql` against a MySQL database defined in
`sql/database_schema.sql` and populated per `sql/data_import.sql`. **24 queries** are
included, covering:
- Core KPIs (revenue, profit, orders, customers, AOV)
- Time-series queries including a `LAG()`-based month-over-month growth query
- Product and category rankings, including a `RANK()`-partitioned top-3-per-category query
- Loss-making product detection via `GROUP BY ... HAVING`
- Customer analysis: top customers, repeat vs one-time, revenue contribution via window functions
- A `JOIN` between the `orders` and `customer_rfm_segments` tables to compute
  revenue by RFM segment
- An `NTILE()`-based query identifying high-volume, low-margin products

All queries were validated for correctness against the actual cleaned dataset (via DuckDB,
which supports the same ANSI SQL window-function syntax) before being finalized as
MySQL-compatible statements.

## 8. Customer Segmentation (RFM)

Performed in `notebooks/03_customer_segmentation.ipynb`:
- **Recency, Frequency, Monetary** computed per customer from the cleaned order data.
- Each dimension scored 1-5 using rank-based quintiles (`qcut` on ranks, to handle ties
  from the skewed frequency distribution).
- Customers mapped into 7 segments: **Champions, Loyal Customers, Potential Loyalists,
  New Customers, At Risk, Needs Attention, Lost Customers.**
- Segment-level revenue, average order value, and recommended business action computed
  for each group.
- Output exported to `data/cleaned/customer_rfm_segments.csv` for use in SQL and Power BI.

**Headline result:** Champions are 22.9% of customers but generate 64.6% of total revenue,
while At Risk + Needs Attention + Lost customers are 49.7% of customers but only 15.2% of
revenue - a clear retention and reactivation opportunity.

## 9. Dashboard

A 3-page Power BI dashboard is specified in full detail in
`dashboard/powerbi_dashboard_guide.md`, including:
- **Page 1 - Executive Overview:** KPI cards, monthly trends, category/region sales, top products
- **Page 2 - Customer Analytics:** RFM segment distribution, top customers, repeat-rate visuals
- **Page 3 - Product & Profitability:** sales-vs-profit, discount-vs-profit scatter, loss-making products
- 12 named DAX measures with plain-language explanations

A `.pbix` file could not be produced directly in this environment (no Power BI Desktop
available), so the guide is written to let anyone reproduce the exact dashboard from the
cleaned CSV or the MySQL database.

## 10. Key Findings

(Full detail with evidence and recommendations in `reports/business_insights.md`.)

1. Electronics drives 46% of revenue at only average (5.29%) margin.
2. Clothing (13.46%) and Office Supplies (9.47%) are the most margin-efficient categories.
3. Furniture is the weakest category by margin (1.35%) and contains both loss-making products.
4. Discounts above ~20% are unprofitable on average.
5. Champions (22.9% of customers) generate 64.6% of revenue.
6. Nearly half of customers (49.7%) fall into At Risk/Needs Attention/Lost segments.
7. 88.5% of customers are repeat buyers; 11.5% never return.
8. Clear Oct-Nov-Jan seasonal sales peaks exist.
9. Regional performance is balanced - not a major lever.
10. UPI is the dominant payment method (~30% of transactions).

## 11. Business Recommendations

1. **Discount policy:** Cap standard promotional discounts at 15-20%; require sign-off above that threshold.
2. **Category portfolio:** Grow Clothing and Office Supplies investment given their superior margins; review Furniture pricing/sourcing given its 1.35% margin.
3. **Customer retention:** Launch a formal loyalty program for Champions; targeted win-back campaigns for the At Risk segment specifically.
4. **New customer conversion:** Structured post-first-purchase follow-up for one-time buyers before they age into "Lost."
5. **Seasonal planning:** Plan inventory/staffing around the confirmed Oct-Nov-Jan peak, while modeling festive discount depth against margin data.
6. **Payments:** Prioritize UPI checkout UX given it is the leading payment channel.
7. **Regional strategy:** Maintain current allocation; regional performance is not a differentiator here.

## 12. Conclusion

This project demonstrates a complete, realistic data-analyst workflow from messy raw data
to actionable, evidence-backed business recommendations, using Python/Pandas for cleaning
and EDA, SQL for structured analytical querying, and RFM analysis for customer
segmentation - all converging into a specification for a decision-support Power BI
dashboard.

## 13. Future Scope

- Extend the dataset with returns/refunds data to analyze net profitability more precisely.
- Add a cohort-retention analysis (month-of-first-purchase cohorts) alongside RFM.
- Incorporate marketing spend/channel data to compute customer acquisition cost (CAC) and CAC-to-LTV ratios.
- Automate the pipeline (data generation -> cleaning -> SQL load -> dashboard refresh) with a scheduler for a "live" portfolio demo.
- Build the actual `.pbix` file and publish it to Power BI Service for a live public link.
