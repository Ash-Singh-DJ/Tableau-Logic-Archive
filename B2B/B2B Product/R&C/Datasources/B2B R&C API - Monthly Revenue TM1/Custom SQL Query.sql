-- Published data source : "B2B R&C API - Monthly Revenue TM1"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT billing_date, tm1_name,
	SUM(exit_rate) AS monthly_exit_rate
    , SUM(exit_rate * 12) AS annualized_exit_rate
    , SUM(total_revenue) AS total_revenue
    , SUM(total_non_recurring_revenue) AS monthly_non_recurring_revenue
FROM fact_external_db.tm1_fact 
WHERE billing_date >>= DATE('2022-07-01')
--product list from tm1 dashboard linked by Parantap
AND tm1_name IN ('WatchList API','Screening & Monitoring - Watchlist - API','Risk Database API package','Adverse Media Search - API','Adverse Media - Structured Profiles (Entities) - API','State-Owned Companies - API','Screening & Monitoring API Plus-Watchlist','Screening & Monitoring - State-Owned Companies - API','Screening & Monitoring - Adverse Media (Entities) - API','Screening & Monitoring API Plus-State Owned Companies','Screening & Monitoring API Plus-Adverse Media (Entities)','Cities & Ports - API','Adverse Media Analytics API','Batch Screening API','Dual-Use Goods - API','Watchlist-API Sandbox Env.','Marijuana-Related Business API')
--AND billing_date = (SELECT MAX(billing_date) FROM fact_external_db.tm1_fact)
GROUP BY 1,2
ORDER BY billing_date desc, tm1_name desc
