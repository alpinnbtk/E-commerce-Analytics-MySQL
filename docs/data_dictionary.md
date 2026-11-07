# Data Dictionary: Olist Brazilian E-Commerce

Sumber: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle).
Periode: 4 September 2016 – 17 Oktober 2018 (`order_purchase_timestamp`).

Kolom **Tipe** adalah rencana tipe MySQL untuk layer raw/clean. Jumlah baris berasal dari `docs/profile_summary.md`.

## Ringkasan tabel

| Tabel | Grain (1 baris =) | Kunci | Baris |
| --- | --- | --- | --- |
| orders | 1 pesanan | `order_id` | 99.441 |
| customers | 1 pelanggan per pesanan | `customer_id` | 99.441 |
| order_items | 1 barang di dalam pesanan | `order_id` + `order_item_id` | 112.650 |
| order_payments | 1 transaksi pembayaran | `order_id` + `payment_sequential` | 103.886 |
| order_reviews | 1 ulasan untuk 1 pesanan | `review_id` + `order_id` | 99.224 |
| products | 1 produk | `product_id` | 32.951 |
| sellers | 1 penjual | `seller_id` | 3.095 |
| category_translation | 1 kategori produk | `product_category_name` | 71 |
| geolocation | 1 titik koordinat (banyak titik per prefix kode pos) | Tidak ada | 1.000.163 |

## orders

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| order_id | CHAR(32) | ID unik pesanan | Unik, tanpa null |
| customer_id | CHAR(32) | ID pelanggan untuk pesanan ini; terhubung ke `customers` | Satu `customer_id` per pesanan |
| order_status | VARCHAR(16) | Status terakhir pesanan (delivered, shipped, canceled, dll.) | Lihat daftar nilai unik |
| order_purchase_timestamp | DATETIME | Waktu pelanggan membuat pesanan | Dasar semua analisis waktu |
| order_approved_at | DATETIME | Waktu pembayaran disetujui | 160 null |
| order_delivered_carrier_date | DATETIME | Waktu paket diserahkan ke kurir | 1.783 null |
| order_delivered_customer_date | DATETIME | Waktu paket diterima pelanggan | 2.965 null; 8 di antaranya berstatus `delivered` |
| order_estimated_delivery_date | DATETIME | Estimasi tanggal tiba yang dijanjikan ke pelanggan | Pembanding untuk metrik on-time |

## customers

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| customer_id | CHAR(32) | ID pelanggan khusus untuk satu pesanan; kunci penghubung ke `orders` | Dibuat baru di setiap pesanan, jadi **tidak** mewakili orang |
| customer_unique_id | CHAR(32) | ID unik orang/pelanggan sebenarnya | Dipakai untuk repeat rate, cohort, RFM |
| customer_zip_code_prefix | CHAR(5) | 5 digit pertama kode pos pelanggan | Baca sebagai teks; nol di depan harus dipertahankan |
| customer_city | VARCHAR(64) | Kota pelanggan | Huruf kecil, tanpa standardisasi aksen |
| customer_state | CHAR(2) | Kode negara bagian (mis. SP, RJ) | 27 negara bagian Brasil |

## order_items

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| order_id | CHAR(32) | ID pesanan; terhubung ke `orders` | Satu pesanan bisa punya banyak baris |
| order_item_id | SMALLINT | Nomor urut barang di dalam pesanan (1, 2, 3, …) | Bersama `order_id` menjadi kunci |
| product_id | CHAR(32) | ID produk; terhubung ke `products` | |
| seller_id | CHAR(32) | ID penjual; terhubung ke `sellers` | Satu pesanan bisa melibatkan beberapa penjual |
| shipping_limit_date | DATETIME | Batas waktu penjual menyerahkan barang ke mitra logistik | |
| price | DECIMAL(10,2) | Harga barang (BRL) | Per barang, bukan per pesanan |
| freight_value | DECIMAL(10,2) | Ongkos kirim barang (BRL) | Ongkir pesanan dibagi ke setiap barang |

## order_payments

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| order_id | CHAR(32) | ID pesanan; terhubung ke `orders` | Satu pesanan bisa punya beberapa pembayaran |
| payment_sequential | SMALLINT | Urutan pembayaran bila pelanggan memakai lebih dari satu metode | Bersama `order_id` menjadi kunci |
| payment_type | VARCHAR(20) | Metode bayar: credit_card, boleto, voucher, debit_card, not_defined | Cek baris `not_defined` |
| payment_installments | SMALLINT | Jumlah cicilan yang dipilih | Cek nilai 0 |
| payment_value | DECIMAL(10,2) | Nominal pembayaran (BRL) | Jangan di-join langsung dengan `order_items` saat menghitung GMV (risiko dobel hitung) |

