-- Dashboard   : "B2B Factiva Analytics Uptime Reporting"  [B2B / B2B Product / Factiva]
-- Data source : "New Relic2" (embedded in the workbook)
-- Relation    : Custom SQL "Downtime"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select ymd, synthetic_monitor_name, sum(duration) duration_sum from ( 
select substring(cast(timestamp as varchar),1,10) as ymd, synthetic_monitor_name, date_diff('second', timestamp, test) as duration from (  
select synthetic_monitor_name, timestamp, result, lag_result, LEAD(timestamp, 1) OVER (PARTITION BY synthetic_monitor_name ORDER BY timestamp asc) as test from (              
select * from (
select synthetic_monitor_name, timestamp, result,
LAG(result, 1) OVER (PARTITION BY synthetic_monitor_name ORDER BY timestamp asc) as lag_result
from new_relic_db.new_relic_synthetics
where synthetic_monitor_name like 'fa%'
and synthetic_monitor_name not like '%bucket_stag%'
and timestamp >> cast('2024-07-01' as date)
)
WHERE ((result = 'FAILED' and lag_result = 'SUCCESS') or (result = 'SUCCESS' and lag_result = 'FAILED')))
)
where result = 'FAILED')
group by 1,2
