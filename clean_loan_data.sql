create or replace table project.analysis.BRONZE_SBA_LOANS
( 
    record_date varchar,
    program varchar,
    lender_id number,
    borrower_name varchar,
    borr_street varchar,
    borr_city varchar,
    borr_state varchar,
    borr_zip varchar,
    cdc_name varchar,   --Certified Development Company
    cdc_street varchar,
    cdc_city varchar,
    cdc_state varchar,
    cdc_zip varchar, 
    thirdPartyLender_Name varchar, --third party lender name
    thirdPartyLender_city varchar,
    thirdPartyLender_state varchar,
    thirdparty_amount varchar,
    gross_approval varchar,
    approval_date varchar,
    approval_fiscal_year varchar,
    FirstDisbursement_date varchar,
    loan_term_months varchar,
    SBA_district_office varchar,
    business_type varchar,
    business_age varchar,
    loan_status varchar,
    paidfull_date varchar,
    jobs_supported varchar,
    collateral varchar 
);


select * from BRONZE_SBA_LOANS;

-- add a new column with years count for total loan term
ALTER TABLE bronze_sba_loans 
ADD COLUMN loan_term_years NUMBER(10,2) 
AS (ROUND(loan_term_months / 12.0, 2));


-- update null values in business type column
update bronze_sba_loans 
set business_type = 'Not Described' 
where business_type is null;


-- add metadata to see when records were loaded
ALTER TABLE bronze_sba_loans ADD COLUMN load_metadata_time TIMESTAMP_NTZ;

update bronze_sba_loans
set load_metadata_time = CURRENT_TIMESTAMP;

-- confirm lender id is unique
SELECT lender_id, COUNT()
FROM bronze_sba_loans
GROUP BY 1 HAVING COUNT() > 1;

-- to review currency with thousand saperator and $
SELECT lender_id, borrower_name, to_char(thirdparty_amount:: number,'FM$999,999,999.99') as amount
FROM bronze_sba_loans;



