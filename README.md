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
- **Geolocation is pre-aggregated** to one row per zip prefix at load time (~1M source rows) to fit the 1 GB free-tier disk.
- **DATETIME, not TIMESTAMP**, to keep Brazil local times without timezone conversion.

## How to Reproduce
1. Clone the repo, create a virtual environment, and run `pip install -r requirements.txt` (or open it in GitHub Codespaces).
2. Set `KAGGLE_API_TOKEN` as an environment variable (or a Codespaces secret).
3. TBD