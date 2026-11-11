-- Dashboard   : "B2B New Source Request Process"  [B2B / B2B Content Licensing- PAL]
-- Data source : "Source request dash test" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with tm1 as

(select company_sfdc_id,  sum(annualized_exit_rate) total_revenue from 

(WITH fact_tm1 AS (
    SELECT *
    FROM fact_external_db.tm1_fact fact_tm1
    WHERE cycle_date >>= DATE('2022-05-01')
)

, customer_names AS (
    SELECT DISTINCT
    corp_id 
	, customer AS customer_name
    FROM reference_external_db.pib_account_mapping
)

, tm1_latest_month AS (
    SELECT
    MAX(billing_date) AS billing_month
    FROM fact_tm1
)

--Monthly TM1 output - looking at month by month exit rates and one time revenue
, tm1_monthly AS (
    SELECT
    fact_tm1.billing_account_number
    , fact_tm1.corporate_id
    , sm.customer_name
    , TRIM(fact_tm1.product) AS tm1_product
    , pm.bu AS business_unit
    , fact_tm1.billing_date
    , fact_tm1.product_category
    , fact_tm1.tm1_name AS tm1_rollup_name
    , fact_tm1.tm1_rollup_category
    , fact_tm1.tm1_rollup_segment
    , fact_tm1.tm1_rollup_bu
    , fact_tm1.account_name
    , fact_tm1.country
    , fact_tm1.industry
    , fact_tm1.sales_territory
    , fact_tm1.sales_region
    , fact_tm1.cibs_id
    , fact_tm1.cibs_product
    , fact_tm1.num_user_seats
    , fact_tm1.user_trans_vol
    , SUM(fact_tm1.exit_rate) AS monthly_exit_rate
    , SUM(fact_tm1.exit_rate * 12) AS annualized_exit_rate
    , SUM(fact_tm1.total_revenue) AS total_revenue
    , SUM(fact_tm1.total_non_recurring_revenue) AS monthly_non_recurring_revenue
    , 0 AS rolling_12_month_one_time_revenue
    FROM fact_tm1
    LEFT JOIN reference_external_db.pib_product_master pm
        ON fact_tm1.product = pm.tm1_product
    LEFT JOIN customer_names sm
        ON fact_tm1.corporate_id = sm.corp_id 
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
)

, month_dates_table AS (
    SELECT
    SUBSTRING(CAST(full_date AS varchar),1,7) AS year_month
    , MIN(date_trunc('day', full_date)) AS month_start_date
    FROM reference_external_db.date_dimension
    CROSS JOIN tm1_latest_month
    WHERE full_date >>= date_trunc('month', DATE_ADD('month', -23, billing_month))
    AND full_date <<= date_trunc('month', DATE_ADD('month', 1, billing_month))
    GROUP BY 1
    ORDER BY month_start_date
)

--Displaying all tm1 items for every month. This is used to calculate the rolling 12 month average which needs month over month calculations
--Cross join of months_dates_table required because not all accounts have an entry for each month across one fiscal year.
, tm1_rolling AS (
    SELECT
    fact_tm1.billing_account_number
    , fact_tm1.corporate_id
    , customer_names.customer_name
    , fact_tm1.product AS tm1_product
    , pm.bu business_unit
    , month_dates_table.month_start_date AS billing_date
    , fact_tm1.product_category
    , fact_tm1.tm1_name AS tm1_rollup_name
    , fact_tm1.tm1_rollup_category
    , fact_tm1.tm1_rollup_segment
    , fact_tm1.tm1_rollup_bu
    , fact_tm1.account_name
    , fact_tm1.country
    , fact_tm1.industry
    , fact_tm1.sales_territory
    , fact_tm1.sales_region
    , fact_tm1.cibs_id
    , fact_tm1.cibs_product
    , fact_tm1.num_user_seats
    , fact_tm1.user_trans_vol
    , 0 AS monthly_exit_rate
    , 0 AS annualized_exit_rate
    , 0 AS total_revenue
    , 0 AS monthly_non_recurring_revenue
    , SUM(CASE
            WHEN billing_date <<= month_dates_table.month_start_date 
            AND billing_date >>= DATE(DATE_ADD('month',-11, month_dates_table.month_start_date)) 
                THEN total_non_recurring_revenue
            ELSE 0
          END) AS rolling_12_month_one_time_revenue
    FROM fact_tm1
    CROSS JOIN month_dates_table
    LEFT JOIN reference_external_db.pib_product_master pm
        ON fact_tm1.product = pm.tm1_product
    LEFT JOIN customer_names
        ON customer_names.corp_id = fact_tm1.corporate_id
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
)

, tm1_union AS (
    SELECT * FROM tm1_monthly
    UNION ALL 
    SELECT * FROM tm1_rolling
)
  
, dim_billing_account AS (
    SELECT DISTINCT
    cibs_billing_account_id
    , contract_id
    , subscription_date
    FROM dimension_external_db.pib_billing_account_dimension
)

, dim_contract AS (
    SELECT DISTINCT contract_id
    FROM dimension_external_db.pib_contract_dimension
)

, fact_pib_account AS ( 
    SELECT DISTINCT
    contract_id
    , company_sfdc_id
    FROM fact_external_db.pib_account_hierarchy_fact
)

, dim_company AS ( 
    SELECT DISTINCT
    company_name
    , company_sfdc_id
    , company_state
    FROM dimension_external_db.pib_company_dimension
)
  
, dim_corporate AS ( 
    SELECT DISTINCT
    corporate_sfdc_id
    , corporate_id
    , corporate_name
    FROM dimension_external_db.pib_corporate_dimension
)

, accounts AS (
    SELECT DISTINCT
    dim_company.company_sfdc_id
    , dim_company.company_name
    , dim_company.company_state
    , dim_billing_account.cibs_billing_account_id
    , dim_billing_account.contract_id
    FROM dim_billing_account
    LEFT JOIN dim_contract
        ON dim_billing_account.contract_id = dim_contract.contract_id
    LEFT JOIN fact_pib_account
        ON dim_contract.contract_id = fact_pib_account.contract_id
    LEFT JOIN dim_company
        ON fact_pib_account.company_sfdc_id = dim_company.company_sfdc_id
)

--Final output: unioned the tm1_monthly table with the 12 month rolling output, outputting millions of rows as a result.
SELECT
accounts.company_sfdc_id
, accounts.company_name
, REGEXP_REPLACE(accounts.company_state,'(\w)(\w*)', x ->> upper(x[1]) || lower(x[2])) AS company_state
, dim_corporate.corporate_name
, tm1_union.customer_name
, tm1_union.corporate_id
, tm1_union.billing_account_number
, tm1_union.tm1_product
, CASE 
	WHEN tm1_union.product_category = 'FINANCIAL PRODUCTS'
		THEN 'Newswires'
	ELSE tm1_union.product_category
  END AS product_category
, tm1_union.tm1_rollup_name
, tm1_union.tm1_rollup_category
, tm1_union.tm1_rollup_segment
, tm1_union.tm1_rollup_bu
, tm1_union.account_name
, tm1_union.country
, UPPER(tm1_union.industry) AS industry
, tm1_union.sales_territory
, tm1_union.sales_region
, tm1_union.cibs_id
, tm1_union.cibs_product
, tm1_union.num_user_seats
, tm1_union.user_trans_vol
, tm1_union.business_unit
, tm1_union.billing_date 
, tm1_union.monthly_exit_rate
, tm1_union.annualized_exit_rate
, tm1_union.total_revenue
, tm1_union.monthly_non_recurring_revenue
, tm1_union.rolling_12_month_one_time_revenue
FROM tm1_union 
LEFT JOIN accounts
    ON accounts.cibs_billing_account_id = tm1_union.billing_account_number
LEFT JOIN dim_corporate
    ON dim_corporate.corporate_id = tm1_union.corporate_id)
    
    where tm1_rollup_bu = 'Factiva'
    and billing_date = (select MAX(billing_date) from fact_external_db.tm1_fact) 
    group by 1)




select case_number, id, created_date, type, product_level_1, product_level_2, case_sub_type, priority, status,
contact_user_id, mem.billing_account_id, comp.company_name, comp.company_sfdc_id, round(tm1.total_revenue,0) as annualized_revenue, customer_company_name, customer_first_name, customer_last_name, customer_country_location,
source_name1, source_language, source_url, source_country, source_industry, source_priority, source_publisher, source_description, 
web_source_code, substatus_2, web_substatus, source_justification_overview_additional, r_c_relevant

from dimension_external_db.pib_customer_service_case_dimension cs
left join dimension_external_db.pib_membership_dimension mem on cs.contact_user_id = mem.user_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join tm1 on comp.company_sfdc_id = tm1.company_sfdc_id
where type = 'Content Suggestion'
and source_name1 is not null
and lower(source_name1) not like '%test%'
and lower(source_justification_overview_additional) not like '%test%'
and  contact_user_id not like 'prod%'
and cs.status_flag <<>> 'DELETE'
