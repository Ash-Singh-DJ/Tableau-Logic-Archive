-- Dashboard   : "R&C SLT Due Diligence Dashboard"  [B2B / B2B Product / R&C]
-- Data source : "DD Reports" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / google_sheets_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select record_id, delivery_date, dat.week_number_in_fiscal_year, month_number_in_fiscal_year, concat(fiscal_month_name, ' ', substring(cast(week_number_in_fiscal_year as varchar),1,4)) as fiscal_month,
substring(cast(delivery_date as varchar),1,7) cal_month,
concat(cast((cast(substring(dat.week_number_in_fiscal_year,1,4) as integer)-1) as varchar),'-',cast(substring(dat.week_number_in_fiscal_year,6,2) as varchar)) prior_yr_fiscal_wk, 
CONCAT(  cast((cast(substring(cast(delivery_date as varchar),1,4) as INTEGER)-1) as varchar),'-',cast(substring(cast(delivery_date as varchar),6,2) as varchar)) prior_yr_cal_mth,
report_type, sales_region, number_of_reports, add_subjects_number, usd_value from google_sheets_db.due_diligence_delivered_reports_current dd
left join reference_external_db.date_dimension dat on cast(dd.delivery_date as varchar) = substring(cast(dat.full_date as varchar),1,10)
where delivery_date >>= CAST('2024-01-01' as date)
