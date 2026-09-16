-- ============================================================
-- Schema: orders (DataCo Supply Chain, cleaned)
-- Loaded via python/etl_pipeline.py into data/supply_chain.db
-- Grain: one row per order line item (order_item_id)
-- ============================================================
-- Run with: sqlite3 data/supply_chain.db < sql/01_schema.sql
-- (informational — the table already exists after running the ETL script;
--  this file documents the structure for reviewers.)

-- Key columns used across the business queries in 02_business_queries.sql:
--   order_id, order_item_id        -> order / line item identifiers
--   order_date, shipping_date       -> parsed datetime columns
--   order_month                     -> YYYY-MM, for trend analysis
--   days_for_shipping_real,
--   days_for_shipment_scheduled,
--   shipping_delay_days             -> actual - scheduled shipping days
--   late_delivery_risk               -> 1 = late, 0 = on time (source-provided flag)
--   delivery_status                 -> Late delivery / Advance shipping / Shipping on time / Shipping canceled
--   shipping_mode                   -> Standard/Second/First Class, Same Day
--   order_region, order_country,
--   market                          -> geography
--   category_name, product_name     -> product hierarchy
--   customer_id, customer_segment   -> customer (PII columns removed in ETL)
--   sales, order_item_total,
--   order_profit_per_order,
--   order_item_profit_ratio,
--   order_item_discount_rate        -> financials
--   order_status                    -> COMPLETE / CANCELED / SUSPECTED_FRAUD / etc.

CREATE INDEX IF NOT EXISTS idx_order_region  ON orders(order_region);
CREATE INDEX IF NOT EXISTS idx_shipping_mode ON orders(shipping_mode);
CREATE INDEX IF NOT EXISTS idx_order_month   ON orders(order_month);
CREATE INDEX IF NOT EXISTS idx_customer_id   ON orders(customer_id);
