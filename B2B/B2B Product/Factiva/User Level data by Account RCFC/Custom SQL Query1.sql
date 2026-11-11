-- Published data source : "User Level data by Account RCFC"  [B2B / B2B Product / Factiva]
-- Relation    : Custom SQL "Custom SQL Query1"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT ba.cibs_billing_account_id,  
        cib.transaction_volume,
        cib.start_date, 
        ubo.*
FROM dimension_external_db.pib_cibs_billing_charges_dimension cib
LEFT JOIN dimension_external_db.pib_billing_account_dimension ba ON ba.salesforce_billing_account_id = cib.cibs_billing_account 
left join google_sheets_db.ubo_usage_monthly_unpivot ubo on ba.cibs_billing_account_id = ubo.billing_account 

WHERE product_id = 'UBOW' and current_chg = 'Current'
