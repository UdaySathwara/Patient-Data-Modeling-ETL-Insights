# Data Catalog - Gold Layer

## Overview

The Gold Layer represents business-level data structured to support analytical and reporting use cases. It consists of dimension tables and fact tables for healthcare metrics including visits, diagnoses, and patient-doctor interactions.

## Tables

### gold.dim_patient

**Purpose**: Stores patient identity and demographic information enriched for analytics.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| patient_key | INT | Surrogate key uniquely identifying each patient in the dimension table |
| patient_id | INT | Business key from the source Silver layer |
| patient_name | VARCHAR(200) | Full patient name (first name + last name) |
| gender | ENUM | Gender of the patient ('Male', 'Female', 'Other') |
| age | INT | Age of the patient computed from date_of_birth |

### gold.dim_doctor

**Purpose**: Stores doctor information including their identity and specialization.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| doctor_key | INT | Surrogate key uniquely identifying each doctor in the dimension table |
| doctor_id | INT | Business key representing the doctor |
| doctor_name | VARCHAR(200) | Full doctor name (first name + last name) |
| specialization | VARCHAR(100) | Area of medical expertise such as Pediatrics, Cardiology, Dermatology, etc. |

### gold.dim_date

**Purpose**: Stores calendar dates used for time-series reporting.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| date_key | INT | Surrogate key uniquely identifying each date entry |
| full_date | DATE | Actual date (YYYY-MM-DD) corresponding to patient visit records |

### gold.fact_visits

**Purpose**: Stores detailed visit-level facts combining patient, doctor, diagnosis, and billing information.

| Column Name | Data Type | Description |
|-------------|-----------|-------------|
| visit_key | INT | Surrogate key uniquely identifying each visit record |
| patient_key | INT | Foreign key referencing dim_patient.patient_key |
| patient_name | VARCHAR(200) | Denormalized patient name for fast reporting |
| doctor_key | INT | Foreign key referencing dim_doctor.doctor_key |
| doctor_name | VARCHAR(200) | Denormalized doctor name for fast reporting |
| date_key | INT | Foreign key referencing dim_date.date_key |
| full_date | DATE | Actual visit date |
| consultation_fee | DECIMAL(12,2) | Billed consultation amount |
| diagnosis_code | VARCHAR(100) | Diagnosis description or ICD code |
| severity | VARCHAR(20) | Severity level of diagnosis such as Mild, Moderate, Severe |
