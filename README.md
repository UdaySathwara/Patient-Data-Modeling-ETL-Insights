# 🏥 Patient Data Modeling & ETL Insights
A Complete Data Warehouse and Analytics Project

Welcome to the **Patient Data Modeling & ETL Insights** repository! 🚀
This project demonstrates a full end-to-end Data Warehouse and Analytics pipeline built using industry-standard data engineering practices. It covers everything from data modeling, ETL pipeline development, and data quality checks, to building a multi-layer data warehouse (Bronze → Silver → Gold) and generating meaningful healthcare insights.

---
## 🎯 Project Overview

This project simulates a real-world Hospital Patient Analytics System, where raw patient, doctor, visit, and diagnosis data flows through multiple transformation stages before becoming clean, standardized, and analysis-ready.

The workflow follows the Medallion Architecture:

![Data Architecture](docs/Data_architecture.png)
1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---

## 📖 Project Overview

This project involves:

1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.

🎯 This repository is an excellent resource for showcaseing expertise in:
- SQL Development
- Data Architect
- Data Engineering  
- ETL Pipeline  
- Data Modeling  
- Data Analytics  

---

## 🚀 Project Requirements

### Building the Data Warehouse (Data Engineering)

#### Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from two source systems (ERP and CRM) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine both sources into a single, user-friendly data model designed for analytical queries.
- **Scope**: Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.

## 📂 Repository Structure
```
Healthcare-Data-Warehouse/
│
├── Data/                             # Raw CSV input files
│   ├── patients.csv
│   ├── doctors.csv
│   ├── visits.csv
│   └── diagnosis.csv
│
├── SQL/                              # SQL scripts for DW layers
│   ├── bronze.sql
│   ├── silver.sql
│   └── gold.sql
│ 
│
├── Python/                           # Python ETL scripts
│   ├── etl_load_bronze.py
│   ├── etl_transform_to_silver.py
│   └── etl_create_gold.py
│
├── Architecture/                     # Architecture diagrams
│   └── healthcare_dw_architecture.png
│
└─── .gitignore                       # Project overview and instructions
└─── LICENSE                          # License information for the repository 
└─── README.md                        # Files and directories to be ignored by Git

```
