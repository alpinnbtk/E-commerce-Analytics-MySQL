# Performance Notes

Pengujian index pada `olist_raw` (MySQL 8 di Aiven Free: 1 CPU, 1 GB RAM).
Waktu = `actual time` total dari `EXPLAIN ANALYZE`. Kondisi "sebelum" diukur dengan index hint `IGNORE INDEX`, tanpa menghapus index.

| Query | Pola | Sebelum | Sesudah | Percepatan |
| --- | --- | --- | --- | --- |
| Q1 | Lookup 1 order di order_items | Table scan, 112.650 baris dibaca, **314 ms** | Index lookup `idx_items_order_id`, **0,02 ms** | ±12.800× |
| Q2 | Join + filter 1 bulan (Jan 2018) | Hash join, 2 table scan (112.650 + 99.441 baris), **985 ms** | Index range scan `idx_orders_purchase_ts` + 7.269 index lookup ke order_items, **1.020 ms** | ±1,0× (tidak ada percepatan) |
| Q3 | Anti-join order tanpa pembayaran | Table scan payments + materialisasi subquery, **2.381 ms** | Covering index scan `idx_payments_order_id` + materialisasi, **1.602 ms** | ±1,5× |

Ukuran olist_raw: 72,48 MB sebelum → 140,06 MB sesudah index.

## Pelajaran
- Index paling efektif untuk query yang **sangat selektif**: mencari 1 order turun dari membaca 112 ribu baris menjadi satu lookup langsung.
- Untuk query yang mengambil porsi besar tabel (Q2: ±7% order, lalu ribuan lookup terpisah), hash join tanpa index sudah sama cepatnya. Optimizer memilih rencana berbeda, tapi waktunya hampir sama.
- Query yang memang harus memeriksa semua baris (Q3) hanya terbantu sedikit, karena index membuat pembacaan tabel pembayaran lebih ringan (covering index), bukan menghindari pembacaan.