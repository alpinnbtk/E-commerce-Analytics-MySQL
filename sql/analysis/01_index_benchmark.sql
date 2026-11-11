SELECT order_id
FROM olist_raw.orders
ORDER BY order_purchase_timestamp DESC
LIMIT 1;

-- Q1 tanpa index
EXPLAIN ANALYZE
SELECT * FROM olist_raw.order_items IGNORE INDEX (idx_items_order_id)
WHERE order_id = '10a045cdf6a5650c21e9cfeb60384c16';

-- Q2 tanpa index
EXPLAIN ANALYZE
SELECT COUNT(DISTINCT o.order_id)     AS jumlah_order,
       SUM(i.price + i.freight_value) AS gmv
FROM olist_raw.orders AS o IGNORE INDEX (idx_orders_purchase_ts, idx_orders_order_id)
JOIN olist_raw.order_items AS i IGNORE INDEX (idx_items_order_id)
  ON i.order_id = o.order_id
WHERE o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp <  '2018-02-01';

-- Q3 tanpa index
EXPLAIN ANALYZE
SELECT COUNT(*)
FROM olist_raw.orders AS o
WHERE NOT EXISTS (
  SELECT 1 FROM olist_raw.order_payments AS p IGNORE INDEX (idx_payments_order_id)
  WHERE p.order_id = o.order_id
);

-- Q1. LOOKUP: semua item dari satu order
EXPLAIN 
SELECT * FROM olist_raw.order_items WHERE order_id = '10a045cdf6a5650c21e9cfeb60384c16';

EXPLAIN ANALYZE 
SELECT * FROM olist_raw.order_items WHERE order_id = '10a045cdf6a5650c21e9cfeb60384c16';

-- Q2. JOIN + FILTER: jumlah order & GMV Januari 2018
EXPLAIN ANALYZE 
SELECT COUNT(DISTINCT o.order_id)       AS jumlah_order,
       SUM(i.price + i.freight_value)   AS gmv
FROM olist_raw.orders AS o
JOIN olist_raw.order_items AS i ON i.order_id = o.order_id
WHERE o.order_purchase_timestamp >= '2018-01-01'
  AND o.order_purchase_timestamp <  '2018-02-01';

-- Q3. ANTI-JOIN (dari scorecard): order tanpa pembayaran
EXPLAIN ANALYZE 
SELECT COUNT(*)
FROM olist_raw.orders AS o
WHERE NOT EXISTS (
  SELECT 1 FROM olist_raw.order_payments AS p WHERE p.order_id = o.order_id
);

-- Ukuran database 
SELECT table_schema, 
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS ukuran_mb
FROM information_schema.tables
WHERE table_schema = 'olist_raw'
GROUP BY table_schema;
