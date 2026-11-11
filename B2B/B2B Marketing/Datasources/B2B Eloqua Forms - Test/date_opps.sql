-- Published data source : "B2B Eloqua Forms - Test"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "date_opps"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select date(full_date) as date_opp
, calendar_month_name calendar_month_name_opp
, calendar_year calendar_year_opp
, fiscal_year fiscal_year_opp 
from reference_external_db.date_dimension
