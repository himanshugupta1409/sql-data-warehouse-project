
/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to
    populate the 'silver' schema tables from the 'bronze' schema.
    Actions Performed:
        - Truncates Silver tables.
        - Inserts transformed and cleansed data from Bronze into Silver tables.

Parameters:
    None.
      This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

DELIMITER $$
DROP PROCEDURE IF EXISTS silver.load_silver;
CREATE PROCEDURE silver.load_silver()
BEGIN

    -- ============================================
    -- DECLARE VARIABLES
    -- ============================================

    DECLARE batch_start_time DATETIME(3);
    DECLARE batch_end_time DATETIME(3);
    DECLARE start_time DATETIME(3);
    DECLARE end_time DATETIME(3);

    DECLARE error_message TEXT;
    DECLARE error_number INT;
    DECLARE error_state CHAR(5);


    -- ============================================
    -- ERROR HANDLING
    -- ============================================

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        GET DIAGNOSTICS CONDITION 1
            error_message = MESSAGE_TEXT,
            error_number = MYSQL_ERRNO,
            error_state = RETURNED_SQLSTATE;

        SELECT 'ERROR OCCURRED DURING LOADING SILVER LAYER' AS message;

        SELECT
            error_message AS error_message,
            error_number AS error_number,
            error_state AS error_state;

    END;


    -- ============================================
    -- START BATCH LOADING
    -- ============================================

    SET batch_start_time = NOW(3);

    SELECT '================================================' AS message;
    SELECT 'Loading Silver Layer' AS message;
    SELECT '================================================' AS message;

    SELECT '------------------------------------------------' AS message;
    SELECT 'Loading CRM Tables' AS message;
    SELECT '------------------------------------------------' AS message;


    -- ============================================
    -- 1. LOAD CRM CUSTOMER INFORMATION
    -- ============================================

    SET start_time = NOW(3);

    SELECT '>> Truncating Table: silver.crm_cust_info' AS message;

    TRUNCATE TABLE silver.crm_cust_info;

    SELECT '>> Inserting Data Into: silver.crm_cust_info' AS message;

    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_material_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,

        CASE
            WHEN UPPER(TRIM(cst_material_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_material_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,

        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,

        cst_create_date

    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS flag_last

        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL  or cst_create_date != 0000-00-00

    ) t

    WHERE flag_last = 1;

    SET end_time = NOW(3);

    SELECT CONCAT(
        '>> Load Duration: ',
        ROUND(TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000, 3),
        ' seconds'
    ) AS message;

    SELECT '>> -------------' AS message;


    -- ============================================
    -- 2. LOAD CRM PRODUCT INFORMATION
    -- ============================================

    SET start_time = NOW(3);

    SELECT '>> Truncating Table: silver.crm_prd_info' AS message;

    TRUNCATE TABLE silver.crm_prd_info;

    SELECT '>> Inserting Data Into: silver.crm_prd_info' AS message;

    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )

    SELECT
        prd_id,

        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

        SUBSTRING(prd_key, 7) AS prd_key,

        prd_nm,

        IFNULL(prd_cost, 0) AS prd_cost,

        CASE
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        CAST(
            DATE_SUB(
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key
                    ORDER BY prd_start_dt
                ),
                INTERVAL 1 DAY
            ) AS DATE
        ) AS prd_end_dt

    FROM bronze.crm_prd_info;

    SET end_time = NOW(3);

    SELECT CONCAT(
        '>> Load Duration: ',
        ROUND(TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000, 3),
        ' seconds'
    ) AS message;

    SELECT '>> -------------' AS message;


    -- ============================================
    -- 3. LOAD CRM SALES DETAILS
    -- ============================================

    SET start_time = NOW(3);

    SELECT '>> Truncating Table: silver.crm_sales_details' AS message;

    TRUNCATE TABLE silver.crm_sales_details;

    SELECT '>> Inserting Data Into: silver.crm_sales_details' AS message;

    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )

    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,

        CASE
            WHEN sls_order_dt = 0
                OR CHAR_LENGTH(CAST(sls_order_dt AS CHAR)) <> 8
            THEN NULL
            ELSE STR_TO_DATE(CAST(sls_order_dt AS CHAR), '%Y%m%d')
        END AS sls_order_dt,

        CASE
            WHEN sls_ship_dt = 0
                OR CHAR_LENGTH(CAST(sls_ship_dt AS CHAR)) <> 8
            THEN NULL
            ELSE STR_TO_DATE(CAST(sls_ship_dt AS CHAR), '%Y%m%d')
        END AS sls_ship_dt,

        CASE
            WHEN sls_due_dt = 0
                OR CHAR_LENGTH(CAST(sls_due_dt AS CHAR)) <> 8
            THEN NULL
            ELSE STR_TO_DATE(CAST(sls_due_dt AS CHAR), '%Y%m%d')
        END AS sls_due_dt,

        CASE
            WHEN sls_sales IS NULL
                OR sls_sales <= 0
                OR sls_sales <> sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,

        sls_quantity,

        CASE
            WHEN sls_price IS NULL OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price

    FROM bronze.crm_sales_details;

    SET end_time = NOW(3);

    SELECT CONCAT(
        '>> Load Duration: ',
        ROUND(TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000, 3),
        ' seconds'
    ) AS message;

    SELECT '>> -------------' AS message;


    -- ============================================
    -- LOAD ERP TABLES
    -- ============================================

    SELECT '------------------------------------------------' AS message;
    SELECT 'Loading ERP Tables' AS message;
    SELECT '------------------------------------------------' AS message;


    -- ============================================
    -- 4. LOAD ERP CUSTOMER INFORMATION
    -- ============================================

    SET start_time = NOW(3);

    SELECT '>> Truncating Table: silver.erp_cust_az12' AS message;

    TRUNCATE TABLE silver.erp_cust_az12;

    SELECT '>> Inserting Data Into: silver.erp_cust_az12' AS message;

    INSERT INTO silver.erp_cust_az12 (
        cid,
        bdate,
        gen
    )

    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
            ELSE cid
        END AS cid,

        CASE
            WHEN bdate > CURDATE() THEN NULL
            ELSE bdate
        END AS bdate,

        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
            ELSE 'n/a'
        END AS gen

    FROM bronze.erp_cust_az12;

    SET end_time = NOW(3);

    SELECT CONCAT(
        '>> Load Duration: ',
        ROUND(TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000, 3),
        ' seconds'
    ) AS message;

    SELECT '>> -------------' AS message;


    -- ============================================
    -- 5. LOAD ERP LOCATION INFORMATION
    -- ============================================

    SET start_time = NOW(3);

    SELECT '>> Truncating Table: silver.erp_loc_a101' AS message;

    TRUNCATE TABLE silver.erp_loc_a101;

    SELECT '>> Inserting Data Into: silver.erp_loc_a101' AS message;

    INSERT INTO silver.erp_loc_a101 (
        cid,
        cntry
    )

    SELECT
        REPLACE(cid, '-', '') AS cid,

        CASE
            WHEN TRIM(cntry) = 'DE' THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry

    FROM bronze.erp_loc_a101;

    SET end_time = NOW(3);

    SELECT CONCAT(
        '>> Load Duration: ',
        ROUND(TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000, 3),
        ' seconds'
    ) AS message;

    SELECT '>> -------------' AS message;


    -- ============================================
    -- 6. LOAD ERP PRODUCT CATEGORY INFORMATION
    -- ============================================

    SET start_time = NOW(3);

    SELECT '>> Truncating Table: silver.erp_px_cat_g1v2' AS message;

    TRUNCATE TABLE silver.erp_px_cat_g1v2;

    SELECT '>> Inserting Data Into: silver.erp_px_cat_g1v2' AS message;

    INSERT INTO silver.erp_px_cat_g1v2 (
        id,
        cat,
        subcat,
        maintenance
    )

    SELECT
        id,
        cat,
        subcat,
        maintenance

    FROM bronze.erp_px_cat_g1v2;

    SET end_time = NOW(3);

    SELECT CONCAT(
        '>> Load Duration: ',
        ROUND(TIMESTAMPDIFF(MICROSECOND, start_time, end_time) / 1000000, 3),
        ' seconds'
    ) AS message;

    SELECT '>> -------------' AS message;


    -- ============================================
    -- TOTAL BATCH LOADING DURATION
    -- ============================================

    SET batch_end_time = NOW(3);

    SELECT '==========================================' AS message;
    SELECT 'Loading Silver Layer is Completed' AS message;

    SELECT CONCAT(
        'Total Load Duration: ',
        ROUND(
            TIMESTAMPDIFF(
                MICROSECOND,
                batch_start_time,
                batch_end_time
            ) / 1000000,
            3
        ),
        ' seconds'
    ) AS message;

    SELECT '==========================================' AS message;


END $$

DELIMITER ;
