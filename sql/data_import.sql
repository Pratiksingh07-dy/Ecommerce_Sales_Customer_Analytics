-- ============================================================
-- data_import.sql
-- E-Commerce Sales & Customer Analytics
-- ============================================================
-- Instructions and commands for importing the cleaned CSV files
-- into MySQL. Run database_schema.sql FIRST.
-- ============================================================

USE ecommerce_analytics;

-- ------------------------------------------------------------
-- OPTION A: Import via MySQL Workbench "Table Data Import Wizard"
-- ------------------------------------------------------------
-- 1. Right-click the `orders` table -> Table Data Import Wizard
-- 2. Select data/cleaned/ecommerce_cleaned.csv
-- 3. Map each CSV column to the matching table column (names are
--    identical, so auto-mapping should work)
-- 4. Run the import
-- Repeat the same steps for customer_rfm_segments using
-- data/cleaned/customer_rfm_segments.csv

-- ------------------------------------------------------------
-- OPTION B: Import via LOAD DATA INFILE (faster, command line)
-- ------------------------------------------------------------
-- NOTE: If your MySQL server has --secure-file-priv restrictions,
-- copy the CSV files into the directory shown by:
--   SHOW VARIABLES LIKE 'secure_file_priv';
-- and adjust the file paths below accordingly. On Windows, use
-- double backslashes or forward slashes in the path.

-- Enable local infile if needed (run once per session, as admin):
-- SET GLOBAL local_infile = 1;

LOAD DATA LOCAL INFILE 'data/cleaned/ecommerce_cleaned.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, @Order_Date, Customer_ID, Customer_Name, Product_ID, Product_Name,
 Category, Sub_Category, Quantity, Sales, Discount, Profit, Region, State, City,
 Payment_Mode, Shipping_Mode, Year, Month, Month_Name, Quarter, Day_of_Week,
 Profit_Margin, Unit_Price)
SET Order_Date = STR_TO_DATE(@Order_Date, '%Y-%m-%d');

LOAD DATA LOCAL INFILE 'data/cleaned/customer_rfm_segments.csv'
INTO TABLE customer_rfm_segments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Customer_ID, Customer_Name, Recency, Frequency, Monetary, R_Score, F_Score,
 M_Score, RFM_Score, RFM_Sum, Segment);

-- ------------------------------------------------------------
-- Verify the import
-- ------------------------------------------------------------
SELECT COUNT(*) AS orders_row_count FROM orders;
SELECT COUNT(*) AS rfm_row_count FROM customer_rfm_segments;
SELECT * FROM orders LIMIT 5;
SELECT * FROM customer_rfm_segments LIMIT 5;
