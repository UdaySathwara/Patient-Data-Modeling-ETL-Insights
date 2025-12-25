# etl_healthcare_to_silver.py
# Full ETL Pipeline: CSV → Clean → Transform → Load to Silver Tables

import pandas as pd
from sqlalchemy import create_engine, text
import numpy as np
import re
from urllib.parse import quote_plus

# =======================
# CONFIGURATION
# =======================
DB_USER = "root"          # MySQL username
DB_PASS = quote_plus("Your_password") # MySQL password
DB_HOST = "localhost"     # MySQL host
DB_PORT = 3306
DB_NAME = "healthcare_dw"

CSV_PATHS = {
    "patients": "../Data/patients.csv",
    "doctors": "../Data/doctors.csv",
    "visits": "../Data/visits.csv",
    "diagnosis": "../Data/diagnosis.csv"
}

engine = create_engine(
    f"mysql+pymysql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}",
    pool_recycle=3600
)

print("="*50)
print("ETL Pipeline: CSV -> Clean -> Transform -> Silver Tables")
print("="*50)

# =======================
# STEP 1: LOAD CSV
# =======================
print("\n[STEP 1] Loading CSV files...")
data = {}
for name, path in CSV_PATHS.items():
    try:
        data[name] = pd.read_csv(path)
        print(f" -> {name}: {len(data[name])} rows loaded")
    except Exception as e:
        print(f" -> ERROR loading {name}: {e}")
        exit(1)

# =======================
# STEP 2: CLEAN FUNCTIONS
# =======================
def clean_text(series):
    """Remove special characters, extra spaces, proper capitalization"""
    return (series.fillna('')
                  .astype(str)
                  .str.strip()
                  .str.title()
                  .apply(lambda x: re.sub(r'[^A-Za-z0-9\s]', '', x)))

def normalize_gender(value):
    """Normalize gender to Male/Female/Other"""
    if pd.isna(value) or str(value).strip() == '':
        return 'Other'
    s = str(value).strip().upper()
    return 'Male' if s in ['M', 'MALE'] else 'Female' if s in ['F', 'FEMALE'] else 'Other'

def clean_numeric(series):
    return pd.to_numeric(series, errors='coerce')

def clean_amount(series):
    def parse_amount(x):
        try:
            val = float(x)
            return val if val >= 0 else np.nan
        except:
            return np.nan
    return series.apply(parse_amount)

# =======================
# STEP 3: CLEAN DATA
# =======================

# --- Patients ---
patients = data['patients'].drop_duplicates('patient_id').copy()
patients['patient_id'] = clean_numeric(patients['patient_id']).astype('Int64')
patients = patients.dropna(subset=['patient_id']).copy()
patients['first_name'] = clean_text(patients['first_name'])
patients['last_name'] = clean_text(patients['last_name'])
patients['patient_name'] = (patients['first_name'] + ' ' + patients['last_name']).str.strip()
patients['date_of_birth'] = pd.to_datetime(patients['date_of_birth'], errors='coerce')
patients['gender'] = patients['gender'].apply(normalize_gender)
patients['primary_condition'] = clean_text(patients['primary_condition']).replace(['', 'Unknown'], 'Unknown')
patients_clean = patients[['patient_id','first_name','last_name','patient_name','date_of_birth','gender','primary_condition']]
print(f" -> Patients cleaned: {len(patients_clean)} rows")

# --- Doctors ---
doctors = data['doctors'].drop_duplicates('doctor_id').copy()
doctors['doctor_id'] = clean_numeric(doctors['doctor_id']).astype('Int64')
doctors = doctors.dropna(subset=['doctor_id']).copy()
doctors['first_name'] = clean_text(doctors['first_name'])
doctors['last_name'] = clean_text(doctors['last_name'])
doctors['doctor_name'] = ('Dr. ' + doctors['first_name'] + ' ' + doctors['last_name']).str.strip()
doctors['specialization'] = clean_text(doctors['specialization'])
doctors['department'] = clean_text(doctors['department']).str.replace('Dept', 'Department')
doctors_clean = doctors[['doctor_id','first_name','last_name','doctor_name','specialization','department']]
print(f" -> Doctors cleaned: {len(doctors_clean)} rows")

