-- Dashboard   : "R&C SLT Due Diligence Dashboard"  [B2B / B2B Product / R&C]
-- Data source : "DD Reports" (embedded in the workbook)
-- Relation    : Custom SQL "dd reports 2"
-- Connection  : Athena (AwsDataCatalog / google_sheets_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select record_id, delivery_date, dat.week_number_in_fiscal_year, 
substring(cast(delivery_date as varchar),1,7) cal_month,
dat.month_number_in_fiscal_year, number_of_reports, usd_value from google_sheets_db.due_diligence_delivered_reports_current dd
left join reference_external_db.date_dimension dat on cast(dd.delivery_date as varchar) = substring(cast(dat.full_date as varchar),1,10)
where delivery_date >>= CAST('2024-01-01' as date)
