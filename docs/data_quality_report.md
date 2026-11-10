# Data Quality Report: olist_raw

Dihasilkan dari `sql/02_data_quality_checks.sql` (view `olist_raw.v_dq_scorecard`).
Tanggal pemeriksaan: 10 November 2026

Severity: **Blocker** = metrik salah bila tidak ditangani · **Major** = mengganggu sebagian analisis/label · **Minor** = dampak sangat kecil · **Info** = perilaku bisnis wajar · **Lolos** = tidak ada temuan.

| # | Dimensi | Pemeriksaan | Hasil | Severity | Keputusan di layer clean |
| --- | --- | --- | --- | --- | --- |
| 1 | Completeness | Status delivered tanpa tanggal terima | 8 | Major | Tetap di metrik penjualan; dikeluarkan dari metrik pengiriman |
| 2 | Completeness | Produk tanpa kategori | 610 | Major | Kategori diisi `unknown` |
| 3 | Uniqueness | review_id dipakai >1 baris | 814 | Blocker | Ulasan diringkas 1 baris per order sebelum di-join |
| 4 | Uniqueness | Order dengan >1 ulasan | 547 | Blocker | Sama dengan #3: ambil ulasan terbaru per order |
| 5 | Integrity | Produk dengan kategori tanpa terjemahan | 13 | Minor | Tambah terjemahan manual untuk 2 kategori |
| 6 | Integrity | Order tanpa item | 775 | Info | 767 berstatus unavailable/canceled (wajar). Dipertahankan untuk analisis status/pembatalan; otomatis tidak masuk GMV karena GMV dari order_items |
| 7 | Integrity | Order tanpa pembayaran | 1 | Minor | Dipertahankan; dikecualikan dari analisis metode bayar |
| 8 | Integrity | Customer tanpa koordinat | 279 | Minor | Koordinat NULL; dikecualikan dari peta |
| 9 | Validity | Cicilan bernilai 0 | 2 | Minor | Diubah menjadi 1 (bayar penuh = 1 kali cicilan) |
| 10 | Validity | payment_type not_defined | 3 | Minor | Dipertahankan; ditampilkan sebagai "other" di grafik metode bayar |
| 11 | Validity | Berat produk 0 gram | 4 | Minor | Diubah menjadi NULL (berat 0 tidak mungkin) |
| 12 | Consistency | Diterima sebelum dibeli | 0 | Lolos | Tidak perlu tindakan; dipantau lewat scorecard |
| 13 | Consistency | Ke kurir sebelum approve | 1.359 | Info | Dipertahankan; bukan dasar metrik utama |
| 14 | Consistency | Total bayar ≠ total item (> 1 BRL) | 249 dari 98.665 order (0,25%); selisih −51,62 s.d. +182,81 BRL | Info | GMV dihitung dari order_items (harga + ongkir) |
| 15 | Outlier | Harga di atas batas IQR (277,40 BRL) | 8.427 item (7,5%) | Info | Tidak dibuang; harga tipikal memakai median |
| 16 | Consistency | Diterima sebelum diserahkan ke kurir | 23 | Minor | Dipertahankan; metrik pengiriman memakai tanggal beli → tanggal terima, bukan tanggal kurir |
| 17 | Validity | Nilai pembayaran = 0 | 9 | Info | Dipertahankan (kemungkinan voucher); tidak memengaruhi GMV |

## Catatan tambahan
- Order tanpa item per status: unavailable 603, canceled 164, created 5, invoiced 2, shipped 1. Lima status terakhir (8 order) janggal tapi jumlahnya sangat kecil.
- Ulasan tanpa judul 88,3% dan tanpa pesan 58,7% → analisis teks ulasan hanya mewakili sebagian kecil pelanggan.
- Distribusi harga miring ke kanan: median 74,99 BRL vs rata-rata 120,65 BRL; maksimum 6.735 BRL.
- Ongkir gratis pada 383 item; ongkir lebih mahal dari harga barang pada 4.124 item (umum untuk barang murah).
- Pelanggan tersebar di 27 negara bagian, sedangkan penjual hanya di 23.
- Tidak ditemukan duplikat pada order_id, (order_id, order_item_id), customer_id, product_id, seller_id, maupun rujukan yatim di order_items, orders, dan order_payments.