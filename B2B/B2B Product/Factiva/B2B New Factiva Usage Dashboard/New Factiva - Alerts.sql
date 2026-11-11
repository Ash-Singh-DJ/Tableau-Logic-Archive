-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "New Factiva" (embedded in the workbook)
-- Relation    : Custom SQL "Alerts"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(report_date as varchar),1,7) year_month, user_id, email_address, account_id, delivery_type, 
sum(cast(email_count as INTEGER)) sum_email_count, sum(cast(article_count as INTEGER)) sum_article_count 
from dimension_external_db.pib_alerts
where delivery_type in ('D','I')
and report_date >>= cast('2022-06-01' as date)
group by 1,2,3,4,5
