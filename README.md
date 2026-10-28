## 🏗️ Data Architecture

This project follows the **Medallion Architecture**, consisting of three layers: **Bronze, Silver, and Gold**.

### Medallion Architecture Layers

1. **🥉 Bronze Layer — Raw Data**
   - Stores raw data as received from source systems.
   - Ingests CSV files from ERP and CRM systems into the SQL Server database.
   - Preserves the original source data for traceability.

2. **🥈 Silver Layer — Cleaned Data**
   - Performs data cleansing and standardization.
   - Resolves data quality issues and handles inconsistencies.
   - Integrates and prepares data for analytical processing.

3. **🥇 Gold Layer — Business-Ready Data**
   - Stores curated, business-ready data.
   - Organizes data into a **star schema** using fact and dimension tables.
   - Supports reporting, dashboards, and analytical queries.

---

## 📖 Project Overview

The goal of this project is to build a modern data warehouse using SQL Server, consolidating sales data from ERP and CRM source systems to enable analytical reporting and informed business decisions.

Throughout this project, you will:

1. **Design the Data Architecture:** Build a modern data warehouse using the Bronze, Silver, and Gold layers.
2. **Develop ETL Pipelines:** Extract data from source files, transform it, and load it through the warehouse layers.
3. **Model the Data:** Design fact and dimension tables using a star schema for efficient analytical queries.
4. **Perform Data Analysis:** Use SQL to answer business questions and uncover insights into sales performance.

---

## 🚀 Project Requirements

### 🛠️ 1. Building the Data Warehouse — Data Engineering

#### Objective

Develop a modern data warehouse using **SQL Server** to consolidate sales data from multiple source systems, enabling analytical reporting and informed decision-making.

#### Specifications

- **Data Sources:** Import data from two source systems — ERP and CRM — provided as CSV files.
- **Data Quality:** Identify, cleanse, and resolve data quality issues before analysis.
- **Data Integration:** Combine data from both source systems into a unified, user-friendly data model.
- **Data Modeling:** Build fact and dimension tables following a star schema.
- **Scope:** Focus on the latest dataset; historical data tracking and historization are not required.
- **Documentation:** Provide clear documentation of the data architecture and data model for business stakeholders and analytics teams.

### 📊 2. BI: Analytics & Reporting — Data Analysis

#### Objective

Develop SQL-based analytics to generate actionable insights into key business areas.

#### Key Areas of Analysis

- **Customer Behavior:** Analyze customer purchasing patterns and preferences.
- **Product Performance:** Identify top-performing products and evaluate sales performance.
- **Sales Trends:** Examine sales patterns and track business performance over time.

These insights will help stakeholders monitor key business metrics and make data-driven strategic decisions.
---
