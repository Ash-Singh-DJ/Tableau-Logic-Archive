-- Dashboard   : "B2B FY26 Sales-Marketing ABM"  [B2B / B2B Marketing]
-- Data source : "Custom SQL Query (sandbox_pecom)" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from sandbox_hvc.prod_master
