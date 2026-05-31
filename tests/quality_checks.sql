/*
===============================================================================
Quality Checks: Bronze, Silver, Gold Layers
===============================================================================

Purpose:
    This script validates data quality across the full data warehouse pipeline:
    Bronze -> Silver -> Gold.

Usage:
    Run after executing:
    1. bronze.load_bronze
    2. silver.load_silver
    3. gold view creation script
===============================================================================
*/

-- =============================================================================
-- Bronze Layer Tests
-- =============================================================================

-- Check row counts in Bronze tables
SELECT 'bronze.crm_cust_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL
SELECT 'bronze.crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL
SELECT 'bronze.crm_sales_details', COUNT(*) FROM bronze.crm_sales_details
UNION ALL
SELECT 'bronze.erp_cust_az12', COUNT(*) FROM bronze.erp_cust_az12
UNION ALL
SELECT 'bronze.erp_loc_a101', COUNT(*) FROM bronze.erp_loc_a101
UNION ALL
SELECT 'bronze.erp_px_cat_g1v2', COUNT(*) FROM bronze.erp_px_cat_g1v2;


-- Check duplicate customer IDs in Bronze
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Check unwanted spaces in Bronze customer names
SELECT *
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname  != TRIM(cst_lastname);


-- Check invalid Bronze sales dates
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt = 0 OR LEN(sls_order_dt) != 8
   OR sls_ship_dt  = 0 OR LEN(sls_ship_dt)  != 8
   OR sls_due_dt   = 0 OR LEN(sls_due_dt)   != 8;


-- Check invalid Bronze sales values
SELECT *
FROM bronze.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_sales <= 0
   OR sls_price IS NULL
   OR sls_price <= 0
   OR sls_quantity IS NULL
   OR sls_quantity <= 0
   OR sls_sales != sls_quantity * ABS(sls_price);



-- =============================================================================
-- Silver Layer Tests
-- =============================================================================

-- Check row counts in Silver tables
SELECT 'silver.crm_cust_info' AS table_name, COUNT(*) AS row_count FROM silver.crm_cust_info
UNION ALL
SELECT 'silver.crm_prd_info', COUNT(*) FROM silver.crm_prd_info
UNION ALL
SELECT 'silver.crm_sales_details', COUNT(*) FROM silver.crm_sales_details
UNION ALL
SELECT 'silver.erp_cust_az12', COUNT(*) FROM silver.erp_cust_az12
UNION ALL
SELECT 'silver.erp_loc_a101', COUNT(*) FROM silver.erp_loc_a101
UNION ALL
SELECT 'silver.erp_px_cat_g1v2', COUNT(*) FROM silver.erp_px_cat_g1v2;


-- Silver customer IDs should not be NULL
SELECT *
FROM silver.crm_cust_info
WHERE cst_id IS NULL;


-- Silver customer IDs should be unique
SELECT 
    cst_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- Silver names should not contain leading/trailing spaces
SELECT *
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname  != TRIM(cst_lastname);


-- Silver marital status should be standardized
SELECT DISTINCT cst_material_status
FROM silver.crm_cust_info
WHERE cst_material_status NOT IN ('Married', 'Single', 'n/a');


-- Silver gender should be standardized
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr NOT IN ('Male', 'Female', 'n/a');


-- Silver product costs should not be negative
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost < 0;


-- Silver product line should be standardized
SELECT DISTINCT prd_line
FROM silver.crm_prd_info
WHERE prd_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a');


-- Silver product date logic check
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- Silver sales dates should be valid
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
   OR sls_ship_dt IS NULL
   OR sls_due_dt IS NULL;


-- Order date should not be after shipping date or due date
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- Silver sales amount should equal quantity * price
SELECT *
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price;


-- Silver country should be standardized
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
WHERE cntry IS NULL
   OR cntry = ''
   OR cntry IN ('DE', 'US', 'USA');


-- Silver birthdate should not be in the future
SELECT *
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();


-- Silver ERP gender should be standardized
SELECT DISTINCT gen
FROM silver.erp_cust_az12
WHERE gen NOT IN ('Male', 'Female', 'n/a');



-- =============================================================================
-- Gold Layer Tests
-- =============================================================================

-- Check Gold view row counts
SELECT 'gold.dim_customers' AS view_name, COUNT(*) AS row_count FROM gold.dim_customers
UNION ALL
SELECT 'gold.dim_products', COUNT(*) FROM gold.dim_products
UNION ALL
SELECT 'gold.fact_sales', COUNT(*) FROM gold.fact_sales;


-- Customer surrogate key should be unique
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;


-- Customer business key should be unique
SELECT 
    customer_id,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;


-- Product surrogate key should be unique
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- Product business key should be unique
SELECT 
    product_number,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;


-- Fact sales should not have missing customer keys
SELECT *
FROM gold.fact_sales
WHERE customer_key IS NULL;


-- Fact sales should not have missing product keys
SELECT *
FROM gold.fact_sales
WHERE product_key IS NULL;


-- Sales amount should be positive
SELECT *
FROM gold.fact_sales
WHERE sales_amount <= 0;


-- Quantity should be positive
SELECT *
FROM gold.fact_sales
WHERE quantity <= 0;


-- Price should be positive
SELECT *
FROM gold.fact_sales
WHERE price <= 0;


-- Order date should not be after shipping date
SELECT *
FROM gold.fact_sales
WHERE order_date > shipping_date;


-- Order date should not be after due date
SELECT *
FROM gold.fact_sales
WHERE order_date > due_date;
