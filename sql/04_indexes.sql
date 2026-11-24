ALTER TABLE olist_raw.orders
  ADD INDEX idx_orders_order_id    (order_id),
  ADD INDEX idx_orders_customer_id (customer_id),
  ADD INDEX idx_orders_purchase_ts (order_purchase_timestamp);

ALTER TABLE olist_raw.order_items
  ADD INDEX idx_items_order_id   (order_id, order_item_id),
  ADD INDEX idx_items_product_id (product_id),
  ADD INDEX idx_items_seller_id  (seller_id);

ALTER TABLE olist_raw.order_payments
  ADD INDEX idx_payments_order_id (order_id);

ALTER TABLE olist_raw.order_reviews
  ADD INDEX idx_reviews_order_id  (order_id),
  ADD INDEX idx_reviews_review_id (review_id);

ALTER TABLE olist_raw.customers
  ADD INDEX idx_customers_customer_id (customer_id),
  ADD INDEX idx_customers_unique_id   (customer_unique_id),
  ADD INDEX idx_customers_zip         (customer_zip_code_prefix);

ALTER TABLE olist_raw.products
  ADD INDEX idx_products_product_id (product_id),
  ADD INDEX idx_products_category   (product_category_name);

ALTER TABLE olist_raw.sellers
  ADD INDEX idx_sellers_seller_id (seller_id),
  ADD INDEX idx_sellers_zip       (seller_zip_code_prefix);

ALTER TABLE olist_raw.category_translation
  ADD INDEX idx_category_name (product_category_name);

-- Perbarui statistik agar optimizer tahu index baru
ANALYZE TABLE olist_raw.orders, olist_raw.order_items, olist_raw.order_payments,
              olist_raw.order_reviews, olist_raw.customers, olist_raw.products,
              olist_raw.sellers, olist_raw.category_translation;

-- Daftar semua index di olist_raw
SELECT table_name,
       index_name,
       GROUP_CONCAT(column_name ORDER BY seq_in_index) AS kolom,
       non_unique
FROM information_schema.statistics
WHERE table_schema = 'olist_raw'
GROUP BY table_name, index_name, non_unique
ORDER BY table_name, index_name;