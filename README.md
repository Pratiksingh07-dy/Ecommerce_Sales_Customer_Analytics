# E-Commerce Sales & Customer Analytics

An end-to-end data analytics portfolio project covering the full workflow from raw,
messy transactional data to a business-ready Power BI dashboard:

**Raw Data -> Data Cleaning -> EDA -> SQL Analysis -> Customer Segmentation (RFM) -> KPI Analysis -> Power BI Dashboard -> Business Insights & Recommendations**

---

## Project Overview

This project simulates a real Data Analyst engagement with an e-commerce business. It
takes a 42,500-row synthetic-but-realistic transactional dataset (complete with genuine
data-quality issues), cleans it, explores it, analyzes it with 24 SQL queries, segments
customers with RFM analysis, and turns the results into a specified 3-page Power BI
dashboard plus a set of concrete, evidence-backed business recommendations.

## Business Problem

An e-commerce company needs to understand where its revenue and profit actually come
from, whether its discounting strategy helps or hurts profitability, which customers are
most valuable (and which are at risk of churning), and what specific actions would
improve profitability and retention.

## Objectives

- Clean and validate a realistic, messy raw dataset
- Explore sales, profit, customer, and product patterns
- Answer 24 analytical business questions in SQL
- Segment customers using RFM analysis into actionable groups
- Design a 3-page Power BI dashboard with supporting DAX measures
- Deliver concrete, non-generic business recommendations backed by real numbers

## Dataset

- **41,262** cleaned order-line records (from 42,504 raw records) spanning **Jan 2022 - Dec 2023**
- **3,923** unique customers, **335** unique products across **6** categories
- Generated with `src/data_generation.py` (reproducible, seed = 42) since a public dataset
  matching the required schema, size, and quality-issue profile wasn't available
- Intentional, realistic data-quality issues: missing values, duplicates, inconsistent
  text formatting, invalid values, multiple date formats - see `reports/project_report.md`
  for exactly how each was handled

## Tools & Technologies

`Python` · `Pandas` · `NumPy` · `Matplotlib` · `Seaborn` · `MySQL` · `SQL` · `Power BI` ·
`Jupyter Notebook` · `Git/GitHub`

## Project Architecture / Workflow

```
Raw CSV (data/raw/)
    -> 01_data_cleaning.ipynb   -> Cleaned CSV (data/cleaned/)
    -> 02_eda.ipynb             -> Charts (reports/*.png)
    -> 03_customer_segmentation.ipynb -> RFM segments (data/cleaned/)
    -> MySQL (sql/*.sql)        -> 24 analytical queries
    -> Power BI (dashboard/)    -> 3-page dashboard
    -> Business insights & recommendations (reports/)
```

## Data Cleaning

Handled in `notebooks/01_data_cleaning.ipynb`: duplicate removal, missing-value
imputation/removal (decision documented per column), text standardization, invalid-value
correction, multi-format date parsing, and **investigated (not blindly deleted) outliers**
- genuine bulk orders were kept, likely data errors were removed. Full before/after
data-quality table in `reports/project_report.md`.

## Exploratory Data Analysis

Handled in `notebooks/02_eda.ipynb`: sales and profit trends, category/region/product
breakdowns, customer behavior (repeat vs one-time), and a detailed discount-vs-profit
investigation with box plots, scatter plots, and correlation analysis.

## SQL Analysis

`sql/database_schema.sql` (schema + indexes), `sql/data_import.sql` (import steps for
both CSV Wizard and `LOAD DATA INFILE`), and `sql/analysis_queries.sql` (**24 queries**
from basic KPIs through `JOIN`, `CTE`, `CASE WHEN`, `RANK()`, `LAG()`, and `NTILE()`
window-function analysis, each with a comment explaining the business question it answers).

## RFM Customer Segmentation

`notebooks/03_customer_segmentation.ipynb` computes Recency/Frequency/Monetary per
customer, scores each on a 1-5 scale, and classifies customers into 7 segments
(Champions, Loyal Customers, Potential Loyalists, New Customers, At Risk, Needs
Attention, Lost Customers), each with a recommended business action.

**Key result:** Champions are 22.9% of customers but generate **64.6%** of total revenue.

## Power BI Dashboard

