""" Pemakaian (dari root repo, venv aktif):
    python etl/load_raw.py                  # semua tabel
    python etl/load_raw.py orders products  # tabel tertentu saja
"""
import sys
import time
from pathlib import Path

import pandas as pd
from sqlalchemy import text

from db import get_engine

RAW_DIR = Path("data/raw")
SCHEMA = "olist_raw"
CHUNK = 2_000                     # baris per INSERT
DT_FORMAT = "%Y-%m-%d %H:%M:%S"   # format waktu di semua CSV Olist

# Kotak batas wilayah daratan Brasil (derajat)
BRAZIL_LAT = (-33.75, 5.27)
BRAZIL_LNG = (-73.99, -34.79)

# nama tabel MySQL -> file sumber + kolom yang perlu dikonversi
TABLES = {
    "orders": {
        "file": "olist_orders_dataset.csv",
        "datetime": [
            "order_purchase_timestamp", "order_approved_at",
            "order_delivered_carrier_date", "order_delivered_customer_date",
            "order_estimated_delivery_date",
        ],
    },
    "customers": {"file": "olist_customers_dataset.csv"},
    "order_items": {
        "file": "olist_order_items_dataset.csv",
        "datetime": ["shipping_limit_date"],
        "int": ["order_item_id"],
    },
    "order_payments": {
        "file": "olist_order_payments_dataset.csv",
        "int": ["payment_sequential", "payment_installments"],
    },
    "order_reviews": {
        "file": "olist_order_reviews_dataset.csv",
        "datetime": ["review_creation_date", "review_answer_timestamp"],
        "int": ["review_score"],
    },
    "products": {
        "file": "olist_products_dataset.csv",
        "int": [
            "product_name_lenght", "product_description_lenght", "product_photos_qty",
            "product_weight_g", "product_length_cm", "product_height_cm", "product_width_cm",
        ],
    },
    "sellers": {"file": "olist_sellers_dataset.csv"},
    "category_translation": {"file": "product_category_name_translation.csv"},
}


def read_source(cfg: dict) -> pd.DataFrame:
    """Baca CSV sebagai teks, lalu konversi kolom waktu dan integer."""
    df = pd.read_csv(RAW_DIR / cfg["file"], dtype=str, encoding="utf-8-sig")
    for col in cfg.get("datetime", []):
        df[col] = pd.to_datetime(df[col], format=DT_FORMAT)  # gagal keras jika format beda
    for col in cfg.get("int", []):
        df[col] = pd.to_numeric(df[col]).astype("Int64")     # "4.0" -> 4, NaN -> <NA>
    return df


def most_common(s: pd.Series) -> str:
    """Nilai yang paling sering muncul dalam satu grup."""
    return s.mode().iat[0]


def build_geolocation_zip() -> pd.DataFrame:
    """Buang titik di luar Brasil, lalu rata-ratakan koordinat per prefix kode pos."""
    geo = pd.read_csv(RAW_DIR / "olist_geolocation_dataset.csv", dtype=str)
    geo["geolocation_lat"] = pd.to_numeric(geo["geolocation_lat"])
    geo["geolocation_lng"] = pd.to_numeric(geo["geolocation_lng"])

    inside = (geo["geolocation_lat"].between(*BRAZIL_LAT)
              & geo["geolocation_lng"].between(*BRAZIL_LNG))
    print(f"    titik di luar Brasil dibuang: {(~inside).sum():,} dari {len(geo):,}")
    geo = geo[inside]

    agg = (
        geo.groupby("geolocation_zip_code_prefix")
        .agg(
            geolocation_lat=("geolocation_lat", "mean"),
            geolocation_lng=("geolocation_lng", "mean"),
            geolocation_city=("geolocation_city", most_common),
            geolocation_state=("geolocation_state", most_common),
            n_points=("geolocation_lat", "size"),
        )
        .reset_index()
    )
    coords = ["geolocation_lat", "geolocation_lng"]
    agg[coords] = agg[coords].round(6)  # sesuai DECIMAL(9,6)
    return agg


def load(engine, table: str, df: pd.DataFrame) -> None:
    """Kosongkan tabel, lalu insert bertahap per CHUNK baris."""
    with engine.begin() as conn:
        conn.execute(text(f"TRUNCATE TABLE {SCHEMA}.{table}"))
    df.to_sql(table, engine, schema=SCHEMA, if_exists="append", index=False,
              chunksize=CHUNK, method="multi")


def count_rows(engine, table: str) -> int:
    with engine.connect() as conn:
        return conn.execute(text(f"SELECT COUNT(*) FROM {SCHEMA}.{table}")).scalar()


def main(selected: list[str]) -> None:
    all_tables = list(TABLES) + ["geolocation_zip"]
    targets = selected or all_tables
    unknown = set(targets) - set(all_tables)
    if unknown:
        sys.exit(f"Tabel tidak dikenal: {', '.join(sorted(unknown))}")

    engine = get_engine()
    report = []
    for table in targets:
        start = time.perf_counter()
        print(f"[{table}] membaca & memuat...")
        if table == "geolocation_zip":
            df = build_geolocation_zip()
        else:
            df = read_source(TABLES[table])
        load(engine, table, df)
        n_db = count_rows(engine, table)
        report.append((table, len(df), n_db, "OK" if n_db == len(df) else "BEDA!"))
        print(f"    {len(df):,} baris dalam {time.perf_counter() - start:.1f} detik")

    print("\nRingkasan verifikasi")
    print(f"{'tabel':22s} {'sumber':>10s} {'mysql':>10s}  status")
    for table, n_src, n_db, status in report:
        print(f"{table:22s} {n_src:>10,} {n_db:>10,}  {status}")


if __name__ == "__main__":
    main(sys.argv[1:])