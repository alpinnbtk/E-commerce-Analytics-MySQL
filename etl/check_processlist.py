"""Tampilkan (dan opsional hentikan) koneksi avnadmin yang masih aktif.

python etl/check_processlist.py          # lihat saja
python etl/check_processlist.py --kill   # hentikan semua koneksi avnadmin lain
"""
import sys

from sqlalchemy import text

from db import get_engine

KILL = "--kill" in sys.argv

with get_engine().connect() as conn:
    my_id = conn.execute(text("SELECT CONNECTION_ID()")).scalar()
    rows = conn.execute(text("SHOW FULL PROCESSLIST")).fetchall()

    print(f"Total koneksi: {len(rows)}")
    for r in rows:
        info = (r.Info or "")[:70].replace("\n", " ")
        print(f"id={r.Id:<8} {r.Command:<8} {r.Time:>6}s  {r.State or '-':32s}  {info}")

    if KILL:
        targets = [r.Id for r in rows if r.User == "avnadmin" and r.Id != my_id]
        for pid in targets:
            conn.execute(text(f"KILL {int(pid)}"))
        print(f"Dihentikan: {len(targets)} koneksi")