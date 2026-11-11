# E-Commerce Performance & Customer Analytics

End-to-end analytics project: MySQL data pipeline (raw → clean → mart) and an interactive Google Data Studio dashboard.

> Status: work in progress

## Business Questions
TBD

## Dashboard
TBD: link + screenshots

## Data
Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (see Kaggle page for license).

## Architecture
Kaggle CSV → Python ETL → MySQL 8 on Aiven (raw → clean → mart) → Google Data Studio

## Tech Stack
MySQL 8 · Python (pandas, SQLAlchemy) · Google Data Studio · VS Code / GitHub Codespaces

## Repository Structure
- `etl/` – download and load scripts
- `sql/` – numbered SQL scripts, run in order
- `docs/` – data dictionary, metric definitions, screenshots

## Key Insights & Recommendations
TBD

## Design Decisions
- **Raw layer keeps data as delivered.** Surrogate `raw_id` primary keys, no foreign keys, nullable columns, so duplicates and orphans can be detected later instead of being rejected at load.
- **Geolocation is pre-aggregated** to one row per zip prefix (mean lat/lng, most frequent city/state). Points outside Brazil's bounding box (42 points) are dropped before averaging.
- **DATETIME, not TIMESTAMP**, to keep Brazil local times without timezone conversion.

## How to Reproduce
1. Copy `.env.example` to `.env` and fill in your MySQL credentials; put the server CA certificate at `certs/ca.pem`.
2. Run `sql/00_create_schemas.sql` and `sql/01_raw_tables.sql`.
3. python `etl/download_data.py` then python `etl/load_raw.py`.
4. Run `sql/04_indexes.sql` (after loading, so the bulk insert stays fast).
5. Run `sql/02_data_quality_checks.sql` to create the data-quality scorecard view.