## order_reviews

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| review_id | CHAR(32) | ID ulasan | Tidak unik: 814 duplikat (1 ulasan bisa untuk >1 pesanan) |
| order_id | CHAR(32) | ID pesanan yang diulas; terhubung ke `orders` | Satu pesanan bisa punya >1 ulasan; ringkas per pesanan sebelum join |
| review_score | TINYINT | Skor kepuasan 1–5 | |
| review_comment_title | VARCHAR(255) | Judul komentar (bahasa Portugis) | Sebagian besar null |
| review_comment_message | TEXT | Isi komentar (bahasa Portugis) | Banyak null |
| review_creation_date | DATETIME | Tanggal survei kepuasan dikirim ke pelanggan | |
| review_answer_timestamp | DATETIME | Waktu pelanggan menjawab survei | |

## products

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| product_id | CHAR(32) | ID unik produk | |
| product_category_name | VARCHAR(64) | Nama kategori (bahasa Portugis); terhubung ke `category_translation` | 610 null; 2 kategori tanpa terjemahan |
| product_name_lenght | SMALLINT | Jumlah karakter nama produk | Salah eja dari sumber; null di 610 produk yang sama |
| product_description_lenght | INT | Jumlah karakter deskripsi produk | Salah eja dari sumber; null di 610 produk yang sama |
| product_photos_qty | SMALLINT | Jumlah foto produk yang dipublikasikan | Null di 610 produk yang sama |
| product_weight_g | INT | Berat produk (gram) | Cek null dan nilai 0 |
| product_length_cm | SMALLINT | Panjang produk (cm) | |
| product_height_cm | SMALLINT | Tinggi produk (cm) | |
| product_width_cm | SMALLINT | Lebar produk (cm) | |

## sellers

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| seller_id | CHAR(32) | ID unik penjual | |
| seller_zip_code_prefix | CHAR(5) | 5 digit pertama kode pos penjual | Baca sebagai teks |
| seller_city | VARCHAR(64) | Kota penjual | Penulisan tidak seragam |
| seller_state | CHAR(2) | Kode negara bagian penjual | |

## category_translation

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| product_category_name | VARCHAR(64) | Nama kategori dalam bahasa Portugis | Header file mengandung BOM; baca dengan `utf-8-sig` |
| product_category_name_english | VARCHAR(64) | Nama kategori dalam bahasa Inggris | Dipakai sebagai label di dashboard |

## geolocation

| Kolom | Tipe | Deskripsi | Catatan kualitas data |
| --- | --- | --- | --- |
| geolocation_zip_code_prefix | CHAR(5) | 5 digit pertama kode pos | Tidak unik: banyak titik per prefix |
| geolocation_lat | DECIMAL(9,6) | Garis lintang | Cek titik di luar wilayah Brasil |
| geolocation_lng | DECIMAL(9,6) | Garis bujur | Cek titik di luar wilayah Brasil |
| geolocation_city | VARCHAR(64) | Nama kota | Aksen tidak konsisten (mis. "sao paulo" vs "são paulo") |
| geolocation_state | CHAR(2) | Kode negara bagian | |

Rencana: diagregasi menjadi tabel `geolocation_zip` (1 baris per prefix, koordinat rata-rata) sebelum di-join ke `customers` dan `sellers`.

## NOTE

1. **Kunci tidak unik.**
   - `olist_geolocation_dataset`: 1.000.163 baris, 981.148 duplikat pada `geolocation_zip_code_prefix` → banyak titik koordinat per prefix. Harus diagregasi menjadi 1 baris per prefix sebelum di-join, agar baris pelanggan/penjual tidak terduplikasi.
   - `olist_order_reviews_dataset`: 814 duplikat pada `review_id` → satu ulasan bisa terhubung ke beberapa pesanan. Kunci kandidat: `review_id` + `order_id` (isi: unik / tidak). Ulasan diringkas per `order_id` sebelum di-join ke `orders`.
2. **Null pada tanggal pesanan.** `order_approved_at` 160, `order_delivered_carrier_date` 1.783, `order_delivered_customer_date` 2.965. Sebagian besar wajar (status canceled, shipped, unavailable, dsb.). Temuan: **8 order berstatus `delivered` tanpa `order_delivered_customer_date`** → tetap dihitung di metrik penjualan, dikeluarkan dari metrik pengiriman.
3. **Produk tanpa kategori.** 610 produk tidak punya `product_category_name`; kolom nama, deskripsi, dan jumlah foto juga kosong di produk yang sama. Rencana: kategori diisi `unknown` di layer clean.
4. **Kategori tanpa terjemahan.** `pc_gamer` dan `portateis_cozinha_e_preparadores_de_alimentos` tidak ada di tabel terjemahan ((isi) produk terdampak). Rencana: tambahkan terjemahan manual di layer clean.
5. **Periode data.** `order_purchase_timestamp` dari 4 September 2016 sampai 17 Oktober 2018.
6. **Salah eja kolom sumber.** `product_name_lenght`, `product_description_lenght` → diganti menjadi `_length` di layer clean; nama asli dipertahankan di layer raw.