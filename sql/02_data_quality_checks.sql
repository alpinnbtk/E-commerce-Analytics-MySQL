-- ---------- A. COMPLETENESS ----------

-- A1. Null per kolom di orders
SELECT COUNT(*)                                   AS total,
       SUM(order_id IS NULL)                      AS null_order_id,
       SUM(customer_id IS NULL)                   AS null_customer_id,
       SUM(order_purchase_timestamp IS NULL)      AS null_purchase,
       SUM(order_approved_at IS NULL)             AS null_approved, -- 160
       SUM(order_delivered_carrier_date IS NULL)  AS null_carrier, -- 1783
       SUM(order_delivered_customer_date IS NULL) AS null_delivered, -- 2965
       SUM(order_estimated_delivery_date IS NULL) AS null_estimated
FROM olist_raw.orders;

-- A2. Null per kolom di products
SELECT COUNT(*)                            AS total,
       SUM(product_category_name IS NULL)  AS null_kategori, -- 610
       SUM(product_photos_qty IS NULL)     AS null_foto, -- 610
       SUM(product_weight_g IS NULL)       AS null_berat, -- 2
       SUM(product_length_cm IS NULL)      AS null_panjang -- 2
FROM olist_raw.products;

-- A3. Seberapa sering pelanggan menulis komentar?
SELECT COUNT(*)                                          AS total_ulasan,
       ROUND(AVG(review_comment_title IS NULL) * 100, 1)   AS pct_tanpa_judul, -- 88.3
       ROUND(AVG(review_comment_message IS NULL) * 100, 1) AS pct_tanpa_pesan -- 58.7
FROM olist_raw.order_reviews;

-- ---------- B. UNIQUENESS ----------

-- B1. order_id ganda di orders (harapan: 0 baris)
SELECT order_id, COUNT(*) AS n
FROM olist_raw.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- B2. Kunci gabungan order_items (harapan: 0 baris)
SELECT order_id, order_item_id, COUNT(*) AS n
FROM olist_raw.order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- B3. review_id yang dipakai lebih dari 1 order (10 terbanyak)
SELECT review_id, COUNT(*) AS n_order -- hasilnya 3 semua
FROM olist_raw.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY n_order DESC
LIMIT 10;

-- B4. Order yang punya lebih dari 1 ulasan
SELECT COUNT(*) AS order_dengan_ulasan_ganda -- 547
FROM (
  SELECT order_id
  FROM olist_raw.order_reviews
  GROUP BY order_id
  HAVING COUNT(*) > 1
) AS x;

-- B5. cek duplikat untuk data-data lain
SELECT customer_id, COUNT(*)
FROM olist_raw.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

SELECT product_id, COUNT(*)
FROM olist_raw.products
GROUP BY product_id
HAVING COUNT(*) > 1;

SELECT seller_id, COUNT(*)
FROM olist_raw.sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;

-- ---------- C. INTEGRITY ----------

-- C1. Item yang order_id-nya tidak ada di orders (rujukan yatim)
SELECT COUNT(*) AS item_yatim -- 0
FROM olist_raw.order_items AS i
LEFT JOIN olist_raw.orders AS o ON o.order_id = i.order_id
WHERE o.order_id IS NULL;

-- C2. Item yang product_id / seller_id-nya tidak ada
SELECT SUM(p.product_id IS NULL) AS produk_tidak_ada, -- 0
       SUM(s.seller_id IS NULL)  AS seller_tidak_ada -- 0
FROM olist_raw.order_items AS i
LEFT JOIN olist_raw.products AS p ON p.product_id = i.product_id
LEFT JOIN olist_raw.sellers  AS s ON s.seller_id  = i.seller_id;

-- C3. Order yang customer_id-nya tidak ada di customers
SELECT COUNT(*) AS order_tanpa_customer -- 0
FROM olist_raw.orders AS o
LEFT JOIN olist_raw.customers AS c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- C4. Order tanpa item, dipecah per status (induk tanpa anak)
SELECT o.order_status, COUNT(*) AS order_tanpa_item              -- unavailable = 603
FROM olist_raw.orders AS o                                       -- canceled = 164
LEFT JOIN olist_raw.order_items AS i ON i.order_id = o.order_id  -- created = 5
WHERE i.order_id IS NULL                                         -- invoiced = 2
GROUP BY o.order_status                                          -- shipped = 1
ORDER BY order_tanpa_item DESC;

-- C5. Order tanpa pembayaran
SELECT o.order_id, o.order_status
FROM olist_raw.orders AS o
WHERE NOT EXISTS (
  SELECT 1 FROM olist_raw.order_payments AS p WHERE p.order_id = o.order_id
);

-- C6. Kode pos pelanggan yang tidak punya koordinat
SELECT COUNT(*) AS customer_tanpa_koordinat -- 279
FROM olist_raw.customers AS c
LEFT JOIN olist_raw.geolocation_zip AS g
  ON g.geolocation_zip_code_prefix = c.customer_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;

-- ---------- D. VALIDITY ----------

