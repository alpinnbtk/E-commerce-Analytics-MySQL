DROP TABLE IF EXISTS
  olist_clean.order_reviews, olist_clean.order_payments, olist_clean.order_items,
  olist_clean.orders, olist_clean.products, olist_clean.category_translation,
  olist_clean.customers, olist_clean.sellers, olist_clean.geolocation_zip;

-- ---------- category_translation ----------
-- DQ #5: 2 kategori tanpa terjemahan; DQ #2: kategori 'unknown'
CREATE TABLE olist_clean.category_translation (
  product_category_name         VARCHAR(64) NOT NULL,
  product_category_name_english VARCHAR(64) NOT NULL,
  translation_source            VARCHAR(10) NOT NULL COMMENT 'olist / manual',
  PRIMARY KEY (product_category_name)
) ENGINE = InnoDB;

INSERT INTO olist_clean.category_translation
  (product_category_name, product_category_name_english, translation_source)
SELECT TRIM(product_category_name), TRIM(product_category_name_english), 'olist'
FROM olist_raw.category_translation;

INSERT INTO olist_clean.category_translation
  (product_category_name, product_category_name_english, translation_source)
VALUES
  ('pc_gamer', 'pc_gamer', 'manual'),
  ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_food_preparers', 'manual'),
  ('unknown', 'unknown', 'manual');

-- ---------- products ----------
CREATE TABLE olist_clean.products (
  product_id                    CHAR(32)    NOT NULL,
  product_category_name         VARCHAR(64) NOT NULL,
  product_category_name_english VARCHAR(64) NOT NULL,
  product_name_length           SMALLINT,
  product_description_length    INT,
  product_photos_qty            SMALLINT,
  product_weight_g              INT          COMMENT '0 diubah menjadi NULL (DQ #11)',
  product_length_cm             SMALLINT,
  product_height_cm             SMALLINT,
  product_width_cm              SMALLINT,
  product_volume_cm3            INT          COMMENT 'panjang x tinggi x lebar',
  PRIMARY KEY (product_id),
  KEY idx_products_category_en (product_category_name_english)
) ENGINE = InnoDB;

INSERT INTO olist_clean.products
SELECT p.product_id,
       COALESCE(NULLIF(TRIM(p.product_category_name), ''), 'unknown'),  -- DQ #2
       t.product_category_name_english,
       p.product_name_lenght,          
       p.product_description_lenght,
       p.product_photos_qty,
       NULLIF(p.product_weight_g, 0),  -- DQ #11
       p.product_length_cm,
       p.product_height_cm,
       p.product_width_cm,
       p.product_length_cm * p.product_height_cm * p.product_width_cm
FROM olist_raw.products AS p
LEFT JOIN olist_clean.category_translation AS t
  ON t.product_category_name = COALESCE(NULLIF(TRIM(p.product_category_name), ''), 'unknown');

-- ---------- customers ----------
CREATE TABLE olist_clean.customers (
  customer_id              CHAR(32)    NOT NULL,
  customer_unique_id       CHAR(32)    NOT NULL,
  customer_zip_code_prefix CHAR(5)     NOT NULL,
  customer_city            VARCHAR(64) NOT NULL,
  customer_state           CHAR(2)     NOT NULL,
  PRIMARY KEY (customer_id),
  KEY idx_customers_unique_id (customer_unique_id),
  KEY idx_customers_zip (customer_zip_code_prefix)
) ENGINE = InnoDB;

INSERT INTO olist_clean.customers
SELECT customer_id,
       customer_unique_id,
       LPAD(TRIM(customer_zip_code_prefix), 5, '0'),
       LOWER(TRIM(customer_city)),
       UPPER(TRIM(customer_state))
FROM olist_raw.customers;

-- ---------- sellers ----------
CREATE TABLE olist_clean.sellers (
  seller_id              CHAR(32)    NOT NULL,
  seller_zip_code_prefix CHAR(5)     NOT NULL,
  seller_city            VARCHAR(64) NOT NULL,
  seller_state           CHAR(2)     NOT NULL,
  PRIMARY KEY (seller_id),
  KEY idx_sellers_zip (seller_zip_code_prefix)
) ENGINE = InnoDB;

INSERT INTO olist_clean.sellers
SELECT seller_id,
       LPAD(TRIM(seller_zip_code_prefix), 5, '0'),
       LOWER(TRIM(seller_city)),
       UPPER(TRIM(seller_state))
FROM olist_raw.sellers;

-- ---------- geolocation_zip ----------
CREATE TABLE olist_clean.geolocation_zip (
  zip_code_prefix CHAR(5)      NOT NULL,
  lat             DECIMAL(9,6) NOT NULL,
  lng             DECIMAL(9,6) NOT NULL,
  city            VARCHAR(64),
  state           CHAR(2),
  n_points        INT,
  PRIMARY KEY (zip_code_prefix)
) ENGINE = InnoDB;

INSERT INTO olist_clean.geolocation_zip
SELECT LPAD(TRIM(geolocation_zip_code_prefix), 5, '0'),
       geolocation_lat,
       geolocation_lng,
       LOWER(TRIM(geolocation_city)),
       UPPER(TRIM(geolocation_state)),
       n_points
FROM olist_raw.geolocation_zip;

