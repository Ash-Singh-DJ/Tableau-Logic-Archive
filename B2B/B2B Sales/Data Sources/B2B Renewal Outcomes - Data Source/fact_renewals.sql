-- Published data source : "B2B Renewal Outcomes - Data Source"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "fact_renewals"
-- Connection  : Athena (AwsDataCatalog / sandbox_spb), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH billing_account_pre_renewal AS (
    SELECT
    fn.monthly_snapshot_date
    , fn.sfdc_contract_id
    , fn.sfdc_billing_account_territory_id
    , fn.billing_account_territory
    , SUM(COALESCE(tm1.previous_month_annualized_exit_rate,0)) AS tm1_pre_renewal_revenue
    FROM sandbox_spb.fact_renewals fn
    LEFT JOIN sandbox_spb.tm1_renewals tm1
        ON fn.billing_account_id = tm1.billing_account_number
        AND DATE_ADD('month',-1,fn.adj_renewal_trunc) = tm1.billing_date
    GROUP BY 1,2,3,4
)

, max_bill_account_pre_renewal AS (
    SELECT DISTINCT
    monthly_snapshot_date
    , sfdc_contract_id
    , sfdc_billing_account_territory_id
    , billing_account_territory
    , tm1_pre_renewal_revenue
    , MAX(tm1_pre_renewal_revenue) OVER (PARTITION BY monthly_snapshot_date, sfdc_contract_id) AS max_tm1_pre_renewal_revenue
    FROM billing_account_pre_renewal
)

, contract_territories AS (
    SELECT DISTINCT
    monthly_snapshot_date
    , sfdc_contract_id
    , sfdc_billing_account_territory_id AS contract_territory_id
    , billing_account_territory AS contract_territory
    FROM max_bill_account_pre_renewal
    WHERE tm1_pre_renewal_revenue = max_tm1_pre_renewal_revenue
)

, fn AS (
    SELECT DISTINCT
    monthly_snapshot_date
    , sfdc_contract_id
    , billing_account_id
    , company_sfdc_id
    , company_name
    , contract_id
    , contract_renewal_date
    , adjusted_contract_renewal_date
    , salesforce_auto_renewal_flag
    , adj_renewal_trunc
    , opportunity_qty_on_contract
    FROM sandbox_gazzanom.fact_renewals
)

SELECT DISTINCT
fn.monthly_snapshot_date
, fn.sfdc_contract_id
, fn.company_sfdc_id
, fn.company_name
, fn.contract_id
, fn.contract_renewal_date
, fn.adjusted_contract_renewal_date
, fn.salesforce_auto_renewal_flag
, fn.adj_renewal_trunc AS tm1_billing_month
, fn.opportunity_qty_on_contract
, ct.contract_territory_id
, ct.contract_territory
, comp.company_industry
, REGEXP_REPLACE(comp.company_state,'(\w)(\w*)', x ->> upper(x[1]) || lower(x[2])) AS company_state
, REGEXP_REPLACE(comp.company_country,'(\w)(\w*)', x ->> upper(x[1]) || lower(x[2])) AS company_country
, ter_owner.user_full_name AS territory_owner
, rsd.user_full_name AS rsd
, CASE
    WHEN fn.adj_renewal_trunc <<= (SELECT MAX(cycle_date) FROM fact_external_db.tm1_fact)
        THEN TRUE
    ELSE FALSE
  END AS tm1_month_available
, SUM(tm1.previous_month_annualized_exit_rate) AS pre_renewal_revenue
, SUM(tm1.annualized_exit_rate) AS tm1_post_renewal_revenue
, CASE
    WHEN SUM(tm1.annualized_exit_rate) IS NOT NULL
        THEN TRUE
    ELSE FALSE
  END AS has_post_renewal_revenue
FROM fn
LEFT JOIN contract_territories ct
    ON fn.monthly_snapshot_date = ct.monthly_snapshot_date
    AND fn.sfdc_contract_id = ct.sfdc_contract_id
LEFT JOIN sandbox_spb.tm1_renewals tm1
    ON DATE_ADD('month',-1,fn.adj_renewal_trunc) = tm1.billing_date
    AND fn.billing_account_id = tm1.billing_account_number
LEFT JOIN dimension_external_db.pib_territory_dimension ter
    ON ct.contract_territory_id = ter.territory_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension ter_owner
    ON ter.territory_owner = ter_owner.user_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension rsd
    ON ter_owner.manager_id = rsd.user_sfdc_id
LEFT JOIN dimension_external_db.pib_company_dimension comp
    ON fn.company_sfdc_id = comp.company_sfdc_id
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
HAVING ABS(SUM(tm1.previous_month_annualized_exit_rate)) >> 0 --Billed in Previous Month
