-- ====================================================================
-- Script: silver_tables.sql
-- Purpose:
--   1. Create all SILVER layer tables.
--   2. Silver layer = cleaned, typed, validated data.
--   3. Enforce primary keys, foreign keys, correct data types.
--   4. Used by Python ETL (Bronze → Silver transformation).
-- ====================================================================

USE healthcare_dw;

-- ********************************************************************
-- DROP OLD SILVER TABLES
-- Ensures a clean load every time before running ETL.
-- ********************************************************************
DROP TABLE IF EXISTS silver_diagnosis;
DROP TABLE IF EXISTS silver_visits;
DROP TABLE IF EXISTS silver_doctors;
DROP TABLE IF EXISTS silver_patients;


-- ********************************************************************
-- SILVER LAYER TABLES
-- These tables store CLEANED & PROPERLY TYPED data.
-- Data comes from Bronze → cleaned → loaded here via Python ETL.
-- ********************************************************************

-- ===============================
-- SILVER PATIENTS
-- ===============================
CREATE TABLE IF NOT EXISTS silver_patients (
    patient_id INT PRIMARY KEY,                -- Cleaned integer ID
    first_name VARCHAR(100),                   -- Cleaned first name
    last_name VARCHAR(100),                    -- Cleaned last name
    patient_name VARCHAR(200),                 -- first_name + last_name
    date_of_birth DATE,                        -- Converted from TEXT → DATE
    gender ENUM('Male','Female','Other')       -- Standardized gender values
        DEFAULT 'Other',
    primary_condition VARCHAR(100)             -- Cleaned medical condition
);

-- ===============================
-- SILVER DOCTORS
-- ===============================
CREATE TABLE IF NOT EXISTS silver_doctors (
    doctor_id INT PRIMARY KEY,                 -- Clean integer ID
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    doctor_name VARCHAR(200),                  -- first_name + last_name
    specialization VARCHAR(100),
    department VARCHAR(100)
);

-- ===============================
-- SILVER VISITS
-- ===============================
CREATE TABLE IF NOT EXISTS silver_visits (
    visit_id INT PRIMARY KEY,                  -- Clean integer ID
    patient_id INT,                            -- FK → silver_patients
    doctor_id INT,                             -- FK → silver_doctors
    visit_date DATE,                           -- Clean → valid DATE
    symptoms TEXT,                             -- Optional column
    billing_amount DECIMAL(12,2),              -- Converted from TEXT → DECIMAL
    patient_name VARCHAR(200),                 -- Redundant but kept for audit
    doctor_name VARCHAR(200),
    FOREIGN KEY (patient_id) REFERENCES silver_patients(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES silver_doctors(doctor_id)
);

-- ===============================
-- SILVER DIAGNOSIS
-- ===============================
CREATE TABLE IF NOT EXISTS silver_diagnosis (
    diagnosis_id INT PRIMARY KEY,              -- Clean integer ID
    visit_id INT,                              -- FK → silver_visits
    diagnosis VARCHAR(100),                    -- Cleaned diagnosis name
    severity VARCHAR(20),                      -- Cleaned severity values
    FOREIGN KEY (visit_id) REFERENCES silver_visits(visit_id)
);


-- ********************************************************************
-- TRUNCATE TABLES BEFORE LOADING
-- Ensures Python ETL inserts fresh cleaned data each run.
-- ********************************************************************
TRUNCATE TABLE silver_diagnosis;
TRUNCATE TABLE silver_visits;
TRUNCATE TABLE silver_doctors;
TRUNCATE TABLE silver_patients;

-- ********************************************************************
-- VALIDATION CHECKS AFTER LOADING
-- Run these AFTER Python ETL loads data from Bronze → Silver.
-- ********************************************************************
SELECT * FROM silver_patients LIMIT 10;
SELECT * FROM silver_visits LIMIT 10;
SELECT COUNT(*) FROM silver_diagnosis;
SELECT * FROM silver_doctors LIMIT 10;