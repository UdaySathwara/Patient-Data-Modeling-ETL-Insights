-- ====================================================================
-- Script: gold_layer.sql
-- Purpose:
--   1. Create DIM and FACT tables for the GOLD layer.
--   2. GOLD layer = analytics-ready, surrogate keys, optimized schema.
--   3. Loads data from SILVER tables and builds dimensional model.
-- ====================================================================

USE healthcare_dw;

-- ********************************************************************
-- 1. DROP OLD GOLD TABLES
-- Ensures clean rebuild before loading new GOLD layer data
-- ********************************************************************
DROP TABLE IF EXISTS fact_visits;
DROP TABLE IF EXISTS dim_patient;
DROP TABLE IF EXISTS dim_doctor;
DROP TABLE IF EXISTS dim_date;


-- ********************************************************************
-- 2. DIMENSION TABLE: PATIENT
-- Stores unique patient metadata with surrogate keys
-- ********************************************************************
CREATE TABLE dim_patient (
    patient_key INT PRIMARY KEY AUTO_INCREMENT,   -- Surrogate key (DW key)
    patient_id INT,                               -- Business key from Silver table
    patient_name VARCHAR(200),                    -- Full name (first + last)
    gender ENUM('Male','Female','Other') DEFAULT 'Other',
    age INT                                        -- Computed age from DOB
);

-- Populate dim_patient from Silver layer
INSERT INTO dim_patient (patient_id, patient_name, gender, age)
SELECT
    patient_id,
    CONCAT(first_name, ' ', last_name),
    gender,
    TIMESTAMPDIFF(YEAR, date_of_birth, CURDATE()) AS age
FROM silver_patients;


-- ********************************************************************
-- 3. DIMENSION TABLE: DOCTOR
-- Stores doctor identity and specialization information
-- ********************************************************************
CREATE TABLE dim_doctor (
    doctor_key INT PRIMARY KEY AUTO_INCREMENT,    -- Surrogate key
    doctor_id INT,                                -- Business key
    doctor_name VARCHAR(200),                     -- Full name
    specialization VARCHAR(100)
);

-- Load doctor dimension data
INSERT INTO dim_doctor (doctor_id, doctor_name, specialization)
SELECT
    doctor_id,
    CONCAT(first_name, ' ', last_name),
    specialization
FROM silver_doctors;


-- ********************************************************************
-- 4. DIMENSION TABLE: DATE
-- Stores all distinct visit dates for time-based analytics
-- ********************************************************************
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY AUTO_INCREMENT,      -- Surrogate key
    full_date DATE                                -- Actual visit date
);

-- Load unique visit dates
INSERT INTO dim_date (full_date)
SELECT DISTINCT
    visit_date
FROM silver_visits;


-- ********************************************************************
-- 5. FACT TABLE: VISITS
-- Central fact table storing metrics associated with patient visits
-- ********************************************************************
DROP TABLE IF EXISTS fact_visits;

CREATE TABLE fact_visits (
    visit_key INT PRIMARY KEY AUTO_INCREMENT,     -- Surrogate key for fact row

    -- Foreign keys from dimension tables
    patient_key INT,
    doctor_key INT,
    date_key INT,

    -- Denormalized fields for faster analytics
    patient_name VARCHAR(200),
    doctor_name VARCHAR(200),
    full_date DATE,

    -- Measures (numerical & categorial facts)
    consultation_fee DECIMAL(12,2),
    diagnosis_code VARCHAR(100),
    severity VARCHAR(20),

    -- Referential integrity
    FOREIGN KEY (patient_key) REFERENCES dim_patient(patient_key),
    FOREIGN KEY (doctor_key) REFERENCES dim_doctor(doctor_key),
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key)
);


-- ********************************************************************
-- 6. POPULATE FACT TABLE
-- Joins SILVER tables + DIM tables to build analytical fact table
-- ********************************************************************
INSERT INTO fact_visits (
    patient_key,
    patient_name,
    doctor_key,
    doctor_name,
    date_key,
    full_date,
    consultation_fee,
    diagnosis_code,
    severity
)
SELECT
    p.patient_key,                     -- Surrogate patient key
    p.patient_name,

    d.doctor_key,                      -- Surrogate doctor key
    d.doctor_name,

    dt.date_key,                       -- Surrogate date key
    v.visit_date,

    v.billing_amount AS consultation_fee,
    dg.diagnosis AS diagnosis_code,
    dg.severity
FROM silver_visits v
JOIN silver_diagnosis dg ON v.visit_id = dg.visit_id
JOIN dim_patient p ON v.patient_id = p.patient_id
JOIN dim_doctor d ON v.doctor_id = d.doctor_id
JOIN dim_date dt ON v.visit_date = dt.full_date;


-- ********************************************************************
-- 7. DATA VALIDATION (Post Load Checks)
-- Use these queries to quickly verify correctness
-- ********************************************************************
SELECT * FROM dim_patient LIMIT 10;      -- Verify patient dimension
SELECT * FROM silver_patients LIMIT 10;  -- Compare with silver
SELECT * FROM dim_doctor LIMIT 10;       -- Verify doctor dimension
SELECT * FROM dim_date LIMIT 10;         -- Verify date dimension
SELECT * FROM fact_visits WHERE patient_key = 3;  -- Fact table validation