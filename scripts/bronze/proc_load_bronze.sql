CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql
AS $$
DECLARE
    -- Timing variables
    v_start_time TIMESTAMP;      -- Overall procedure start time
    v_stop_time TIMESTAMP;       -- Time at each measurement point
    v_operation_start TIMESTAMP; -- Start time for each load operation
    v_operation_duration INTERVAL; -- Duration of each operation
    v_duration_ms NUMERIC;       -- Duration in milliseconds
BEGIN
    v_start_time := CURRENT_TIMESTAMP;
    
    BEGIN -- Start error handling block
        RAISE NOTICE '===============================================';
        RAISE NOTICE 'Starting bronze layer data load at %', v_start_time;
        RAISE NOTICE '===============================================';

        RAISE NOTICE '-----------------------------------------------';
        RAISE NOTICE 'Loading CRM Tables';
        RAISE NOTICE '-----------------------------------------------';

        -- CRM Customer Info
        v_operation_start := CURRENT_TIMESTAMP;
        RAISE NOTICE 'Truncating CRM customer data...';
        TRUNCATE TABLE bronze.crm_cust_info;

        RAISE NOTICE 'Loading CRM customer info...';
        COPY bronze.crm_cust_info
        FROM '/datasets/source_crm/cust_info.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',');
        v_stop_time := CURRENT_TIMESTAMP;
        v_operation_duration := age(v_stop_time, v_operation_start);
        v_duration_ms := (EXTRACT(epoch FROM v_operation_duration) * 1000)::NUMERIC(10,2);
        RAISE NOTICE 'CRM customer info loaded successfully (Time: % ms)', v_duration_ms;

        -- CRM Product Info
        v_operation_start := CURRENT_TIMESTAMP;
        RAISE NOTICE 'Truncating CRM product data...';
        TRUNCATE TABLE bronze.crm_prd_info;

        RAISE NOTICE 'Loading CRM product info...';
        COPY bronze.crm_prd_info
        FROM '/datasets/source_crm/prd_info.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',');
        v_stop_time := CURRENT_TIMESTAMP;
        v_operation_duration := age(v_stop_time, v_operation_start);
        v_duration_ms := (EXTRACT(epoch FROM v_operation_duration) * 1000)::NUMERIC(10,2);
        RAISE NOTICE 'CRM product info loaded successfully (Time: % ms)', v_duration_ms;

        -- CRM Sales Details
        v_operation_start := CURRENT_TIMESTAMP;
        RAISE NOTICE 'Truncating CRM sales details data...';
        TRUNCATE TABLE bronze.crm_sales_details;

        RAISE NOTICE 'Loading CRM sales details...';
        COPY bronze.crm_sales_details
        FROM '/datasets/source_crm/sales_details.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',');
        v_stop_time := CURRENT_TIMESTAMP;
        v_operation_duration := age(v_stop_time, v_operation_start);
        v_duration_ms := (EXTRACT(epoch FROM v_operation_duration) * 1000)::NUMERIC(10,2);
        RAISE NOTICE 'CRM sales details loaded successfully (Time: % ms)', v_duration_ms;

        RAISE NOTICE '-----------------------------------------------';
        RAISE NOTICE 'Loading ERP Tables';
        RAISE NOTICE '-----------------------------------------------';

        -- ERP Customer Data
        v_operation_start := CURRENT_TIMESTAMP;
        RAISE NOTICE 'Truncating ERP customer data...';
        TRUNCATE TABLE bronze.erp_cust_az12;

        RAISE NOTICE 'Loading ERP customer data...';
        COPY bronze.erp_cust_az12
        FROM '/datasets/source_erp/CUST_AZ12.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',');
        v_stop_time := CURRENT_TIMESTAMP;
        v_operation_duration := age(v_stop_time, v_operation_start);
        v_duration_ms := (EXTRACT(epoch FROM v_operation_duration) * 1000)::NUMERIC(10,2);
        RAISE NOTICE 'ERP customer data loaded successfully (Time: % ms)', v_duration_ms;

        -- ERP Location Data
        v_operation_start := CURRENT_TIMESTAMP;
        RAISE NOTICE 'Truncating ERP location data...';
        TRUNCATE TABLE bronze.erp_loc_a101;

        RAISE NOTICE 'Loading ERP location data...';
        COPY bronze.erp_loc_a101
        FROM '/datasets/source_erp/LOC_A101.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',');
        v_stop_time := CURRENT_TIMESTAMP;
        v_operation_duration := age(v_stop_time, v_operation_start);
        v_duration_ms := (EXTRACT(epoch FROM v_operation_duration) * 1000)::NUMERIC(10,2);
        RAISE NOTICE 'ERP location data loaded successfully (Time: % ms)', v_duration_ms;

        -- ERP PX Data
        v_operation_start := CURRENT_TIMESTAMP;
        RAISE NOTICE 'Truncating ERP PX data...';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        
        RAISE NOTICE 'Loading ERP PX category data...';
        COPY bronze.erp_px_cat_g1v2
        FROM '/datasets/source_erp/PX_CAT_G1V2.csv'
        WITH (FORMAT csv, HEADER true, DELIMITER ',');
        v_stop_time := CURRENT_TIMESTAMP;
        v_operation_duration := age(v_stop_time, v_operation_start);
        v_duration_ms := (EXTRACT(epoch FROM v_operation_duration) * 1000)::NUMERIC(10,2);
        RAISE NOTICE 'ERP PX category data loaded successfully (Time: % ms)', v_duration_ms;

        -- Calculate total execution time
        v_stop_time := CURRENT_TIMESTAMP;
        v_operation_duration := age(v_stop_time, v_start_time);
        v_duration_ms := (EXTRACT(epoch FROM v_operation_duration) * 1000)::NUMERIC(10,2);

        RAISE NOTICE '===============================================';
        RAISE NOTICE 'Bronze layer data load completed successfully';
        RAISE NOTICE 'Total execution time: % ms', v_duration_ms;
        RAISE NOTICE '===============================================';

    EXCEPTION 
        WHEN OTHERS THEN
            v_stop_time := CURRENT_TIMESTAMP;
            v_operation_duration := age(v_stop_time, v_start_time);
            v_duration_ms := (EXTRACT(epoch FROM v_operation_duration) * 1000)::NUMERIC(10,2);
            
            RAISE NOTICE '===============================================';
            RAISE NOTICE 'ERROR: Bronze layer load failed!';
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE NOTICE 'Error Detail: %', SQLERRM;
            RAISE NOTICE 'Execution time until error: % ms', v_duration_ms;
            RAISE NOTICE '===============================================';
            RAISE EXCEPTION '%', SQLERRM;
    END;
END;
$$;

CALL bronze.load_bronze()