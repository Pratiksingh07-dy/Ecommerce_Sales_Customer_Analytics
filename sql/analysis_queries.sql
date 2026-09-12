-- ============================================================
-- analysis_queries.sql
-- E-Commerce Sales & Customer Analytics
-- ============================================================
-- 24 analytical queries, progressing from basic KPIs to advanced
-- window-function analysis. Run after database_schema.sql and
-- data_import.sql. All queries are MySQL (8.0+) compatible.
-- ============================================================

USE ecommerce_analytics;

-- ============================================================
-- SECTION A: CORE KPIs (Q1-Q5)
-- ============================================================

-- Q1. Total revenue
SELECT ROUND(SUM(Sales), 2) AS Total_Revenue
FROM orders;

-- Q2. Total profit
SELECT ROUND(SUM(Profit), 2) AS Total_Profit
FROM orders;

-- Q3. Total orders
SELECT COUNT(DISTINCT Order_ID) AS Total_Orders
FROM orders;

-- Q4. Total customers
SELECT COUNT(DISTINCT Customer_ID) AS Total_Customers
FROM orders;

-- Q5. Average order value
SELECT ROUND(SUM(Sales) / COUNT(DISTINCT Order_ID), 2) AS Avg_Order_Value
FROM orders;

-- ============================================================
-- SECTION B: TIME-BASED TRENDS (Q6-Q7, Q18)
-- ============================================================

-- Q6. Monthly revenue
SELECT Year, Month, Month_Name,
       ROUND(SUM(Sales), 2) AS Monthly_Revenue
FROM orders
GROUP BY Year, Month, Month_Name
ORDER BY Year, Month;

-- Q7. Monthly profit
SELECT Year, Month, Month_Name,
       ROUND(SUM(Profit), 2) AS Monthly_Profit
FROM orders
GROUP BY Year, Month, Month_Name
ORDER BY Year, Month;

-- Q18. Month-over-month revenue growth %
-- Uses the window function LAG() to compare each month's revenue
-- to the previous month's revenue.
WITH monthly_rev AS (
    SELECT Year, Month, Month_Name, SUM(Sales) AS Revenue
    FROM orders
    GROUP BY Year, Month, Month_Name
)
SELECT
    Year, Month, Month_Name, ROUND(Revenue, 2) AS Revenue,
    ROUND(LAG(Revenue) OVER (ORDER BY Year, Month), 2) AS Prev_Month_Revenue,
    ROUND(
        (Revenue - LAG(Revenue) OVER (ORDER BY Year, Month))
        / LAG(Revenue) OVER (ORDER BY Year, Month) * 100, 2
    ) AS MoM_Growth_Pct
FROM monthly_rev
ORDER BY Year, Month;

-- ============================================================
-- SECTION C: PRODUCT ANALYSIS (Q8-Q9, Q13)
-- ============================================================

-- Q8. Top 10 products by sales
SELECT Product_Name, Category,
       ROUND(SUM(Sales), 2) AS Total_Sales
FROM orders
GROUP BY Product_Name, Category
ORDER BY Total_Sales DESC
LIMIT 10;

-- Q9. Top 10 products by profit
SELECT Product_Name, Category,
       ROUND(SUM(Profit), 2) AS Total_Profit
FROM orders
GROUP BY Product_Name, Category
ORDER BY Total_Profit DESC
LIMIT 10;

-- Q13. Loss-making products
-- Answers: "Which products are actively losing the business money?"
SELECT Product_Name, Category,
       ROUND(SUM(Sales), 2) AS Total_Sales,
       ROUND(SUM(Profit), 2) AS Total_Profit
FROM orders
GROUP BY Product_Name, Category
HAVING SUM(Profit) < 0
ORDER BY Total_Profit ASC;

-- ============================================================
-- SECTION D: CATEGORY / REGION ANALYSIS (Q10-Q12, Q19-Q20)
-- ============================================================

-- Q10. Sales by category
SELECT Category, ROUND(SUM(Sales), 2) AS Total_Sales
FROM orders
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Q11. Profit by category
SELECT Category, ROUND(SUM(Profit), 2) AS Total_Profit
FROM orders
GROUP BY Category
ORDER BY Total_Profit DESC;

-- Q12. Sales by region
SELECT Region, ROUND(SUM(Sales), 2) AS Total_Sales
FROM orders
GROUP BY Region
ORDER BY Total_Sales DESC;

-- Q19. Category contribution percentage
-- Uses a window function to compute each category's share of total revenue
-- without a separate subquery for the grand total.
SELECT
    Category,
    ROUND(SUM(Sales), 2) AS Category_Sales,
    ROUND(SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER (), 2) AS Pct_of_Total_Sales
FROM orders
GROUP BY Category
ORDER BY Category_Sales DESC;

-- Q20. Regional profitability (profit margin by region)
-- Answers: "Which region converts sales into profit most efficiently?"
SELECT
    Region,
    ROUND(SUM(Sales), 2)  AS Total_Sales,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales) * 100, 2) AS Profit_Margin_Pct
FROM orders
GROUP BY Region
ORDER BY Profit_Margin_Pct DESC;

-- ============================================================
-- SECTION E: CUSTOMER ANALYSIS (Q14-Q17)
-- ============================================================

-- Q14. Top customers by revenue
SELECT Customer_ID, Customer_Name,
       ROUND(SUM(Sales), 2) AS Total_Revenue,
       COUNT(DISTINCT Order_ID) AS Total_Orders
FROM orders
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Revenue DESC
LIMIT 10;

