/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
      Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

create table bronze.crm_cust_info(
	cst_id int,
	cst_key nvarchar(50),
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_material_status nvarchar(50),
	cst_gndr nvarchar(50),
	cst_create_date date
);

-- Check if the table exists and drop it if it does
DROP TABLE IF EXISTS bronze.crm_prd_info;

-- Create the CRM Product Information table
CREATE TABLE bronze.crm_prd_info (
    prd_id       INT,
    prd_key      VARCHAR(50),
    prd_nm       VARCHAR(50),
    prd_cost     INT,
    prd_line     VARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt   DATETIME
);

-- Drop the table if it already exists
DROP TABLE IF EXISTS bronze.crm_sales_details;

-- Create CRM Sales Details table
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num  VARCHAR(50),
    sls_prd_key  VARCHAR(50),
    sls_cust_id  INT,
    sls_order_dt INT,
    sls_ship_dt  INT,
    sls_due_dt   INT,
    sls_sales    INT,
    sls_quantity INT,
    sls_price    INT
);

-- =====================================================
-- Create ERP Location Table
-- =====================================================

-- Drop table if it already exists
DROP TABLE IF EXISTS bronze.erp_loc_a101;

-- Create ERP Location Table
CREATE TABLE bronze.erp_loc_a101 (
    cid    VARCHAR(50),
    cntry  VARCHAR(50)
);


-- =====================================================
-- Create ERP Customer Table
-- =====================================================

-- Drop table if it already exists
DROP TABLE IF EXISTS bronze.erp_cust_az12;

-- Create ERP Customer Table
CREATE TABLE bronze.erp_cust_az12 (
    cid    VARCHAR(50),
    bdate  DATE,
    gen    VARCHAR(50)
);


-- =====================================================
-- Create ERP Product Category Table
-- =====================================================

-- Drop table if it already exists
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

-- Create ERP Product Category Table
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id           VARCHAR(50),
    cat          VARCHAR(50),
    subcat       VARCHAR(50),
    maintenance  VARCHAR(50)
);
