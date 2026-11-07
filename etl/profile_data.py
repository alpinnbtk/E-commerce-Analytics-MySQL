from pathlib import Path

import pandas as pd

RAW_DIR = Path("data/raw")
OUT = Path("docs/profile_summary.md")

KEYS = {
    "olist_orders_dataset.csv": ["order_id"],
    "olist_customers_dataset.csv": ["customer_id"],
    "olist_order_items_dataset.csv": ["order_id", "order_item_id"],
    "olist_order_payments_dataset.csv": ["order_id", "payment_sequential"],
    "olist_order_reviews_dataset.csv": ["review_id"],
    "olist_products_dataset.csv": ["product_id"],
    "olist_sellers_dataset.csv": ["seller_id"],
    "product_category_name_translation.csv": ["product_category_name"],
    "olist_geolocation_dataset.csv": ["geolocation_zip_code_prefix"],
}


def clean(value: object, limit: int = 30) -> str:
    """Rapikan contoh nilai agar aman ditaruh di tabel markdown."""
    text = str(value).replace("|", "\\|").replace("\n", " ").replace("\r", " ")
    return text[:limit]


lines = ["# Profil data Olist", "", "Dibuat otomatis oleh `etl/profile_data.py`.", ""]

for csv in sorted(RAW_DIR.glob("*.csv")):
    df = pd.read_csv(csv, dtype=str, encoding="utf-8-sig")

    keys = KEYS.get(csv.name, [])
    if keys:
        n_dup = int(df.duplicated(subset=keys).sum())
        key_status = "UNIK" if n_dup == 0 else f"TIDAK UNIK ({n_dup:,} baris duplikat)"
    else:
        key_status = "-"

    lines += [
        f"## {csv.name}",
        "",
        f"- Baris: {len(df):,}",
        f"- Kolom: {df.shape[1]}",
        f"- Kandidat kunci `{', '.join(keys)}`: {key_status}",
        "",
        "| Kolom | Null | % Null | Nilai unik | Contoh |",
        "| --- | --- | --- | --- | --- |",
    ]
    for col in df.columns:
        s = df[col]
        n_null = int(s.isna().sum())
        example = clean(s.dropna().iloc[0]) if s.notna().any() else ""
        lines.append(
            f"| {col} | {n_null:,} | {n_null / len(df):.1%} | {s.nunique():,} | {example} |"
        )
    lines.append("")
    print(f"{csv.name:45s} {len(df):>10,} baris  kunci: {key_status}")

OUT.write_text("\n".join(lines), encoding="utf-8")
print(f"\nRingkasan ditulis ke {OUT}")