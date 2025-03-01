-- Check for nulls or duplicates in PK
-- Expectation: No Result

/*
Script Purpose:
    1. Check for duplicates in cst_id
    2. Check for nulls in cst_id
    3. Check for unwanted spaces in cst_firstname
    4. Check for unwanted spaces in cst_lastname
    5. Provide a meaningful name for cst_martial_status
    6. Provide a meaningful name for cst_gndr
*/

INSERT INTO silver.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)

SELECT
    cst_id,
    cst_key,
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname) AS cst_lastname,
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END cst_marItal_status,
    CASE 
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END cst_gndr,
    cst_create_date
FROM (
    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date) AS flag_last
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL
) t WHERE flag_last = 1;