-- D1. Distribusi status order (daftar nilai yang ada)
SELECT order_status, COUNT(*) AS n
FROM olist_raw.orders
GROUP BY order_status
ORDER BY n DESC;

-- D2. Metode pembayaran
SELECT payment_type, COUNT(*) AS n
FROM olist_raw.order_payments
GROUP BY payment_type
ORDER BY n DESC;

-- D3. Nilai pembayaran & cicilan yang janggal
SELECT SUM(payment_installments = 0) AS cicilan_nol, -- 2
       SUM(payment_value = 0)        AS bayar_nol, -- 9
       SUM(payment_value < 0)        AS bayar_negatif
FROM olist_raw.order_payments;

-- D4. Harga & ongkir yang janggal
SELECT SUM(price <= 0)                AS harga_nol_atau_negatif,
       SUM(freight_value = 0)         AS ongkir_gratis, -- 383
       SUM(freight_value > price)     AS ongkir_lebih_mahal_dari_barang -- 4124
FROM olist_raw.order_items;

-- D5. Dimensi fisik produk yang tidak mungkin
SELECT SUM(product_weight_g = 0)   AS berat_nol, -- 4
       SUM(product_length_cm = 0
           OR product_height_cm = 0
           OR product_width_cm = 0) AS dimensi_nol -- 0
FROM olist_raw.products;

-- D6. Jumlah negara bagian (Brasil punya 27)
SELECT COUNT(DISTINCT customer_state) AS state_customer, -- 27
       (SELECT COUNT(DISTINCT seller_state) FROM olist_raw.sellers) AS state_seller -- 23
FROM olist_raw.customers;

-- ---------- E. CONSISTENCY ----------

-- E1. Urutan waktu yang tidak logis
SELECT
  SUM(order_approved_at             < order_purchase_timestamp)     AS approve_sebelum_beli, -- 0
  SUM(order_delivered_carrier_date  < order_approved_at)            AS ke_kurir_sebelum_approve, -- 1359
  SUM(order_delivered_customer_date < order_delivered_carrier_date) AS diterima_sebelum_ke_kurir, -- 23
  SUM(order_delivered_customer_date < order_purchase_timestamp)     AS diterima_sebelum_beli, -- 0
  SUM(order_estimated_delivery_date < order_purchase_timestamp)     AS estimasi_sebelum_beli -- 0
FROM olist_raw.orders;

-- E2. Status vs tanggal terima
SELECT order_status,
       SUM(order_delivered_customer_date IS NULL)     AS tanpa_tgl_terima,
       SUM(order_delivered_customer_date IS NOT NULL) AS dengan_tgl_terima
FROM olist_raw.orders
GROUP BY order_status;

-- E3. Total pembayaran vs total item per order
WITH item_total AS (
  SELECT order_id, SUM(price + freight_value) AS total_item
  FROM olist_raw.order_items
  GROUP BY order_id
),
pay_total AS (
  SELECT order_id, SUM(payment_value) AS total_bayar
  FROM olist_raw.order_payments
  GROUP BY order_id
)
SELECT COUNT(*)                                       AS order_dibandingkan, -- 98665
       SUM(ABS(p.total_bayar - i.total_item) > 1)     AS selisih_lebih_dari_1_brl, -- 249
       ROUND(MAX(p.total_bayar - i.total_item), 2)    AS lebih_bayar_terbesar, -- 182.81
       ROUND(MIN(p.total_bayar - i.total_item), 2)    AS kurang_bayar_terbesar -- -51.62
FROM item_total AS i
JOIN pay_total  AS p ON p.order_id = i.order_id;

-- ---------- F. OUTLIER ----------

-- F1. Ringkasan distribusi harga
WITH ranked AS (
  SELECT price,
         PERCENT_RANK() OVER (ORDER BY price) AS pr
  FROM olist_raw.order_items
)
SELECT MIN(price)                              AS minimum, -- 0.85
       MAX(CASE WHEN pr <= 0.25 THEN price END) AS q1, -- 39.90
       MAX(CASE WHEN pr <= 0.50 THEN price END) AS median, -- 74.99
       MAX(CASE WHEN pr <= 0.75 THEN price END) AS q3, -- 134.90
       MAX(CASE WHEN pr <= 0.99 THEN price END) AS p99, -- 890.00
       MAX(price)                              AS maksimum, -- 6735.00
       ROUND(AVG(price), 2)                    AS rata_rata -- 120.65
FROM ranked;

-- F2. Berapa item di atas batas IQR (Q3 + 1,5 x IQR)?
WITH ranked AS (
  SELECT price, PERCENT_RANK() OVER (ORDER BY price) AS pr
  FROM olist_raw.order_items
),
quartiles AS (
  SELECT MAX(CASE WHEN pr <= 0.25 THEN price END) AS q1,
         MAX(CASE WHEN pr <= 0.75 THEN price END) AS q3
  FROM ranked
)
SELECT q.q1, -- 39.90
       q.q3, -- 134.90
       q.q3 + 1.5 * (q.q3 - q.q1)                          AS batas_atas, -- 277.400
       SUM(i.price > q.q3 + 1.5 * (q.q3 - q.q1))           AS item_di_atas_batas, -- 8427
       ROUND(AVG(i.price > q.q3 + 1.5 * (q.q3 - q.q1)) * 100, 1) AS pct_di_atas_batas -- 7.5
