/*
===============================================================================
Database Setup Script: Data Warehouse
===============================================================================

Purpose:
    This script creates and initializes the Data Warehouse environment
    for a Medallion Architecture project in MySQL.

    It performs the following operations:
    1. Drops the existing datawarehouse database if it exists.
    2. Creates a fresh datawarehouse database.
    3. Creates Bronze, Silver, and Gold databases to represent the
       three layers of the Medallion Architecture.

WARNING:
    Running this script will permanently delete the existing
    'datawarehouse' database and all its tables and data.

    Make sure to back up any important data before execution.

    The Bronze, Silver, and Gold databases are separate databases
    in MySQL, not schemas within the datawarehouse database.

Database System: MySQL
===============================================================================
*/

-- ============================================================================
-- STEP 1: Drop the existing Data Warehouse database if it exists
-- ============================================================================
DROP DATABASE IF EXISTS datawarehouse;

-- ============================================================================
-- STEP 2: Create a fresh Data Warehouse database
-- ============================================================================
CREATE DATABASE datawarehouse;

-- ============================================================================
-- STEP 3: Select the Data Warehouse database for use
-- ============================================================================
USE datawarehouse;

-- ============================================================================
-- STEP 4: Create the Bronze layer database
-- Purpose: Store raw data ingested from source systems.
-- ============================================================================
CREATE DATABASE IF NOT EXISTS bronze;

-- ============================================================================
-- STEP 5: Create the Silver layer database
-- Purpose: Store cleaned, standardized, and transformed data.
-- ============================================================================
CREATE DATABASE IF NOT EXISTS silver;

-- ============================================================================
-- STEP 6: Create the Gold layer database
-- Purpose: Store business-ready data for reporting and analytics.
-- ============================================================================
CREATE DATABASE IF NOT EXISTS gold;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================