-- Q15. Repeat customers (placed more than one order)
SELECT COUNT(*) AS Repeat_Customer_Count
FROM (
    SELECT Customer_ID
    FROM orders
    GROUP BY Customer_ID
    HAVING COUNT(DISTINCT Order_ID) > 1
) AS repeat_customers;

-- Q16. One-time customers (placed exactly one order)
SELECT COUNT(*) AS One_Time_Customer_Count
FROM (
    SELECT Customer_ID
    FROM orders
    GROUP BY Customer_ID
    HAVING COUNT(DISTINCT Order_ID) = 1
) AS one_time_customers;

-- Q17. Customer revenue contribution (% of total revenue per customer)
-- Uses a window function so each row also shows overall total for context.
SELECT
    Customer_ID, Customer_Name,
    ROUND(SUM(Sales), 2) AS Customer_Revenue,
    ROUND(SUM(Sales) * 100.0 / SUM(SUM(Sales)) OVER (), 3) AS Pct_of_Total_Revenue
FROM orders
GROUP BY Customer_ID, Customer_Name
ORDER BY Customer_Revenue DESC
LIMIT 15;

-- ============================================================
-- SECTION F: ADVANCED QUERIES (JOIN, CASE WHEN, CTE, RANK, LAG)
-- ============================================================

-- Q21. RANK() - Rank products within each category by total sales
-- Answers: "Who is the #1 product in each category?" - useful for
-- category managers who only care about relative rank, not raw totals.
WITH product_sales AS (
    SELECT Category, Product_Name, SUM(Sales) AS Total_Sales
    FROM orders
    GROUP BY Category, Product_Name
)
SELECT
    Category, Product_Name, ROUND(Total_Sales, 2) AS Total_Sales,
    RANK() OVER (PARTITION BY Category ORDER BY Total_Sales DESC) AS Sales_Rank_In_Category
FROM product_sales
QUALIFY Sales_Rank_In_Category <= 3
ORDER BY Category, Sales_Rank_In_Category;
-- NOTE: QUALIFY is not supported in MySQL 8.0. If your MySQL version
-- rejects QUALIFY, wrap the query above in a subquery instead:
--   SELECT * FROM ( ... RANK() ... ) ranked WHERE Sales_Rank_In_Category <= 3;

-- Q21b. MySQL-safe version of the same ranking query (subquery form)
SELECT * FROM (
    SELECT
        Category, Product_Name, ROUND(SUM(Sales), 2) AS Total_Sales,
        RANK() OVER (PARTITION BY Category ORDER BY SUM(Sales) DESC) AS Sales_Rank_In_Category
    FROM orders
    GROUP BY Category, Product_Name
) ranked
WHERE Sales_Rank_In_Category <= 3
ORDER BY Category, Sales_Rank_In_Category;

-- Q22. CASE WHEN - Bucket orders into discount tiers and compare
-- average profit margin per tier.
-- Answers: "Does discounting hurt profit?"
SELECT
    CASE
        WHEN Discount = 0 THEN '0% (No Discount)'
        WHEN Discount <= 0.10 THEN '1-10%'
        WHEN Discount <= 0.20 THEN '11-20%'
        WHEN Discount <= 0.30 THEN '21-30%'
        ELSE '30%+'
    END AS Discount_Tier,
    COUNT(*) AS Order_Count,
    ROUND(AVG(Profit_Margin) * 100, 2) AS Avg_Profit_Margin_Pct
FROM orders
GROUP BY Discount_Tier
ORDER BY MIN(Discount);

-- Q23. JOIN + CTE - Combine order data with RFM segments to see
-- revenue and average order value by customer segment.
-- Answers: "How much revenue comes from Champions vs At Risk customers?"
WITH customer_orders AS (
    SELECT Customer_ID,
           COUNT(DISTINCT Order_ID) AS Orders,
           SUM(Sales) AS Revenue
    FROM orders
    GROUP BY Customer_ID
)
SELECT
    r.Segment,
    COUNT(DISTINCT r.Customer_ID) AS Customers,
    ROUND(SUM(co.Revenue), 2) AS Segment_Revenue,
    ROUND(SUM(co.Revenue) / SUM(co.Orders), 2) AS Avg_Order_Value,
    ROUND(SUM(co.Revenue) * 100.0 / SUM(SUM(co.Revenue)) OVER (), 2) AS Pct_of_Total_Revenue
FROM customer_rfm_segments r
JOIN customer_orders co ON r.Customer_ID = co.Customer_ID
GROUP BY r.Segment
ORDER BY Segment_Revenue DESC;

-- Q24. Subquery + HAVING - Products that sell well (top 25% by quantity)
-- but are simultaneously in the bottom half by profit margin.
-- Answers: "Which products have high sales volume but poor profitability?"
SELECT
    Product_Name, Category,
    Total_Quantity, ROUND(Avg_Margin * 100, 2) AS Avg_Profit_Margin_Pct
FROM (
    SELECT
        Product_Name, Category,
        SUM(Quantity) AS Total_Quantity,
        AVG(Profit_Margin) AS Avg_Margin,
        NTILE(4) OVER (ORDER BY SUM(Quantity) DESC) AS Qty_Quartile,
        NTILE(2) OVER (ORDER BY AVG(Profit_Margin) DESC) AS Margin_Half
    FROM orders
    GROUP BY Product_Name, Category
) ranked
WHERE Qty_Quartile = 1 AND Margin_Half = 2
ORDER BY Total_Quantity DESC;

-- ============================================================
-- End of analysis_queries.sql (24 queries total)
-- ============================================================