# --- Visits ---
visits = data['visits'].drop_duplicates('visit_id').copy()
for col in ['visit_id','patient_id','doctor_id']:
    visits[col] = clean_numeric(visits[col]).astype('Int64')
visits = visits.dropna(subset=['visit_id','patient_id','doctor_id']).copy()
visits = visits[visits['patient_id'].isin(patients_clean['patient_id']) &
                visits['doctor_id'].isin(doctors_clean['doctor_id'])].copy()
visits['visit_date'] = pd.to_datetime(visits['visit_date'], errors='coerce')
visits['symptoms'] = clean_text(visits['symptoms']).replace('', None)
visits['billing_amount'] = clean_amount(visits['billing_amount'])
# Merge patient and doctor names
visits = visits.merge(patients_clean[['patient_id','patient_name']], on='patient_id', how='left')
visits = visits.merge(doctors_clean[['doctor_id','doctor_name']], on='doctor_id', how='left')
visits_clean = visits[['visit_id','patient_id','doctor_id','visit_date','symptoms','billing_amount','patient_name','doctor_name']]
print(f" -> Visits cleaned: {len(visits_clean)} rows")

# --- Diagnosis ---
diagnosis = data['diagnosis'].drop_duplicates('diagnosis_id').copy()
for col in ['diagnosis_id','visit_id']:
    diagnosis[col] = clean_numeric(diagnosis[col]).astype('Int64')
diagnosis = diagnosis.dropna(subset=['diagnosis_id','visit_id']).copy()
diagnosis = diagnosis[diagnosis['visit_id'].isin(visits_clean['visit_id'])].copy()
diagnosis['diagnosis'] = clean_text(diagnosis['diagnosis'])
diagnosis['severity'] = clean_text(diagnosis['severity'])
diagnosis_clean = diagnosis[['diagnosis_id','visit_id','diagnosis','severity']]
print(f" -> Diagnosis cleaned: {len(diagnosis_clean)} rows")

# =======================
# STEP 4: LOAD TO SILVER (FK-SAFE)
# =======================
print("\n[STEP 4] Loading Silver tables...")

with engine.connect() as conn:
    # Temporarily disable FK checks to truncate safely
    conn.execute(text("SET FOREIGN_KEY_CHECKS=0;"))
    conn.execute(text("TRUNCATE TABLE silver_diagnosis;"))
    conn.execute(text("TRUNCATE TABLE silver_visits;"))
    conn.execute(text("TRUNCATE TABLE silver_doctors;"))
    conn.execute(text("TRUNCATE TABLE silver_patients;"))
    conn.execute(text("SET FOREIGN_KEY_CHECKS=1;"))

def load_silver(df, table):
    try:
        # Append to existing tables instead of replace
        df.to_sql(table, engine, if_exists='append', index=False, chunksize=500)
        print(f" -> Loaded {table}: {len(df)} rows")
    except Exception as e:
        print(f" -> Error loading {table}: {e}")

# Load in FK-safe order
load_silver(patients_clean, 'silver_patients')
load_silver(doctors_clean, 'silver_doctors')
load_silver(visits_clean, 'silver_visits')
load_silver(diagnosis_clean, 'silver_diagnosis')


# =======================
# STEP 5: VERIFY
# =======================
print("\n[STEP 5] Verifying data in Silver tables...")
for table in ['silver_patients','silver_doctors','silver_visits','silver_diagnosis']:
    try:
        with engine.connect() as conn:
            count = conn.execute(text(f"SELECT COUNT(*) FROM {table}")).scalar()
            print(f" -> {table}: {count} rows")
    except Exception as e:
        print(f"Error verifying {table}: {e}")


print("\nETL PIPELINE COMPLETED SUCCESSFULLY!")
