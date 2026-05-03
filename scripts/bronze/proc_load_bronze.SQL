/*
=====================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=====================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the BULK INSERT command to load data from CSV files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;

=====================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    BEGIN TRY
        DECLARE @starttime DATETIME, @endtime DATETIME;
        DECLARE @batch_start_time DATETIME, @batch_end_time DATETIME;

        SET @batch_start_time = GETDATE();

        PRINT '====================================================';
        PRINT '              Loading Bronze Layer                  ';
        PRINT '====================================================';

        ----------------------------------------------------
        -- CRM TABLES
        ----------------------------------------------------
        PRINT '----------------------------------------------------';
        PRINT '              Loading CRM Tables                    ';
        PRINT '----------------------------------------------------';

        -- crm_cust_info
        SET @starttime = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT '>> Inserting Data Into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @endtime = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------';

        -- crm_prd_info
        SET @starttime = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT '>> Inserting Data Into: bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @endtime = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------';

        -- crm_sales_details
        SET @starttime = GETDATE();

        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT '>> Inserting Data Into: bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @endtime = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------';

        ----------------------------------------------------
        -- ERP TABLES
        ----------------------------------------------------
        PRINT '----------------------------------------------------';
        PRINT '              Loading ERP Tables                    ';
        PRINT '----------------------------------------------------';

        -- erp_loc_a101
        SET @starttime = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\sql-data-warehouse-project\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @endtime = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------';

        -- erp_cust_az12
        SET @starttime = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\sql-data-warehouse-project\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @endtime = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------';

        -- erp_px_cat_g1v2
        SET @starttime = GETDATE();

        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\sql-data-warehouse-project\datasets\source_erp\px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @endtime = GETDATE();

        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @starttime, @endtime) AS NVARCHAR) + ' seconds';
        PRINT '----------------------------------------------------';

        SET @batch_end_time = GETDATE();

        PRINT '====================================================';
        PRINT '         Bronze Layer Loading Completed ✅           ';
        PRINT '>> Whole Batch Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
        PRINT '====================================================';

    END TRY

    BEGIN CATCH
        PRINT '====================================================';
        PRINT 'ERROR OCCURRED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '====================================================';
    END CATCH;
END;
