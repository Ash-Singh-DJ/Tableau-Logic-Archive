-- Dashboard   : "Unique Users on DJ Platform"  [B2B / B2B Product]
-- Data source : "Unique Users on DJ Platform2" = published source "Unique Users on DJ Platform2"  [B2B / B2B Content Licensing- PAL]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(cycle_date as varchar),1,7) as year_month, mem.pib_member_id, mem.billing_account_id, product,
count(*) as pv_count
from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
where cycle_date >>= cast('2025-07-01' as date)
and event_name in ('page_view', 'user_action')
group by 1,2,3,4

union all 

select substring(cast(cycle_date as varchar),1,7) as year_month, mem.pib_member_id, mem.billing_account_id, reporting_suite as product,
count(*) as pv_count
from fact_external_db.omniture_event_fact_hourly djm
inner join dimension_external_db.pib_membership_dimension mem on djm.post_evar3 = mem.pib_member_id 
where cycle_date >>= cast('2025-07-01' as date)
and reporting_suite in ('djb2byomiuri','djb2briskjournal')
group by 1,2,3,4
