📘 Data Catalog – Healthcare Gold Layer
Overview

The Gold Layer contains analytics-ready data modeled using dimension tables and fact tables.
This layer represents the business-level view designed for dashboards, reporting, and advanced analysis.

🟦 1. gold.dim_patient

Purpose: Stores enriched patient details used for analytics.

Columns
Column Name	Data Type	Description
patient_key	INT	Surrogate primary key for each patient.
patient_id	INT	Business key from the Silver layer.
patient_name	VARCHAR(200)	Full patient name (first + last).
gender	ENUM	Gender of the patient (‘Male’, ‘Female’, ‘Other’).
age	INT	Age calculated from date_of_birth.
🟩 2. gold.dim_doctor

Purpose: Stores doctor information used for reporting and analytics.

Columns
Column Name	Data Type	Description
doctor_key	INT	Surrogate primary key for each doctor.
doctor_id	INT	Business key from the Silver layer.
doctor_name	VARCHAR(200)	Full doctor name (first + last).
specialization	VARCHAR(100)	Medical specialization (e.g., Cardiology, Orthopedics).
🟨 3. gold.dim_date

Purpose: Stores unique calendar dates for time-series analytics.

Columns
Column Name	Data Type	Description
date_key	INT	Surrogate primary key for each date.
full_date	DATE	Actual date of patient visit.
🟥 4. gold.fact_visits

Purpose: Stores transactional visit data and metrics for analytics.

Columns
Column Name	Data Type	Description
visit_key	INT	Surrogate key for each visit record.
patient_key	INT	Foreign key → dim_patient.patient_key.
patient_name	VARCHAR(200)	Denormalized patient name for convenience.
doctor_key	INT	Foreign key → dim_doctor.doctor_key.
doctor_name	VARCHAR(200)	Denormalized doctor name for convenience.
date_key	INT	Foreign key → dim_date.date_key.
full_date	DATE	Actual date of the visit.
consultation_fee	DECIMAL(12,2)	Fee collected for the visit.
diagnosis_code	VARCHAR(100)	Diagnosis code or description.
severity	VARCHAR(20)	Severity level (e.g., Mild, Moderate, Severe).
📌 Notes

Surrogate keys (patient_key, doctor_key, date_key, visit_key) ensure data warehouse consistency.

Fact table includes denormalized names for performance improvement.

Dimension tables come from clean Silver data.

Fact table combines Visits + Diagnosis + Dimensions for analytics.
