# Metric Definitions

## Aturan umum

| Aturan | Ketentuan |
| --- | --- |
| Mata uang | BRL (Real Brasil), tanpa konversi |
| Tanggal acuan | `order_purchase_timestamp` (waktu pelanggan membuat pesanan), kecuali disebutkan lain |
| Granularitas waktu | Bulanan (`DATE_FORMAT(order_purchase_timestamp, '%Y-%m')`) |
| **Order valid** | Order yang punya ≥1 baris di `order_items` **dan** `order_status` bukan `canceled` atau `unavailable` |
| Identitas pelanggan | `customer_unique_id` (bukan `customer_id`, yang dibuat baru di setiap pesanan) |
| Ulasan per order | 1 ulasan per order: yang `review_answer_timestamp`-nya paling akhir (lihat DQ report #3–4) |
| Periode analisis | Data mentah: Sep 2016 – Okt 2018. Bulan di awal dan akhir periode kemungkinan sangat sedikit order; periode tren final diputuskan di Day 10 setelah melihat jumlah order per bulan |

## 1. Penjualan

### GMV (Gross Merchandise Value)
- **Definisi:** total nilai barang yang terjual, termasuk ongkos kirim.
- **Rumus:** `SUM(order_items.price + order_items.freight_value)` untuk order valid.
- **Sumber:** `order_items` ⋈ `orders`.
- **Catatan:** dihitung dari `order_items`, **bukan** `order_payments`. Total pembayaran berbeda >1 BRL dari total item pada 249 order (lihat DQ report #14), dan pembayaran bisa memuat bunga cicilan.

### Product Revenue
- **Definisi:** nilai barang tanpa ongkos kirim.
- **Rumus:** `SUM(order_items.price)` untuk order valid.
- **Catatan:** dipakai saat membandingkan kategori, supaya kategori barang berat tidak terlihat besar hanya karena ongkirnya.

### Jumlah Order
- **Rumus:** `COUNT(DISTINCT order_id)` untuk order valid.

### AOV (Average Order Value)
- **Definisi:** rata-rata nilai belanja per order.
- **Rumus:** `GMV / Jumlah Order`.
- **Catatan:** hitung dari total GMV dibagi total order, **bukan** rata-rata dari AOV bulanan.

### Pertumbuhan MoM (Month over Month)
- **Rumus:** `(nilai bulan ini − nilai bulan lalu) / nilai bulan lalu`, memakai `LAG()` per bulan.
- **Catatan:** bulan pertama periode tidak punya pembanding (NULL).

### Items per Order
- **Rumus:** `COUNT(*) dari order_items / COUNT(DISTINCT order_id)` untuk order valid.

## 2. Pelanggan

### Repeat Customer Rate
- **Definisi:** persentase pelanggan yang membuat ≥2 order valid sepanjang periode.
- **Rumus:** `COUNT(customer_unique_id dengan ≥2 order valid) / COUNT(DISTINCT customer_unique_id)`.

### Cohort & Retention
- **Cohort:** bulan order valid pertama setiap `customer_unique_id`.
- **Month index:** selisih bulan antara bulan order dan bulan cohort (`TIMESTAMPDIFF(MONTH, ...)`); bulan cohort = 0.
- **Retention (month index n):** `pelanggan cohort yang order lagi di bulan ke-n / ukuran cohort`.
- **Catatan:** cohort di akhir periode punya pengamatan lebih pendek; jangan dibandingkan langsung dengan cohort awal.

### RFM
- **Tanggal referensi:** 1 hari setelah `order_purchase_timestamp` terakhir di data.
- **Recency (R):** hari sejak order valid terakhir pelanggan sampai tanggal referensi.
- **Frequency (F):** jumlah order valid pelanggan.
- **Monetary (M):** total GMV pelanggan.
- **Skor:** R dan M memakai `NTILE(5)` (5 = terbaik). F memakai aturan tetap (1 order = 1, 2 order = 3, ≥3 order = 5), karena mayoritas besar pelanggan hanya order sekali sehingga `NTILE` tidak bermakna untuk F.
- **Segmen:** ditentukan di Day 11 dari kombinasi skor R, F, M; daftarnya dicatat di sini setelah final.

## 3. Pengiriman & Kepuasan

Semua metrik di bagian ini hanya memakai order berstatus `delivered` yang **punya** `order_delivered_customer_date` (8 order delivered tanpa tanggal terima dikecualikan, lihat DQ report #1).

### Delivery Days
- **Definisi:** lama pesanan sampai ke pelanggan sejak dibeli.
- **Rumus:** `TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_delivered_customer_date) / 24`.
- **Catatan:** laporkan median dan rata-rata.

### Delay vs Estimasi
- **Rumus:** `DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date)`; positif = terlambat, negatif = lebih cepat dari janji.

### On-time Delivery Rate
- **Definisi:** persentase order yang tiba pada atau sebelum tanggal estimasi.
- **Rumus:** `AVG(DATE(order_delivered_customer_date) <= DATE(order_estimated_delivery_date))`.
- **Catatan:** dibandingkan per **tanggal**, karena estimasi hanya berisi tanggal (jam 00:00:00). Membandingkan datetime langsung akan membuat pesanan yang tiba siang hari di tanggal estimasi tercatat terlambat.

### Average Review Score
- **Rumus:** `AVG(review_score)` dari 1 ulasan per order.
- **Catatan:** dibandingkan antara order tepat waktu dan terlambat untuk melihat dampak keterlambatan terhadap kepuasan.

## 4. Produk & Seller

### Top Kategori
- **Rumus:** GMV atau Product Revenue per `product_category_name_english`.
- **Catatan:** 610 produk tanpa kategori masuk ke `unknown`; 2 kategori tanpa terjemahan diterjemahkan manual (lihat DQ report #2, #5).

### Seller Pareto
- **Definisi:** persentase seller yang menghasilkan 80% GMV.
- **Rumus:** urutkan seller berdasarkan GMV menurun, hitung GMV kumulatif dengan `SUM() OVER (ORDER BY gmv DESC)`, lalu cari seller terakhir yang kumulatifnya ≤ 80% total.

### Freight Ratio
- **Definisi:** besar ongkir dibanding harga barang.
- **Rumus:** `SUM(freight_value) / SUM(price)`.
- **Catatan:** dihitung dari total, bukan rata-rata rasio per item (rasio per item menjadi ekstrem pada barang murah; lihat catatan DQ: 4.124 item ongkirnya lebih mahal dari barang).

## 5. Pembayaran

### Payment Mix
- **Rumus:** `SUM(payment_value)` per `payment_type` dibagi total `payment_value`, untuk order valid.
- **Catatan:** `not_defined` ditampilkan sebagai "other".

### Rata-rata Cicilan
- **Rumus:** `AVG(payment_installments)` untuk `payment_type = 'credit_card'`.
- **Catatan:** cicilan bernilai 0 diubah menjadi 1 di layer clean (DQ report #9).

## Changelog

| Tanggal | Perubahan |
| --- | --- |
| 2026-11-10 | Versi awal: aturan order valid, GMV dari order_items, definisi pengiriman hanya untuk order delivered bertanggal |