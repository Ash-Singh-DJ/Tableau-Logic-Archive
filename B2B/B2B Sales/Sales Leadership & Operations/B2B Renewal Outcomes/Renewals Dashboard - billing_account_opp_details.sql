-- Dashboard   : "B2B Renewal Outcomes"  [B2B / B2B Sales / Sales Leadership & Operations]
-- Data source : "Renewals Dashboard" = published source "B2B Renewal Outcomes - Data Source"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "billing_account_opp_details"
-- Connection  : Athena (AwsDataCatalog / sandbox_spb), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH opp_fn AS (
    SELECT DISTINCT
    monthly_snapshot_date
    , sfdc_contract_id
    , contract_id
    , opportunity_number
    , pib_opportunity_sfdc_id
    , opportunity_vs_Renewal_month_delta
    , adj_renewal_trunc
    , SUM(tm1.previous_month_annualized_exit_rate) AS pre_renewal_revenue
    FROM sandbox_gazzanom.fact_renewals fn
    LEFT JOIN sandbox_spb.tm1_renewals tm1
        ON DATE_ADD('month',-1,fn.adj_renewal_trunc) = tm1.billing_date
        AND fn.billing_account_id = tm1.billing_account_number
    GROUP BY 1,2,3,4,5,6,7
)


, detail_union AS (
    SELECT
    fn.monthly_snapshot_date AS monthly_snapshot_date
    , 'Billing Account' AS record_type
    , fn.contract_id
    , fn.sfdc_contract_id
    , fn.billing_account_id AS record_type_identifier
    , bad.salesforce_billing_account_id AS record_type_system_id
    , CAST(NULL AS DATE) AS opportunity_effective_date
    , CAST(NULL AS REAL) AS probability_percentage
    , CAST(NULL AS INTEGER) AS opportunity_vs_renewal_month_delta
    , SUM(annualized_exit_rate) AS post_renewal_revenue
    FROM sandbox_gazzanom.fact_renewals fn
    INNER JOIN sandbox_spb.tm1_renewals tm1
        ON fn.billing_account_id = tm1.billing_account_number
        AND DATE_ADD('month',-1,fn.adj_renewal_trunc) = tm1.billing_date
    LEFT JOIN (SELECT DISTINCT cibs_billing_account_id, salesforce_billing_account_id FROM dimension_external_db.pib_billing_account_dimension) bad
        ON tm1.billing_account_number = bad.cibs_billing_account_id
    WHERE fn.contract_id IS NOT NULL
    GROUP BY 1,2,3,4,5,6
       
    UNION ALL
    
    SELECT
    fn.monthly_snapshot_date
    , 'Opportunity' AS record_type
    , fn.contract_id
    , fn.sfdc_contract_id
    , CAST(fn.opportunity_number AS VARCHAR) AS record_type_identifier
    , fn.pib_opportunity_sfdc_id AS record_type_system_id
    , dim_opp.opportunity_effective_date
    , (dim_opp.probability_percentage / 100) AS probability_percentage
    , fn.opportunity_vs_renewal_month_delta
    , SUM(dim_opp.annualized_opportunity_revenue / dim_fx.rate) AS post_renewal_revenue
    FROM opp_fn fn
    LEFT JOIN dimension_external_db.pib_opportunity_dimension dim_opp
        ON fn.pib_opportunity_sfdc_id = dim_opp.pib_opportunity_sfdc_id
    LEFT JOIN reference_external_db.fx_rates_current dim_fx
        ON dim_opp.currency_iso_code = dim_fx.currency
    WHERE dim_opp.probability_percentage IN (99.0,100.0)
    GROUP BY 1,2,3,4,5,6,7,8,9
)

SELECT
du.*
--Count Distinct Window function of the record_type field. Partitioned by snapshot_date and contract_id.
, CASE
    WHEN (DENSE_RANK() OVER (PARTITION BY monthly_snapshot_date, contract_id ORDER BY record_type ASC)
    + (DENSE_RANK() OVER (PARTITION BY monthly_snapshot_date, contract_id ORDER BY record_type DESC) - 1)) >> 1
        THEN TRUE
    ELSE FALSE
END AS multiple_record_types
FROM detail_union du
