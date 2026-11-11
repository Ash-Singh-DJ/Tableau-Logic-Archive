-- Dashboard   : "[SANDBOX] Contract-Level Dataset (athena)"  [B2B / B2B Pricing / Country Segment Pricing / Test Versions]
-- Data source : "Historical Pricing TM1" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
Select * from sandbox_test.vw_contract_level
