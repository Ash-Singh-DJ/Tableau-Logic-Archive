-- Published data source : "Sales API Lite 11212025"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "TM1 Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select billing_account_number, company_sfdc_id, company_name, coalesce(sum(CASE when product_category in ('DJX', 'CORPORATE PRODUCTS') then annualized_exit_rate end),0) factiva_total_recurring, 
coalesce(sum(CASE when product_category in ('DJX', 'CORPORATE PRODUCTS') then rolling_12_month_one_time_revenue end),0) factiva_total_one_time,
coalesce(sum(CASE when product_category = 'Risk & Compliance' then annualized_exit_rate end),0) rc_total_recurring, 
coalesce(sum(CASE when product_category = 'Risk & Compliance' then rolling_12_month_one_time_revenue end),0) rc_total_one_time 

from (

WITH fact_tm1 AS (
    SELECT *
    FROM fact_external_db.tm1_fact fact_tm1
    WHERE cycle_date >>= DATE('2020-01-01')
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
    , comp.company_sfdc_id 
    , comp.company_name 
    , sm.customer_name
    , TRIM(fact_tm1.product) AS tm1_product
    , pm.bu AS business_unit
    , fact_tm1.billing_date
    , fact_tm1.product_category
    , fact_tm1.tm1_name AS tm1_rollup_name
    , fact_tm1.tm1_rollup_bu
    , fact_tm1.account_name
    , fact_tm1.cibs_id
    , fact_tm1.cibs_product
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
    left join dimension_external_db.pib_billing_account_dimension bill
    on fact_tm1.billing_account_number = bill.cibs_billing_account_id 
    left join dimension_external_db.pib_company_dimension comp
      on bill.salesforce_company_two = comp.company_sfdc_id 
        
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
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
    , comp.company_sfdc_id 
    , comp.company_name 
    , customer_names.customer_name
    , fact_tm1.product AS tm1_product
    , pm.bu business_unit
    , month_dates_table.month_start_date AS billing_date
    , fact_tm1.product_category
    , fact_tm1.tm1_name AS tm1_rollup_name
    , fact_tm1.tm1_rollup_bu
    , fact_tm1.account_name
    , fact_tm1.cibs_id
    , fact_tm1.cibs_product
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
        left join dimension_external_db.pib_billing_account_dimension bill
    on fact_tm1.billing_account_number = bill.cibs_billing_account_id 
    left join dimension_external_db.pib_company_dimension comp
      on bill.salesforce_company_two = comp.company_sfdc_id     
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
)

    SELECT * FROM tm1_monthly
    UNION ALL 
    SELECT * FROM tm1_rolling)
    where billing_date = (select max(billing_date) from fact_external_db.tm1_fact)    
 --and company_sfdc_id = '0017000000d7RgVAAU'
        group by 1,2,3
