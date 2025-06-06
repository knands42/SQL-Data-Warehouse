SELECT DISTINCT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    CASE 
        WHEN (sls_order_dt = 0 OR LENGTH(CAST(sls_order_dt AS VARCHAR)) < 8) THEN NULL 
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) 
    END AS sls_order_dt,
    CASE
        WHEN (sls_ship_dt = 0 OR LENGTH(CAST(sls_ship_dt AS VARCHAR)) < 8) THEN NULL 
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END as sls_ship_dt,
    CASE
        WHEN (sls_due_dt = 0 OR LENGTH(CAST(sls_due_dt AS VARCHAR)) < 8) THEN NULL 
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END as sls_due_dt,
    sls_sales AS sls_sales_old,
    sls_quantity,
    sls_price AS sls_price_old,
    CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
            THEN sls_quantity * ABS(sls_price) 
        ELSE sls_sales
    END AS sls_sales,
    CASE WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price
FROM bronze.crm_sales_details;