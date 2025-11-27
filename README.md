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
