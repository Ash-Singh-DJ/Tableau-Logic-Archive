-- Published data source : "User Level data by Account"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query4"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH dim_contracts AS (
    SELECT
    *
    , MAX(salesforce_last_modified_date) OVER (PARTITION BY salesforce_id) AS max_modified_date
    , MAX(last_change_date) OVER (PARTITION BY salesforce_id) AS max_change_date
    FROM dimension_external_db.pib_contract_dimension
)

, ctr AS (
    SELECT
    ctr.*
    , CASE 
        WHEN ctr.salesforce_renewal_date  << CURRENT_DATE
        THEN DATE_ADD('year'
                     , DATE_DIFF('year',ctr.salesforce_renewal_date,CURRENT_DATE) + 1
                     , ctr.salesforce_renewal_date)
        ELSE ctr.salesforce_renewal_date
      END AS adjusted_renewal_date
    FROM dim_contracts ctr
    WHERE salesforce_last_modified_date = max_modified_date
    AND last_change_date = max_change_date
)

, tm1_rollup_prelim AS (
    SELECT DISTINCT
    billing_date
    , cibs_id
    , MAX(billing_date) OVER (PARTITION BY cibs_id) AS max_rollup_billing_date
    , tm1_name AS tm1_rollup_name
    , tm1_rollup_category
    , tm1_rollup_segment
    , tm1_rollup_bu
    FROM fact_external_db.tm1_fact fact_tm1
    WHERE cycle_date >>= DATE('2022-07-01') --Product rollup start date
    AND cibs_id != '0000'
    AND cibs_id IS NOT NULL
    AND tm1_name IS NOT NULL
)

, tm1_product_rollup AS (
    SELECT
    billing_date AS rollup_billing_date --Denotes which month of tm1 the rollup values are taken, always most recent month available.
    , cibs_id
    , tm1_rollup_name
    , tm1_rollup_category
    , tm1_rollup_segment
    , tm1_rollup_bu
    FROM tm1_rollup_prelim
    WHERE billing_date = max_rollup_billing_date
)

, calendar_fiscal (fiscal_month_number, calendar_month_number, calendar_year_delta) AS 
    (VALUES (1,7,-1)
            , (2,8,-1)
            , (3,9,-1)
            , (4,10,-1)
            , (5,11,-1)
            , (6,12,-1)
            , (7,1,0)
            , (8,2,0)
            , (9,3,0)
            , (10,4,0)
            , (11,5,0)
            , (12,6,0)
)

, billing_month_dates AS (
	SELECT DISTINCT
	DATE(CONCAT(CAST(dd.fiscal_year + cf.calendar_year_delta AS VARCHAR),'-',CAST(calendar_month_number AS VARCHAR),'-01')) AS billing_month
	, CONCAT('FY',CAST(dd.fiscal_year AS VARCHAR)) AS fiscal_year
	, fiscal_month_name
	FROM reference_external_db.date_dimension dd
	LEFT JOIN calendar_fiscal cf
	    ON dd.month_number_in_fiscal_year = cf.fiscal_month_number
)

