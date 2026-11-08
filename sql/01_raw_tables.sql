DROP TABLE IF EXISTS
  olist_raw.orders, olist_raw.customers, olist_raw.order_items,
  olist_raw.order_payments, olist_raw.order_reviews, olist_raw.products,
  olist_raw.sellers, olist_raw.category_translation, olist_raw.geolocation_zip;

-- 1 baris = 1 pesanan
CREATE TABLE olist_raw.orders (
  raw_id                        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id                      CHAR(32),
  customer_id                   CHAR(32),
  order_status                  VARCHAR(16),
  order_purchase_timestamp      DATETIME,
  order_approved_at             DATETIME,
  order_delivered_carrier_date  DATETIME,
  order_delivered_customer_date DATETIME,
  order_estimated_delivery_date DATETIME,
  loaded_at                     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (raw_id)
) ENGINE = InnoDB COMMENT = 'olist_orders_dataset.csv';

-- 1 baris = 1 pelanggan per pesanan
CREATE TABLE olist_raw.customers (
  raw_id                   BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id              CHAR(32),
  customer_unique_id       CHAR(32),
  customer_zip_code_prefix CHAR(5),
  customer_city            VARCHAR(64),
  customer_state           CHAR(2),
  loaded_at                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (raw_id)
) ENGINE = InnoDB COMMENT = 'olist_customers_dataset.csv';

-- 1 baris = 1 barang di dalam pesanan
CREATE TABLE olist_raw.order_items (
  raw_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id            CHAR(32),
  order_item_id       SMALLINT,
  product_id          CHAR(32),
  seller_id           CHAR(32),
  shipping_limit_date DATETIME,
  price               DECIMAL(10,2),
  freight_value       DECIMAL(10,2),
  loaded_at           DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (raw_id)
) ENGINE = InnoDB COMMENT = 'olist_order_items_dataset.csv';

-- 1 baris = 1 transaksi pembayaran
CREATE TABLE olist_raw.order_payments (
  raw_id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id             CHAR(32),
  payment_sequential   SMALLINT,
  payment_type         VARCHAR(20),
  payment_installments SMALLINT,
  payment_value        DECIMAL(10,2),
  loaded_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (raw_id)
) ENGINE = InnoDB COMMENT = 'olist_order_payments_dataset.csv';

-- 1 baris = 1 ulasan untuk 1 pesanan
CREATE TABLE olist_raw.order_reviews (
  raw_id                  BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  review_id               CHAR(32),
  order_id                CHAR(32),
  review_score            TINYINT,
  review_comment_title    VARCHAR(255),
  review_comment_message  TEXT,
  review_creation_date    DATETIME,
  review_answer_timestamp DATETIME,
  loaded_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (raw_id)
) ENGINE = InnoDB COMMENT = 'olist_order_reviews_dataset.csv';

-- 1 baris = 1 produk 
CREATE TABLE olist_raw.products (
  raw_id                     BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id                 CHAR(32),
  product_category_name      VARCHAR(64),
  product_name_lenght        SMALLINT,
  product_description_lenght INT,
  product_photos_qty         SMALLINT,
  product_weight_g           INT,
  product_length_cm          SMALLINT,
  product_height_cm          SMALLINT,
  product_width_cm           SMALLINT,
  loaded_at                  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (raw_id)
) ENGINE = InnoDB COMMENT = 'olist_products_dataset.csv';

-- 1 baris = 1 penjual
CREATE TABLE olist_raw.sellers (
  raw_id                 BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  seller_id              CHAR(32),
  seller_zip_code_prefix CHAR(5),
  seller_city            VARCHAR(64),
  seller_state           CHAR(2),
  loaded_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (raw_id)
) ENGINE = InnoDB COMMENT = 'olist_sellers_dataset.csv';

-- 1 baris = 1 kategori (Portugis -> Inggris)
CREATE TABLE olist_raw.category_translation (
  raw_id                        BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_category_name         VARCHAR(64),
  product_category_name_english VARCHAR(64),
  loaded_at                     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (raw_id)
) ENGINE = InnoDB COMMENT = 'product_category_name_translation.csv';

-- 1 baris = 1 prefix kode pos 
CREATE TABLE olist_raw.geolocation_zip (
  geolocation_zip_code_prefix CHAR(5)      NOT NULL,
  geolocation_lat             DECIMAL(9,6),
  geolocation_lng             DECIMAL(9,6),
  geolocation_city            VARCHAR(64),
  geolocation_state           CHAR(2),
  n_points                    INT COMMENT 'jumlah titik asli yang dirata-rata',
  loaded_at                   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (geolocation_zip_code_prefix)
) ENGINE = InnoDB COMMENT = 'olist_geolocation_dataset.csv (agregat per prefix)';