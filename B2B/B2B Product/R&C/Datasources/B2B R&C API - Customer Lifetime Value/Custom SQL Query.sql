-- Published data source : "B2B R&C API - Customer Lifetime Value"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT bad.cibs_billing_account_id, /*cibs_billing_charges_id, current_chg,*/ cibs_billing_account, product_id, product_description, tm1p.cibs_product, tm1p.tm1_name, /*amount, charge_start_date, charge_end_date,*/ min(CASE WHEN current_chg in ('Past','Current') THEN charge_start_date end) earliest_charge_date, max(CASE WHEN current_chg in ('Past','Current') THEN charge_end_date end) latest_charge_date--, cancel_date, last_billed, date_diff('month',charge_start_date,charge_end_date) datediff
FROM dimension_external_db.pib_cibs_billing_charges_dimension cbcd LEFT JOIN dimension_external_db.pib_billing_account_dimension bad
		ON cbcd.cibs_billing_account = bad.salesforce_billing_account_id
	LEFT JOIN (SELECT cibs_id, cibs_product, tm1_name FROM fact_external_db.tm1_fact 
				WHERE tm1_name IN ('WatchList API','Screening & Monitoring - Watchlist - API','Risk Database API package','Adverse Media Search - API','Adverse Media - Structured Profiles (Entities) - API','State-Owned Companies - API','Screening & Monitoring API Plus-Watchlist','Screening & Monitoring - State-Owned Companies - API','Screening & Monitoring - Adverse Media (Entities) - API','Screening & Monitoring API Plus-State Owned Companies','Screening & Monitoring API Plus-Adverse Media (Entities)','Cities & Ports - API','Adverse Media Analytics API','Batch Screening API','Dual-Use Goods - API','Watchlist-API Sandbox Env.','Marijuana-Related Business API')
				GROUP BY 1,2,3) tm1p ON cbcd.product_id = tm1p.cibs_id
WHERE product_id in (SELECT DISTINCT cibs_id FROM fact_external_db.tm1_fact
					WHERE tm1_name IN ('WatchList API','Screening & Monitoring - Watchlist - API','Risk Database API package','Adverse Media Search - API','Adverse Media - Structured Profiles (Entities) - API','State-Owned Companies - API','Screening & Monitoring API Plus-Watchlist','Screening & Monitoring - State-Owned Companies - API','Screening & Monitoring - Adverse Media (Entities) - API','Screening & Monitoring API Plus-State Owned Companies','Screening & Monitoring API Plus-Adverse Media (Entities)','Cities & Ports - API','Adverse Media Analytics API','Batch Screening API','Dual-Use Goods - API','Watchlist-API Sandbox Env.','Marijuana-Related Business API'))
AND current_chg <<>> 'Cancelled'
--AND charge_start_date >>= current_date - INTERVAL '36' MONTH 
--AND bad.cibs_billing_account_id in ('9GEA000200','9HON012500','9KRU000500','9YOU001600')
GROUP BY 1,2,3,4,5,6--,7,8,9,10,11,12,13
ORDER BY cibs_billing_account_id--, charge_start_date
