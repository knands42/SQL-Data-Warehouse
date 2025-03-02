-- Query to check for duplicates and nulls in cst_id
SELECT cst_id,
    COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1
    OR cst_id IS NULL;
-- Query to check for unwanted spaces in cst_firstname
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);
SELECT cst_lastname
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);
-- Data standardization & consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info;
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info;