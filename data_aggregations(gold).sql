CREATE or replace TABLE NAICS_Codes (
    code VARCHAR(6) PRIMARY KEY,
    description varchar
);

select * from NAICS_Codes;

-- loan count, total and average loan amount per state
SELECT 
    borr_state,
    COUNT(lender_id) AS total_loans,
    SUM(REPLACE(gross_approval, ',', '')::FLOAT) AS total_funded_amount,
    AVG(REPLACE(gross_approval, ',', '')::FLOAT) AS avg_loan_size
FROM project.analysis.silver_sba_loans
GROUP BY borr_state
ORDER BY total_funded_amount DESC;


-- top 5 business type with highest loan count and approved gross amount
SELECT 
    naics_description,
    business_type,
    COUNT(*) AS loan_count,
    SUM(REPLACE(gross_approval, ',', '')::FLOAT) AS total_volume
FROM project.analysis.silver_sba_loans
GROUP BY 1, 2
ORDER BY total_volume DESC
LIMIT 5;


-- total borrower and lender per state
SELECT
    borr_state AS state,
    COUNT(DISTINCT borrower_name) AS total_borrowers,
    COUNT(DISTINCT thirdpartylender_name) AS total_lenders
FROM silver_sba_loans
GROUP BY 1
ORDER BY state;


-- market share of lenders
SELECT 
    lender_id,
    COUNT(distinct(lender_id)) AS number_of_loans,
    SUM(REPLACE(gross_approval_num, ',', '')::FLOAT) AS total_loan_value,
    (total_loan_value / SUM(total_loan_value) OVER()) * 100 AS market_share_percentage
FROM project.analysis.silver_sba_loans
GROUP BY lender_id
ORDER BY total_loan_value DESC;

-- lender with multiple loans
SELECT
  lender_id,
  COUNT(*) AS duplicate_count
FROM
  bronze_sba_loans
GROUP BY
  lender_id
HAVING
  COUNT(*) > 1;


-- add column to review gold layer changes timestamp
ALTER TABLE bronze_sba_loans ADD COLUMN gold_layer_processed TIMESTAMP_NTZ;
ALTER TABLE silver_sba_loans ADD COLUMN gold_layer_processed TIMESTAMP_NTZ;

-- add current timestamp to silver layer process
update silver_sba_loans
set gold_layer_processed = CURRENT_TIMESTAMP;

select * from silver_sba_loans;

-- loan count by business age
select business_age,
       count(lender_id) as total_loans
from silver_sba_loans
group by 1
order by total_loans desc;