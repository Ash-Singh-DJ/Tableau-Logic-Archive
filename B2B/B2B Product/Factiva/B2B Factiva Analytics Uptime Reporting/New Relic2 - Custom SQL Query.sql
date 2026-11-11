-- Dashboard   : "B2B Factiva Analytics Uptime Reporting"  [B2B / B2B Product / Factiva]
-- Data source : "New Relic2" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
                  
                    
                  
                  
                  
with da as 

(select substring(cast(full_date as varchar),1,10) as ymd3,
 0 as downtime3, cast('86400' as INT) tot_seconds2  from 
reference_external_db.date_dimension dd

where full_date >>= cast('2024-07-01' as date)
and full_date <<= cast('2032-05-31' as date)
order by full_date),

ja as

(select year_month_day, sum(seconds) as total_downtime from (

select substring(cast(start_time as varchar),1,10) year_month_day, start_time, end_time, date_diff('second', start_time, end_time) as seconds from ( 

WITH 
intervals as (

select start_time, end_time from (
(select  smn, timestamp as start_time, test as end_time  from (  
select synthetic_monitor_name as smn, timestamp, result, lag_result, LEAD(timestamp, 1) OVER (PARTITION BY synthetic_monitor_name ORDER BY timestamp asc) as test from (              
select * from (
select synthetic_monitor_name, timestamp, result,
LAG(result, 1) OVER (PARTITION BY synthetic_monitor_name ORDER BY timestamp asc) as lag_result
from new_relic_db.new_relic_synthetics
where (synthetic_monitor_name like 'fa%' 
and synthetic_monitor_name not like '%bucket%'
and synthetic_monitor_name not like  '%cloud_run_distdoc%' and
synthetic_monitor_name not like '%explains%' and synthetic_monitor_name not like '%analytics%'))
WHERE ((result = 'FAILED' and lag_result = 'SUCCESS') or (result = 'SUCCESS' and lag_result = 'FAILED')))
)
where result = 'FAILED'
))),


IntervalsWithLag AS (
    SELECT
        *,
        LAG(end_time) OVER (ORDER BY start_time) AS prev_end_time
    FROM
        intervals
),
GroupedIntervals AS (
    SELECT
        start_time,
        end_time,
        SUM(CASE
                WHEN start_time <<= prev_end_time THEN 0
                ELSE 1
            END) OVER (ORDER BY start_time) AS group_id
    FROM
        IntervalsWithLag
)
SELECT
    MIN(start_time) AS start_time,
    MAX(end_time) AS end_time
FROM
    GroupedIntervals
GROUP BY
    group_id
ORDER BY
    start_time))
    group by 1)
    
    select * from da
    left join ja on da.ymd3 = ja.year_month_day                                                