-- ---------- orders ----------
CREATE TABLE olist_clean.orders (
  order_id                      CHAR(32)     NOT NULL,
  customer_id                   CHAR(32)     NOT NULL,
  order_status                  VARCHAR(16)  NOT NULL,
  order_purchase_timestamp      DATETIME     NOT NULL,
  order_approved_at             DATETIME,
  order_delivered_carrier_date  DATETIME,
  order_delivered_customer_date DATETIME,
  order_estimated_delivery_date DATETIME     NOT NULL,
  -- kolom turunan
  purchase_date                 DATE         NOT NULL,
  purchase_month                DATE         NOT NULL COMMENT 'tanggal 1 di bulan pembelian',
  is_valid_order                TINYINT(1)   NOT NULL COMMENT 'punya item & bukan canceled/unavailable',
  is_delivery_measurable        TINYINT(1)   NOT NULL COMMENT 'delivered & punya tanggal terima',
  delivery_days                 DECIMAL(6,2)          COMMENT 'jam beli->terima / 24',
  delay_days                    INT                   COMMENT 'tgl terima - tgl estimasi; positif = terlambat',
  is_late                       TINYINT(1)            COMMENT '1 terlambat, 0 tepat waktu, NULL tak terukur',
  PRIMARY KEY (order_id),
  KEY idx_orders_customer_id (customer_id),
  KEY idx_orders_purchase_month (purchase_month)
) ENGINE = InnoDB;

INSERT INTO olist_clean.orders
SELECT
  b.order_id,
  b.customer_id,
  LOWER(TRIM(b.order_status)),
  b.order_purchase_timestamp,
  b.order_approved_at,
  b.order_delivered_carrier_date,
  b.order_delivered_customer_date,
  b.order_estimated_delivery_date,
  DATE(b.order_purchase_timestamp),
  DATE_FORMAT(b.order_purchase_timestamp, '%Y-%m-01'),
  -- metric_definitions: order valid
  (b.order_status NOT IN ('canceled', 'unavailable')
   AND EXISTS (SELECT 1 FROM olist_raw.order_items AS i WHERE i.order_id = b.order_id)),
  b.measurable,
  CASE WHEN b.measurable
       THEN ROUND(TIMESTAMPDIFF(HOUR, b.order_purchase_timestamp,
                                b.order_delivered_customer_date) / 24, 2)
  END,
  CASE WHEN b.measurable
       THEN DATEDIFF(b.order_delivered_customer_date, b.order_estimated_delivery_date)
  END,
  CASE WHEN b.measurable
       THEN DATE(b.order_delivered_customer_date) > DATE(b.order_estimated_delivery_date)
  END
FROM (
  SELECT o.*,
         -- DQ #1: metrik pengiriman hanya untuk order delivered yang bertanggal
         (o.order_status = 'delivered'
          AND o.order_delivered_customer_date IS NOT NULL) AS measurable
  FROM olist_raw.orders AS o
) AS b;

-- ---------- order_items ----------
CREATE TABLE olist_clean.order_items (
  order_id            CHAR(32)      NOT NULL,
  order_item_id       SMALLINT      NOT NULL,
  product_id          CHAR(32)      NOT NULL,
  seller_id           CHAR(32)      NOT NULL,
  shipping_limit_date DATETIME      NOT NULL,
  price               DECIMAL(10,2) NOT NULL,
  freight_value       DECIMAL(10,2) NOT NULL,
  item_value          DECIMAL(10,2) NOT NULL COMMENT 'price + freight_value (dasar GMV)',
  PRIMARY KEY (order_id, order_item_id),
  KEY idx_items_product_id (product_id),
  KEY idx_items_seller_id (seller_id)
) ENGINE = InnoDB;

INSERT INTO olist_clean.order_items
SELECT order_id, order_item_id, product_id, seller_id, shipping_limit_date,
       price, freight_value, price + freight_value
FROM olist_raw.order_items;

-- ---------- order_payments ----------
CREATE TABLE olist_clean.order_payments (
  order_id             CHAR(32)      NOT NULL,
  payment_sequential   SMALLINT      NOT NULL,
  payment_type         VARCHAR(20)   NOT NULL,
  payment_installments SMALLINT      NOT NULL COMMENT '0 diubah menjadi 1 (DQ #9)',
  payment_value        DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, payment_sequential)
) ENGINE = InnoDB;

INSERT INTO olist_clean.order_payments
SELECT order_id,
       payment_sequential,
       LOWER(TRIM(payment_type)),
       CASE WHEN payment_installments = 0 THEN 1 ELSE payment_installments END,  -- DQ #9
       payment_value
FROM olist_raw.order_payments;

-- ---------- order_reviews (1 baris per order) ----------
-- DQ #3-4: ambil ulasan yang dijawab paling akhir untuk setiap order
CREATE TABLE olist_clean.order_reviews (
  order_id                CHAR(32)   NOT NULL,
  review_id               CHAR(32)   NOT NULL,
  review_score            TINYINT    NOT NULL,
  has_comment             TINYINT(1) NOT NULL COMMENT 'ada judul atau pesan',
  review_creation_date    DATETIME,
  review_answer_timestamp DATETIME,
  n_reviews_raw           SMALLINT   NOT NULL COMMENT 'jumlah ulasan asli untuk order ini',
  PRIMARY KEY (order_id)
) ENGINE = InnoDB;

INSERT INTO olist_clean.order_reviews
SELECT order_id, review_id, review_score, has_comment,
       review_creation_date, review_answer_timestamp, n_reviews
FROM (
  SELECT b.*,
         ROW_NUMBER() OVER (
           PARTITION BY b.order_id
           ORDER BY b.review_answer_timestamp DESC,
                    b.review_creation_date   DESC,
                    b.review_id              DESC
         ) AS rn,
         COUNT(*) OVER (PARTITION BY b.order_id) AS n_reviews
  FROM (
    -- Kolom TEXT diringkas jadi 1 flag di sini, supaya tidak ikut diurutkan
    SELECT order_id,
           review_id,
           review_score,
           (review_comment_title IS NOT NULL
            OR review_comment_message IS NOT NULL) AS has_comment,
           review_creation_date,
           review_answer_timestamp
    FROM olist_raw.order_reviews
  ) AS b
) AS ranked
WHERE rn = 1;