FROM olist_raw.order_items AS i
CROSS JOIN quartiles AS q
GROUP BY q.q1, q.q3;

-- F3. 10 item termahal: masuk akal atau salah input?
SELECT i.price, i.freight_value, p.product_category_name, p.product_weight_g
FROM olist_raw.order_items AS i
LEFT JOIN olist_raw.products AS p ON p.product_id = i.product_id
ORDER BY i.price DESC
LIMIT 10;

-- ---------- G. SCORECARD ----------
-- Satu baris per pemeriksaan. jumlah_temuan = 0 berarti lolos.

CREATE OR REPLACE VIEW olist_raw.v_dq_scorecard AS

SELECT 'completeness' AS dimensi, 'orders' AS tabel,
       'status delivered tanpa tanggal terima' AS pemeriksaan,
       COUNT(*) AS jumlah_temuan
FROM olist_raw.orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL

UNION ALL
SELECT 'completeness', 'products', 'produk tanpa kategori', COUNT(*)
FROM olist_raw.products
WHERE product_category_name IS NULL

UNION ALL
SELECT 'uniqueness', 'orders', 'order_id ganda',
       COUNT(*) - COUNT(DISTINCT order_id)
FROM olist_raw.orders

UNION ALL
SELECT 'uniqueness', 'order_reviews', 'review_id dipakai lebih dari 1 baris',
       COUNT(*) - COUNT(DISTINCT review_id)
FROM olist_raw.order_reviews

UNION ALL
SELECT 'integrity', 'order_items', 'item dengan order_id yatim', COUNT(*)
FROM olist_raw.order_items AS i
LEFT JOIN olist_raw.orders AS o ON o.order_id = i.order_id
WHERE o.order_id IS NULL

UNION ALL
SELECT 'integrity', 'orders', 'order tanpa item', COUNT(*)
FROM olist_raw.orders AS o
WHERE NOT EXISTS (SELECT 1 FROM olist_raw.order_items AS i WHERE i.order_id = o.order_id)

UNION ALL
SELECT 'integrity', 'orders', 'order tanpa pembayaran', COUNT(*)
FROM olist_raw.orders AS o
WHERE NOT EXISTS (SELECT 1 FROM olist_raw.order_payments AS p WHERE p.order_id = o.order_id)

UNION ALL
SELECT 'integrity', 'products', 'produk dengan kategori tanpa terjemahan', COUNT(*)
FROM olist_raw.products AS p
LEFT JOIN olist_raw.category_translation AS t
  ON t.product_category_name = p.product_category_name
WHERE p.product_category_name IS NOT NULL
  AND t.product_category_name IS NULL

UNION ALL
SELECT 'integrity', 'customers', 'customer tanpa koordinat', COUNT(*)
FROM olist_raw.customers AS c
LEFT JOIN olist_raw.geolocation_zip AS g
  ON g.geolocation_zip_code_prefix = c.customer_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL

UNION ALL
SELECT 'validity', 'order_payments', 'cicilan bernilai 0', COUNT(*)
FROM olist_raw.order_payments
WHERE payment_installments = 0

UNION ALL
SELECT 'validity', 'order_payments', 'payment_type not_defined', COUNT(*)
FROM olist_raw.order_payments
WHERE payment_type = 'not_defined'

UNION ALL
SELECT 'validity', 'products', 'berat produk 0 gram', COUNT(*)
FROM olist_raw.products
WHERE product_weight_g = 0

UNION ALL
SELECT 'consistency', 'orders', 'diterima sebelum dibeli', COUNT(*)
FROM olist_raw.orders
WHERE order_delivered_customer_date < order_purchase_timestamp

UNION ALL
SELECT 'consistency', 'orders', 'diserahkan ke kurir sebelum approve', COUNT(*)
FROM olist_raw.orders
WHERE order_delivered_carrier_date < order_approved_at

UNION ALL
SELECT 'integrity', 'order_payments', 'pembayaran dengan order_id yatim', COUNT(*)
FROM olist_raw.order_payments AS p
LEFT JOIN olist_raw.orders AS o ON o.order_id = p.order_id
WHERE o.order_id IS NULL

UNION ALL
SELECT 'uniqueness', 'products', 'product_id ganda',
       COUNT(*) - COUNT(DISTINCT product_id)
FROM olist_raw.products

UNION ALL
SELECT 'validity', 'order_reviews', 'skor di luar 1-5', COUNT(*)
FROM olist_raw.order_reviews
WHERE review_score NOT BETWEEN 1 AND 5
   OR review_score IS NULL
;

-- Lihat hasilnya
SELECT *
FROM olist_raw.v_dq_scorecard
ORDER BY FIELD(dimensi, 'completeness', 'uniqueness', 'integrity', 'validity', 'consistency'),
         jumlah_temuan DESC;