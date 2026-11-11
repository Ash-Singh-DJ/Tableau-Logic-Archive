-- Dashboard   : "B2B Factiva Counter Reporting Dashboard"  [B2B / B2B Content Licensing- PAL]
-- Data source : "B2B Factiva Counter Report Query (dimension_external_db)" = published source "B2B Factiva Counter Reporting Dashboard - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Factiva Content Source"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from sandbox_mk.factiva_content_source_current
where onlineavailability not like '%Russia%'
