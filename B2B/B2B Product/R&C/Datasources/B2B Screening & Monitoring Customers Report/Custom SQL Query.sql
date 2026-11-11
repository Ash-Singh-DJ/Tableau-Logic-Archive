-- Published data source : "B2B Screening & Monitoring Customers Report"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select cibs_billing_account_id, period, company_name, name,product_description, transaction_volume, names_screened 
from google_sheets_db.rc_batch_screening_cdp_data_unpivot
where period >>= date('2024-01-01')
