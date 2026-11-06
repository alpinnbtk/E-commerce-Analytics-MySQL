import os

from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL, Engine

load_dotenv()  


def get_engine(database: str | None = None) -> Engine:
    """Buat SQLAlchemy engine dengan koneksi SSL ke Aiven."""
    url = URL.create(
        drivername="mysql+pymysql",
        username=os.environ["MYSQL_USER"],
        password=os.environ["MYSQL_PASSWORD"],  
        host=os.environ["MYSQL_HOST"],
        port=int(os.environ["MYSQL_PORT"]),
        database=database or os.environ["MYSQL_DATABASE"],
    )
    return create_engine(
        url,
        connect_args={"ssl": {"ca": os.environ["MYSQL_SSL_CA"]}},
        pool_pre_ping=True, 
    )