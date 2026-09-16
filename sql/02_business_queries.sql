-- ============================================================
-- Business Questions — DataCo Supply Chain Analysis
-- Run with: sqlite3 data/supply_chain.db < sql/02_business_queries.sql
-- ============================================================

-- Q1. Which shipping modes have the worst late-delivery risk?
SELECT
    shipping_mode,
    COUNT(*)                                            AS total_shipments,
    ROUND(AVG(late_delivery_risk) * 100, 1)             AS late_risk_pct,
    ROUND(AVG(shipping_delay_days), 2)                  AS avg_delay_days
FROM orders
GROUP BY shipping_mode
ORDER BY late_risk_pct DESC;

-- Q2. Which order regions have the worst late-delivery risk (top 10)?
SELECT
    order_region,
    COUNT(*)                                            AS total_shipments,
    ROUND(AVG(late_delivery_risk) * 100, 1)             AS late_risk_pct
FROM orders
GROUP BY order_region
ORDER BY late_risk_pct DESC
LIMIT 10;

-- Q3. Monthly revenue and profit trend
SELECT
    order_month,
    ROUND(SUM(sales), 0)                                AS total_sales,
    ROUND(SUM(order_profit_per_order), 0)               AS total_profit,
    COUNT(DISTINCT order_id)                            AS order_count
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- Q4. Top 10 most profitable product categories
SELECT
    category_name,
    ROUND(SUM(order_profit_per_order), 0)               AS total_profit,
    ROUND(SUM(sales), 0)                                AS total_sales,
    ROUND(SUM(order_profit_per_order) * 100.0 / NULLIF(SUM(sales), 0), 2) AS profit_margin_pct
FROM orders
GROUP BY category_name
ORDER BY total_profit DESC
LIMIT 10;

-- Q5. Bottom 10 product categories by profit (loss-making / low-margin)
SELECT
    category_name,
    ROUND(SUM(order_profit_per_order), 0)               AS total_profit,
    ROUND(SUM(sales), 0)                                AS total_sales
FROM orders
GROUP BY category_name
ORDER BY total_profit ASC
LIMIT 10;

-- Q6. Average shipping delay by market
SELECT
    market,
    COUNT(*)                                            AS shipments,
    ROUND(AVG(shipping_delay_days), 2)                  AS avg_delay_days,
    ROUND(AVG(late_delivery_risk) * 100, 1)             AS late_risk_pct
FROM orders
GROUP BY market
ORDER BY avg_delay_days DESC;

-- Q7. Order status breakdown (cancellations, suspected fraud rate)
SELECT
    order_status,
    COUNT(*)                                            AS order_items,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total
FROM orders
GROUP BY order_status
ORDER BY order_items DESC;

-- Q8. Sales and profit by customer segment
SELECT
    customer_segment,
    COUNT(DISTINCT customer_id)                         AS customers,
    ROUND(SUM(sales), 0)                                AS total_sales,
    ROUND(SUM(order_profit_per_order), 0)               AS total_profit,
    ROUND(SUM(sales) * 1.0 / COUNT(DISTINCT customer_id), 0) AS avg_sales_per_customer
FROM orders
GROUP BY customer_segment
ORDER BY total_sales DESC;

-- Q9. Does discounting actually help or hurt profit margin?
-- Buckets orders into discount-rate bands and compares average profit ratio.
SELECT
    CASE
        WHEN order_item_discount_rate = 0 THEN '0% (no discount)'
        WHEN order_item_discount_rate <= 0.10 THEN '1-10%'
        WHEN order_item_discount_rate <= 0.20 THEN '11-20%'
        ELSE '21%+'
    END                                                  AS discount_band,
    COUNT(*)                                            AS line_items,
    ROUND(AVG(order_item_profit_ratio) * 100, 2)        AS avg_profit_ratio_pct
FROM orders
GROUP BY discount_band
ORDER BY discount_band;

-- Q10. Top 10 regions by sales and profit (territory-level view, ASM-relevant)
SELECT
    order_region,
    ROUND(SUM(sales), 0)                                AS total_sales,
    ROUND(SUM(order_profit_per_order), 0)               AS total_profit,
    COUNT(DISTINCT order_id)                            AS orders
FROM orders
GROUP BY order_region
ORDER BY total_sales DESC
LIMIT 10;
