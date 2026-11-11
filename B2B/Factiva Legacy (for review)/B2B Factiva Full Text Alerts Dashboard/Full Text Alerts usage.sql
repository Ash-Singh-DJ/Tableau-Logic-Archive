-- Dashboard   : "B2B Factiva Full Text Alerts Dashboard"  [B2B / Factiva Legacy (for review)]
-- Data source : "Full Text Alerts usage" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from dimension_external_db.pib_alerts
where report_date >>= cast('2023-04-01' as date)
and lower(display_format) LIKE '%fulltext%'