A complete 3-page dashboard specification (no `.pbix` included - Power BI Desktop wasn't
available in this environment) lives in `dashboard/powerbi_dashboard_guide.md`, including
every visual, field, filter, and 12 explained DAX measures:

- **Page 1 - Executive Overview:** KPI cards + monthly trends + category/region breakdowns
- **Page 2 - Customer Analytics:** RFM segments, top customers, repeat-rate visuals
- **Page 3 - Product & Profitability:** sales vs profit, discount-vs-profit scatter, loss-makers

## Key Insights

(Full evidence and recommendations: `reports/business_insights.md`)

- Electronics drives 46% of revenue at only average margin (5.29%)
- Clothing (13.46%) and Office Supplies (9.47%) are the most profit-efficient categories
- Furniture is the weakest category by margin (1.35%) and holds both loss-making products
- Discounts above ~20% are unprofitable on average (margin turns negative)
- Champions (22.9% of customers) generate 64.6% of revenue
- 49.7% of customers are At Risk / Needs Attention / Lost, but only 15.2% of revenue
- 88.5% of customers are repeat buyers
- Clear Oct-Nov-Jan seasonal sales peak
- UPI is the leading payment method (~30% of transactions)

## Business Recommendations

1. Cap standard discounts at 15-20%; require sign-off above that.
2. Grow investment in Clothing and Office Supplies; review Furniture pricing/sourcing.
3. Build a formal loyalty program for Champions; targeted win-back campaigns for At Risk customers.
4. Add a structured post-first-purchase follow-up for one-time buyers.
5. Plan inventory/staffing around the Oct-Nov-Jan peak while modeling discount depth against margin.
6. Prioritize UPI checkout UX given its transaction share.

## Project Structure

```
Ecommerce-Sales-Customer-Analytics/
│
├── data/
│   ├── raw/ecommerce_raw.csv
│   └── cleaned/
│       ├── ecommerce_cleaned.csv
│       └── customer_rfm_segments.csv
│
├── notebooks/
│   ├── 01_data_cleaning.ipynb
│   ├── 02_eda.ipynb
│   └── 03_customer_segmentation.ipynb
│
├── sql/
│   ├── database_schema.sql
│   ├── data_import.sql
│   └── analysis_queries.sql
│
├── dashboard/
│   └── powerbi_dashboard_guide.md
│
├── reports/
│   ├── business_insights.md
│   ├── project_report.md
│   └── chart_*.png
│
├── src/
│   └── data_generation.py
│
├── requirements.txt
├── README.md
└── .gitignore
```

## How to Run

See **`MANUAL_SETUP_GUIDE.md`** for a complete, beginner-friendly, step-by-step guide
(including installing Python, MySQL, and Power BI from scratch on Windows).

Quick version (if your environment is already set up):
```bash
pip install -r requirements.txt
python src/data_generation.py
jupyter notebook notebooks/01_data_cleaning.ipynb   # run all cells
jupyter notebook notebooks/02_eda.ipynb              # run all cells
jupyter notebook notebooks/03_customer_segmentation.ipynb  # run all cells
# then load sql/database_schema.sql, sql/data_import.sql, sql/analysis_queries.sql into MySQL
# then follow dashboard/powerbi_dashboard_guide.md in Power BI Desktop
```

## Future Improvements

- Add returns/refunds data for a more precise net-profitability view
- Add cohort-retention analysis alongside RFM
- Incorporate marketing spend to compute CAC and CAC-to-LTV
- Automate the full pipeline end-to-end with a scheduler
- Publish an actual `.pbix` to Power BI Service for a live public dashboard link

---

### Resume bullet points

**E-Commerce Sales & Customer Analytics | Python, SQL, Power BI**

- Engineered an end-to-end analytics pipeline on 41K+ e-commerce transactions, resolving 8 categories of data-quality issues (duplicates, missing values, invalid entries, inconsistent formats) using Python/Pandas to produce a fully validated, analysis-ready dataset.
- Wrote 24 MySQL queries (joins, CTEs, window functions including RANK/LAG/NTILE) to quantify KPIs across revenue, profit, and customer behavior, identifying that discounts above 20% reduced average profit margin to -19.9%.
- Built an RFM-based customer segmentation model in Python identifying that 22.9% of customers ("Champions") generated 64.6% of total revenue, and designed a 3-page Power BI dashboard with 12 DAX measures to communicate these insights to stakeholders.
