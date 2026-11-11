-- Published data source : "B2B Classic Factiva Usage Dashboard - Usage Athena"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "fiscal_week lookup"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(full_date as varchar), 1, 10) date,
case 
	when substring(cast(week_number_in_calendar_year as varchar), 6, 1) = '0' then 
	CONCAT(substring(cast(week_number_in_calendar_year as varchar),1,5), substring(cast(week_number_in_calendar_year as varchar),7,1))
	
	else week_number_in_calendar_year  end as cal_week,

 week_number_in_fiscal_year as "fiscal_week" from reference_external_db.date_dimension
where day_of_week = 'Monday'

order by fiscal_week
