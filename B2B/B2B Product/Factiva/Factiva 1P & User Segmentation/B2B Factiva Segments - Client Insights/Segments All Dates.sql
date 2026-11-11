-- Dashboard   : "B2B Factiva Segments - Client Insights"  [B2B / B2B Product / Factiva / Factiva 1P & User Segmentation]
-- Data source : "Segments All Dates" = published source "B2B Factiva Segments Client Insights - All Dates"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / zoolander_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from zoolander_db.factiva_micro_user_seg_6mo 
where cycle_date >>= date_trunc('month', date_add('month', -5, current_date))
