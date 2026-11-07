# Profil data Olist

Dibuat otomatis oleh `etl/profile_data.py`.

## olist_customers_dataset.csv

- Baris: 99,441
- Kolom: 5
- Kandidat kunci `customer_id`: UNIK

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| customer_id | 0 | 0.0% | 99,441 | 06b8999e2fba1a1fbc88172c00ba8b |
| customer_unique_id | 0 | 0.0% | 96,096 | 861eff4711a542e4b93843c6dd7feb |
| customer_zip_code_prefix | 0 | 0.0% | 14,994 | 14409 |
| customer_city | 0 | 0.0% | 4,119 | franca |
| customer_state | 0 | 0.0% | 27 | SP |

## olist_geolocation_dataset.csv

- Baris: 1,000,163
- Kolom: 5
- Kandidat kunci `geolocation_zip_code_prefix`: TIDAK UNIK (981,148 baris duplikat)

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| geolocation_zip_code_prefix | 0 | 0.0% | 19,015 | 01037 |
| geolocation_lat | 0 | 0.0% | 717,372 | -23.54562128115268 |
| geolocation_lng | 0 | 0.0% | 717,615 | -46.63929204800168 |
| geolocation_city | 0 | 0.0% | 8,011 | sao paulo |
| geolocation_state | 0 | 0.0% | 27 | SP |

## olist_order_items_dataset.csv

- Baris: 112,650
- Kolom: 7
- Kandidat kunci `order_id, order_item_id`: UNIK

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| order_id | 0 | 0.0% | 98,666 | 00010242fe8c5a6d1ba2dd792cb162 |
| order_item_id | 0 | 0.0% | 21 | 1 |
| product_id | 0 | 0.0% | 32,951 | 4244733e06e7ecb4970a6e2683c13e |
| seller_id | 0 | 0.0% | 3,095 | 48436dade18ac8b2bce089ec2a0412 |
| shipping_limit_date | 0 | 0.0% | 93,318 | 2017-09-19 09:45:35 |
| price | 0 | 0.0% | 5,968 | 58.90 |
| freight_value | 0 | 0.0% | 6,999 | 13.29 |

## olist_order_payments_dataset.csv

- Baris: 103,886
- Kolom: 5
- Kandidat kunci `order_id, payment_sequential`: UNIK

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| order_id | 0 | 0.0% | 99,440 | b81ef226f3fe1789b1e8b2acac839d |
| payment_sequential | 0 | 0.0% | 29 | 1 |
| payment_type | 0 | 0.0% | 5 | credit_card |
| payment_installments | 0 | 0.0% | 24 | 8 |
| payment_value | 0 | 0.0% | 29,077 | 99.33 |

## olist_order_reviews_dataset.csv

- Baris: 99,224
- Kolom: 7
- Kandidat kunci `review_id`: TIDAK UNIK (814 baris duplikat)

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| review_id | 0 | 0.0% | 98,410 | 7bc2406110b926393aa56f80a40eba |
| order_id | 0 | 0.0% | 98,673 | 73fc7af87114b39712e6da79b0a377 |
| review_score | 0 | 0.0% | 5 | 4 |
| review_comment_title | 87,656 | 88.3% | 4,527 | recomendo |
| review_comment_message | 58,247 | 58.7% | 36,159 | Recebi bem antes do prazo esti |
| review_creation_date | 0 | 0.0% | 636 | 2018-01-18 00:00:00 |
| review_answer_timestamp | 0 | 0.0% | 98,248 | 2018-01-18 21:46:59 |

## olist_orders_dataset.csv

- Baris: 99,441
- Kolom: 8
- Kandidat kunci `order_id`: UNIK

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| order_id | 0 | 0.0% | 99,441 | e481f51cbdc54678b7cc49136f2d6a |
| customer_id | 0 | 0.0% | 99,441 | 9ef432eb6251297304e76186b10a92 |
| order_status | 0 | 0.0% | 8 | delivered |
| order_purchase_timestamp | 0 | 0.0% | 98,875 | 2017-10-02 10:56:33 |
| order_approved_at | 160 | 0.2% | 90,733 | 2017-10-02 11:07:15 |
| order_delivered_carrier_date | 1,783 | 1.8% | 81,018 | 2017-10-04 19:55:00 |
| order_delivered_customer_date | 2,965 | 3.0% | 95,664 | 2017-10-10 21:25:13 |
| order_estimated_delivery_date | 0 | 0.0% | 459 | 2017-10-18 00:00:00 |

## olist_products_dataset.csv

- Baris: 32,951
- Kolom: 9
- Kandidat kunci `product_id`: UNIK

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| product_id | 0 | 0.0% | 32,951 | 1e9e8ef04dbcff4541ed26657ea517 |
| product_category_name | 610 | 1.9% | 73 | perfumaria |
| product_name_lenght | 610 | 1.9% | 66 | 40 |
| product_description_lenght | 610 | 1.9% | 2,960 | 287 |
| product_photos_qty | 610 | 1.9% | 19 | 1 |
| product_weight_g | 2 | 0.0% | 2,204 | 225 |
| product_length_cm | 2 | 0.0% | 99 | 16 |
| product_height_cm | 2 | 0.0% | 102 | 10 |
| product_width_cm | 2 | 0.0% | 95 | 14 |

## olist_sellers_dataset.csv

- Baris: 3,095
- Kolom: 4
- Kandidat kunci `seller_id`: UNIK

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| seller_id | 0 | 0.0% | 3,095 | 3442f8959a84dea7ee197c632cb2df |
| seller_zip_code_prefix | 0 | 0.0% | 2,246 | 13023 |
| seller_city | 0 | 0.0% | 611 | campinas |
| seller_state | 0 | 0.0% | 23 | SP |

## product_category_name_translation.csv

- Baris: 71
- Kolom: 2
- Kandidat kunci `product_category_name`: UNIK

| Kolom | Null | % Null | Nilai unik | Contoh |
| --- | --- | --- | --- | --- |
| product_category_name | 0 | 0.0% | 71 | beleza_saude |
| product_category_name_english | 0 | 0.0% | 71 | health_beauty |
