SELECT
  SUM(order_approved_at IS NULL)             AS null_approved,
  SUM(order_delivered_carrier_date IS NULL)  AS null_carrier,
  SUM(order_delivered_customer_date IS NULL) AS null_delivered
FROM olist_raw.orders;

-- 1. Tanggal pembelian paling awal dan akhir
SELECT MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)
FROM olist_raw.orders;

-- 2. Jumlah order berstatus delivered yang order_delivered_customer_date-nya null
SELECT COUNT(*) AS jumlah_order
FROM olist_raw.orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL;

-- 3. Jumlah produk tanpa product_category_name
SELECT COUNT(*) AS jumlah_produk
FROM olist_raw.products
WHERE product_category_name IS NULL;

-- 4. Jumlah baris di order_reviews dikurangi jumlah review_id unik
SELECT (COUNT(*) - COUNT(DISTINCT review_id)) AS jumlah_baris
FROM olist_raw.order_reviews;

-- 5. Kategori di products yang tidak ada di category_translation
SELECT DISTINCT p.product_category_name
FROM olist_raw.products p LEFT JOIN olist_raw.category_translation ct ON p.product_category_name = ct.product_category_name
WHERE ct.product_category_name IS NULL;

-- A) Panjang prefix kode pos
SELECT CHAR_LENGTH(customer_zip_code_prefix) AS panjang, COUNT(*) AS jumlah
FROM olist_raw.customers
GROUP BY panjang;

-- B) Pemakaian kuota disk
SELECT table_schema,
       ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS ukuran_mb
FROM information_schema.tables
WHERE table_schema LIKE 'olist%'
GROUP BY table_schema;
