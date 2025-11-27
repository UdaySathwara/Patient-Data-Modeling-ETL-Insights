-- ====================================================================
-- Script: create_database_and_bronze_tables.sql
-- Purpose:
--   1. Create the Data Warehouse database (healthcare_dw)
--   2. Create all Bronze Layer tables (raw data storage)
--   3. Bronze layer keeps data EXACTLY as received from CSVs
--      → No cleaning
--      → No type conversions
--   4. Use SELECT queries to validate data loading
-- ====================================================================


-- ===============================
-- Create Database
-- ===============================
CREATE DATABASE IF NOT EXISTS healthcare_dw;
USE healthcare_dw;


-- ********************************************************************
-- BRONZE LAYER TABLES
-- These tables store RAW data loaded directly from CSV files.
-- Everything is stored as TEXT/VARCHAR to avoid loading failures.
-- No constraints, no transformations.
-- ********************************************************************


-- ===============================
-- BRONZE: Patients
-- ===============================
DROP TABLE IF EXISTS bronze_patients;
CREATE TABLE bronze_patients (
    patient_id VARCHAR(50),      -- Raw patient ID from CSV
    first_name TEXT,             -- Raw first name
    last_name TEXT,              -- Raw last name
    date_of_birth TEXT,          -- Stored as TEXT (will be cleaned in Silver)
    gender TEXT,                 -- May contain inconsistent values
    primary_condition TEXT       -- Raw medical condition
);


-- ===============================
-- BRONZE: Doctors
-- ===============================
DROP TABLE IF EXISTS bronze_doctors;
CREATE TABLE bronze_doctors (
    doctor_id VARCHAR(50),       -- Raw doctor ID
    first_name TEXT,             -- Raw doctor first name
    last_name TEXT,              -- Raw doctor last name
    specialization TEXT,         -- Raw specialization field
    department TEXT              -- Raw department name
);


-- ===============================
-- BRONZE: Visits
-- ===============================
DROP TABLE IF EXISTS bronze_visits;
CREATE TABLE bronze_visits (
    visit_id VARCHAR(50),        -- Raw visit ID
    patient_id VARCHAR(50),      -- Raw patient ID (FK - not enforced in Bronze)
    doctor_id VARCHAR(50),       -- Raw doctor ID (FK - not enforced)
    visit_date TEXT,             -- Stored as TEXT (cleaned later)
    billing_amount TEXT,         -- Raw billing amount (cleaned in Silver)
    patient_name TEXT,           -- Not required, but included in raw CSV
    doctor_name TEXT             -- Same as above
);


-- ===============================
-- BRONZE: Diagnosis
-- ===============================
DROP TABLE IF EXISTS bronze_diagnosis;
CREATE TABLE bronze_diagnosis (
    diagnosis_id VARCHAR(50),    -- Raw diagnosis ID
    visit_id VARCHAR(50),        -- Raw visit ID reference
    diagnosis TEXT,              -- Illness/condition
    severity TEXT,               -- Raw severity value
    patient_name TEXT,           -- Present in CSV, ignored in Silver
    doctor_name TEXT             -- Same as above
);


-- ********************************************************************
-- DATA VALIDATION (Optional but recommended)
-- After running the Python ETL_LOAD_BRONZE script,
-- Use the following queries to confirm data was loaded correctly.
-- ********************************************************************

SELECT * FROM bronze_patients LIMIT 10;
SELECT * FROM bronze_doctors LIMIT 10;
SELECT * FROM bronze_visits LIMIT 10;
SELECT * FROM bronze_diagnosis LIMIT 10;
