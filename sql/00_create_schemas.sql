CREATE DATABASE IF NOT EXISTS olist_raw
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;   -- data apa adanya

CREATE DATABASE IF NOT EXISTS olist_clean
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;   -- data bersih + star schema

CREATE DATABASE IF NOT EXISTS olist_mart
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;   -- tabel agregat untuk dashboard

SHOW DATABASES LIKE 'olist%';