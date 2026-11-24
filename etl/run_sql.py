"""Jalankan file .sql statement demi statement, berurutan, dalam SATU koneksi.

Pemakaian (dari root repo, venv aktif):
    python etl/run_sql.py sql/03_clean_tables.sql
"""
import sys
import time
from pathlib import Path

import sqlparse

from db import get_engine


def main(path: str) -> None:
    raw = Path(path).read_text(encoding="utf-8")
    # Pecah per statement, buang komentar, abaikan statement kosong
    statements = []
    for stmt in sqlparse.split(raw):
        cleaned = sqlparse.format(stmt, strip_comments=True).strip()
        if cleaned:
            statements.append(cleaned)

    engine = get_engine()
    with engine.connect() as conn:
        try:
            conn.exec_driver_sql("SET SESSION lock_wait_timeout = 60")
        except Exception:
            conn.rollback()

        for n, stmt in enumerate(statements, 1):
            label = stmt.splitlines()[0][:70]
            start = time.perf_counter()
            result = conn.exec_driver_sql(stmt, execution_options={"no_parameters": True})
            conn.commit()
            rows = result.rowcount if result.rowcount is not None and result.rowcount >= 0 else "-"
            print(f"[{n:>2}/{len(statements)}] {time.perf_counter() - start:6.1f}s  rows={rows}  {label}")

    print("Selesai.")


if __name__ == "__main__":
    main(sys.argv[1])