, contract_core AS (
    SELECT
    tm.cycle_date AS tm1_billing_date
    , ctr.contract_id AS contract_id
    , ctr.salesforce_id AS salesforce_contract_id
    , bad.salesforce_billing_account_id
    , bad.salesforce_account_number AS billing_account_number
    , bad.salesforce_cancel_ovr_date
    , cd.company_name
    , ctr.salesforce_effective_date AS contract_effective_date
    , ctr.salesforce_renewal_date AS contract_renewal_date
    , ctr.adjusted_renewal_date
    , ctr.salesforce_cancellation_terms_months AS salesforce_cancellation_terms_days
    , DATE_ADD('day',COALESCE(ctr.salesforce_cancellation_terms_months,0) * -1,ctr.adjusted_renewal_date) AS action_required_date
    , cast (ctr.salesforce_term_length_months as varchar) as salesforce_term_length_m
    , ctr.salesforce_auto_renewal_flag
    , td.territory_name AS billing_account_territory
    , usr.user_full_name AS territory_owner
    , rsd_usr.user_full_name AS territory_sales_director
    , tm.customer_name AS tm1_customer_name
    , tm.account_name AS tm1_account_name
    , tm.cibs_product 
    , tm.product AS tm1_legacy_product
    , tpr.tm1_rollup_name
    , REPLACE(REGEXP_REPLACE(
      CASE
        WHEN tpr.tm1_rollup_name IS NOT NULL
            THEN tpr.tm1_rollup_name
        ELSE tm.product END
      ,'(\w)(\w*)', x ->> upper(x[1]) || lower(x[2])),'.Com','.com') AS tm1_product
    , tpr.tm1_rollup_category
    , tpr.tm1_rollup_segment
    , CASE
        WHEN tpr.tm1_rollup_bu = 'Risk'
            THEN 'R&C'
        ELSE tpr.tm1_rollup_bu
      END AS tm1_rollup_bu
    , tm.product_category AS tm1_legacy_product_category
    , tm.Sales_territory AS tm1_sales_territory
    , tm.num_user_seats 
    , tm.exit_rate
    , (tm.exit_rate * 12) AS annualized_exit_rate
    , SUM(tm.exit_rate) OVER (PARTITION BY bad.salesforce_account_number) AS billing_account_exit_rate
    , SUM(tm.exit_rate * 12) OVER (PARTITION BY ctr.contract_id) AS contract_exit_rate
    , ctr.salesforce_current_monthly_revenue_usd
    , bad.salesforce_current_month_exit_rate
    , MAX(tm.exit_rate) OVER (PARTITION BY ctr.contract_id) AS max_er_at_contract
    FROM ctr
    LEFT JOIN dimension_external_db.pib_billing_account_dimension bad
        ON bad.contract_id = ctr.contract_id
    LEFT JOIN dimension_external_db.pib_territory_dimension td
        ON ctr.salesforce_territory = td.territory_sfdc_id
    LEFT JOIN dimension_external_db.pib_territory_dimension ba_td
        ON bad.salesforce_territory = ba_td.territory_sfdc_id
    LEFT JOIN dimension_external_db.pib_user_dimension usr
        ON td.territory_owner = usr.user_sfdc_id
    LEFT JOIN dimension_external_db.pib_user_dimension rsd_usr
        ON td.regional_sales_director = rsd_usr.user_sfdc_id
    LEFT JOIN dimension_external_db.pib_company_dimension cd
        ON bad.salesforce_company_two = cd.company_sfdc_id
    LEFT JOIN fact_external_db.tm1_fact tm
        ON SUBSTRING(tm.billing_account_number, 1, 10) = bad.cibs_billing_account_id
    LEFT JOIN tm1_product_rollup tpr
        ON tm.cibs_id = tpr.cibs_id
    WHERE (LOWER(bad.account_sales_territory) NOT LIKE '%bd%'
    AND LOWER(bad.account_sales_territory) NOT LIKE '%wsj%'
    AND LOWER(bad.account_sales_territory) NOT LIKE  '%fnpen%'
    AND LOWER(td.territory_name) NOT LIKE '%bd%'
    AND LOWER(td.territory_name) NOT LIKE '%wsj%'
    AND LOWER(td.territory_name) NOT LIKE  '%fnpen%'
    OR bad.account_sales_territory IS NULL OR td.territory_name IS NULL)
    AND tm.cycle_date = (SELECT MAX (cycle_date) FROM fact_external_db.tm1_fact)
)

SELECT 
cc.*
, cc_terr.billing_account_territory AS contract_territory
, CASE
    WHEN cc.billing_account_exit_rate >> 1
        THEN TRUE
    ELSE FALSE
  END AS ba_amount_greater_than_one
, bmd_tm1.fiscal_year AS billing_month_fiscal_year
, bmd_ced.fiscal_year AS contract_effective_date_fiscal_year
, bmd_crd.fiscal_year AS contract_renewal_date_fiscal_year
, bmd_ard.fiscal_year AS adjusted_renewal_date_fiscal_year
, bmd_ard.fiscal_month_name AS adjusted_renewal_month
, bmd_arqd.fiscal_year AS action_required_date_fiscal_year
, bmd_arqd.fiscal_month_name AS action_required_month
FROM contract_core cc
LEFT JOIN (SELECT * FROM contract_core WHERE max_er_at_contract = exit_rate) cc_terr
    ON cc.contract_id = cc_terr.contract_id
LEFT JOIN billing_month_dates bmd_tm1
	ON bmd_tm1.billing_month = cc.tm1_billing_date
LEFT JOIN billing_month_dates bmd_ced
	ON bmd_ced.billing_month = DATE_TRUNC('month',cc.contract_effective_date)
LEFT JOIN billing_month_dates bmd_crd
	ON bmd_crd.billing_month = DATE_TRUNC('month',cc.contract_renewal_date)
LEFT JOIN billing_month_dates bmd_ard
	ON bmd_ard.billing_month = DATE_TRUNC('month',cc.adjusted_renewal_date)
LEFT JOIN billing_month_dates bmd_arqd 
	ON bmd_arqd.billing_month = DATE_TRUNC('month',cc.action_required_date)
