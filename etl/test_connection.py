from sqlalchemy import text

from db import get_engine

engine = get_engine()

with engine.connect() as conn:
    version = conn.execute(text("SELECT VERSION()")).scalar()
    user = conn.execute(text("SELECT CURRENT_USER()")).scalar()
    cipher = conn.execute(text("SHOW SESSION STATUS LIKE 'Ssl_cipher'")).fetchone()

print(f"MySQL version : {version}")
print(f"Logged in as  : {user}")
print(f"SSL cipher    : {cipher[1] or 'KOSONG - koneksi tidak terenkripsi!'}")