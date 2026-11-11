-- Dashboard   : "B2B FY26 Sales-Marketing ABM"  [B2B / B2B Marketing]
-- Data source : "Custom SQL Query (sandbox_pecom)" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query2"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select 
date(full_date) full_date, 
fiscal_year, 
day_number_in_fiscal_year,
month_number_in_fiscal_year,
fiscal_month_name,
month_number_in_calendar_year, 
fiscal_year_start_date, 
fiscal_year_end_date
from reference_external_db.date_dimension
