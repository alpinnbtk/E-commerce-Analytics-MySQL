# E-Commerce Performance & Customer Analytics

End-to-end analytics project: MySQL data pipeline (raw → clean → mart) and an interactive Google Data Studio dashboard.

> Status: work in progress

## Business Questions
TBD

## Dashboard
TBD: link + screenshots

## Data
Brazilian E-Commerce Public Dataset by Olist (Kaggle): ~100k orders, 2016–2018, 9 relational tables.

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

## How to Reproduce
1. Clone the repo, create a virtual environment, and run `pip install -r requirements.txt` (or open it in GitHub Codespaces).
2. Set `KAGGLE_API_TOKEN` as an environment variable (or a Codespaces secret).
3. TBD