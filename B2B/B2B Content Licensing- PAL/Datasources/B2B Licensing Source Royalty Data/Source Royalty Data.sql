-- Published data source : "B2B Licensing Source Royalty Data"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "Source Royalty Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT *
FROM dimension_external_db.royalty_monthly_management_report
WHERE DATE(cycle_date) >>= DATE('2017-01-01')
