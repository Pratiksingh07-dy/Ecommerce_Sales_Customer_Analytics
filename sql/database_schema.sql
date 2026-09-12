-- ============================================================
-- database_schema.sql
-- E-Commerce Sales & Customer Analytics
-- ============================================================
-- Creates the database and the core fact table used for all
-- SQL analysis in this project. Column names match the cleaned
-- CSV exactly (data/cleaned/ecommerce_cleaned.csv) so the file
-- can be imported directly.
-- ============================================================

CREATE DATABASE IF NOT EXISTS ecommerce_analytics
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ecommerce_analytics;

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    Order_ID        VARCHAR(20)     NOT NULL,
    Order_Date      DATE            NOT NULL,
    Customer_ID     VARCHAR(20)     NOT NULL,
    Customer_Name   VARCHAR(150)    NOT NULL,
    Product_ID      VARCHAR(20)     NOT NULL,
    Product_Name    VARCHAR(150)    NOT NULL,
    Category        VARCHAR(50)     NOT NULL,
    Sub_Category    VARCHAR(50)     NOT NULL,
    Quantity        INT             NOT NULL,
    Sales           DECIMAL(12,2)   NOT NULL,
    Discount        DECIMAL(5,2)    NOT NULL,
    Profit          DECIMAL(12,2)   NOT NULL,
    Region          VARCHAR(20)     NOT NULL,
    State           VARCHAR(50)     NOT NULL,
    City            VARCHAR(50)     NOT NULL,
    Payment_Mode    VARCHAR(30)     NOT NULL,
    Shipping_Mode   VARCHAR(20)     NOT NULL,
    Year            INT             NOT NULL,
    Month           INT             NOT NULL,
    Month_Name      VARCHAR(10)     NOT NULL,
    Quarter         INT             NOT NULL,
    Day_of_Week     VARCHAR(15)     NOT NULL,
    Profit_Margin   DECIMAL(6,4)    NOT NULL,
    Unit_Price      DECIMAL(12,2)   NOT NULL,
    PRIMARY KEY (Order_ID)
);

-- Customer RFM segmentation table (produced by notebooks/03_customer_segmentation.ipynb)
DROP TABLE IF EXISTS customer_rfm_segments;

CREATE TABLE customer_rfm_segments (
    Customer_ID     VARCHAR(20)     NOT NULL,
    Customer_Name   VARCHAR(150)    NOT NULL,
    Recency         INT             NOT NULL,
    Frequency       INT             NOT NULL,
    Monetary        DECIMAL(14,2)   NOT NULL,
    R_Score         INT             NOT NULL,
    F_Score         INT             NOT NULL,
    M_Score         INT             NOT NULL,
    RFM_Score       VARCHAR(5)      NOT NULL,
    RFM_Sum         INT             NOT NULL,
    Segment         VARCHAR(30)     NOT NULL,
    PRIMARY KEY (Customer_ID)
);

-- ------------------------------------------------------------
-- Index suggestions
-- These speed up the GROUP BY / filter patterns used throughout
-- analysis_queries.sql. Skip these on very small datasets; they
-- matter once the table is used for repeated dashboard queries.
-- ------------------------------------------------------------
CREATE INDEX idx_orders_customer      ON orders (Customer_ID);
CREATE INDEX idx_orders_product       ON orders (Product_ID);
CREATE INDEX idx_orders_category      ON orders (Category, Sub_Category);
CREATE INDEX idx_orders_region        ON orders (Region, State, City);
CREATE INDEX idx_orders_date          ON orders (Order_Date);
CREATE INDEX idx_orders_year_month    ON orders (Year, Month);
CREATE INDEX idx_rfm_segment          ON customer_rfm_segments (Segment);
