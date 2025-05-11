-- Check rows where prd_key is not available in the FK table
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_prd_key NOT IN (select prd_key from silver.crm_prd_info);

-- Check rows where cust_id is not available in the FK table
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_cust_id NOT IN (select cst_id from silver.crm_cust_info);

-- Check for nulls in order date
SELECT NULLIF(sls_order_dt, 0) AS sls_order_dt 
FROM bronze.crm_sales_details 
WHERE sls_order_dt <= 0
OR sls_order_dt > 20500101
OR sls_order_dt < 19000101;

-- Check if order date is always before ship date
SELECT sls_order_dt 
FROM bronze.crm_sales_details 
WHERE sls_order_dt > sls_ship_dt
OR sls_order_dt > sls_due_dt;

SELECT 
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL
OR sls_quantity IS NULL
OR sls_price IS NULL
OR sls_sales = 0
OR sls_quantity = 0
OR sls_price = 0
ORDER BY sls_quantity, sls_quantity, sls_price;