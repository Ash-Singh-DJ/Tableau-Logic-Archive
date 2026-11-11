-- Dashboard   : "B2B Factiva Analytics Uptime Reporting"  [B2B / B2B Product / Factiva]
-- Data source : "New Relic2" (embedded in the workbook)
-- Relation    : Custom SQL "Full Date"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with vr as
(select 
'fa_api_status_snapshots_validation_prod' as fa
union all
select 'fa_analytics_validation_prod' as fa
union all
select 'fa_api_status_streams_validation_prod' as fa
union all
select 'fa_explains_validation_prod' as fa
union all
select 'fa_message_drops_articlecontinuous_prod' as fa
union all
select 'fa_message_drops_dnafirehose_prod' as fa) 


select substring(cast(full_date as varchar),1,10) as ymd,
full_date as date,
 vr.*, cast('86400' as INT) tot_seconds, 0 as downtime2  from 
reference_external_db.date_dimension dd
cross join vr
where full_date >>= cast('2024-07-01' as date)
and full_date <<= cast('2032-05-31' as date)
order by full_date
