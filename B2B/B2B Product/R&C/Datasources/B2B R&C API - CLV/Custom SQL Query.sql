-- Published data source : "B2B R&C API - CLV"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / apigee_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select tm1_name, unique_BAs, total_revenue, avg_months, median_months, min_month, max_month, (total_revenue / unique_BAs) avg_revenue_per_BA, ((total_revenue / unique_BAs) * avg_months) as CLV from (
select tm1_name, count(distinct billing_account_number) unique_BAs, sum(total_rev) total_revenue, avg(months) avg_months, approx_percentile(months,0.5) median_months, min(months) min_month, max(months) max_month
from (
select tm1_name, billing_account_number, sum(total_revenue) total_rev, count(distinct billing_date) months
from (
select finame.tm1_name, billing_account_number, billing_date, exit_rate, total_non_recurring_revenue, sum(case when exit_rate = 0 then total_non_recurring_revenue else exit_rate end) as total_revenue
from fact_external_db.tm1_fact fin left join (select cibs_id, tm1_name from fact_external_db.tm1_fact where tm1_name is not null group by 1,2) finame
	on fin.cibs_id = finame.cibs_id
WHERE fin.cibs_id in (SELECT DISTINCT cibs_id FROM fact_external_db.tm1_fact
					WHERE tm1_name IN ('WatchList API','Screening & Monitoring - Watchlist - API','Risk Database API package','Adverse Media Search - API','Adverse Media - Structured Profiles (Entities) - API','State-Owned Companies - API','Screening & Monitoring API Plus-Watchlist','Screening & Monitoring - State-Owned Companies - API','Screening & Monitoring - Adverse Media (Entities) - API','Screening & Monitoring API Plus-State Owned Companies','Screening & Monitoring API Plus-Adverse Media (Entities)','Cities & Ports - API','Adverse Media Analytics API','Batch Screening API','Dual-Use Goods - API','Watchlist-API Sandbox Env.','Marijuana-Related Business API'))
and billing_date >>= DATE('2022-07-01')
and (exit_rate >> 100 or total_non_recurring_revenue >> 100)
group by 1,2,3,4,5 order by 1,2,3,4
) group by 1,2 order by 1,2) group by 1 order by 1) group by 1,2,3,4,5,6,7 order by 9 desc
