# etl_load_bronze.py
# Load CSV files into bronze_* tables (raw ingestion)
import pandas as pd
import urllib.parse
from sqlalchemy import create_engine
import os

# === CONFIG - change these ===
DB_USER = "root"
DB_PASS = urllib.parse.quote_plus("Your_Password")
DB_HOST = "localhost"
DB_PORT = 3306
DB_NAME = "healthcare_dw"
DATA_DIR = "../Data"   # folder where patients.csv, doctors.csv, visits.csv, diagnosis.csv live
# =============================

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}",
    pool_recycle=3600,
    echo=False
)


def load_csv_to_bronze(filename, table_name):
    path = os.path.join(DATA_DIR, filename)
    print(f"Loading {path} -> bronze table {table_name}")
    df = pd.read_csv(path, dtype=str)  # read everything as str to preserve raw
    # ensure no automatic index column
    df.to_sql(table_name, con=engine, schema=None, if_exists='append', index=False, chunksize=1000)
    print(f"Loaded {len(df)} rows into {table_name}")

if __name__ == "__main__":
    load_csv_to_bronze("patients.csv", "bronze_patients")
    load_csv_to_bronze("doctors.csv", "bronze_doctors")
    load_csv_to_bronze("visits.csv", "bronze_visits")
    load_csv_to_bronze("diagnosis.csv", "bronze_diagnosis")
    print("Bronze load complete.")

