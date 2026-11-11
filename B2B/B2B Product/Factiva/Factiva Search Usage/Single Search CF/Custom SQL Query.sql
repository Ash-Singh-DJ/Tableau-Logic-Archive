-- Published data source : "Single Search CF"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with pw as 
(select mem.pib_member_id, 
count(distinct case when event_name = 'page_view' or event_name = 'user_action' then cycle_date end) cf_active_days

from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
where product = 'Factiva'

AND cycle_date >>= date_add('day', -32, current_date)
group by 1)


select mem.pib_member_id, mem.user_id, mem.plan_id,  pw.cf_active_days, mem.billing_account_id,

count(distinct case when ti_td_page_content_type = 'SearchResults'
and (ti_td_page_section = 'Search' or ti_td_page_section = 'Home') and Product = 'Factiva'
and event_name = 'page_view' 
then user_info_session_id 
end) as cf_search_sessions

from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join pw on mem.pib_member_id = pw.pib_member_id
where product = 'Factiva'

AND cycle_date >>= date_add('day', -92, current_date)
AND cycle_date << date_add('day', -32, current_date)

group by 1,2,3,4,5

having 
count(distinct case when ti_td_page_content_type = 'SearchResults'
and (ti_td_page_section = 'Search' or ti_td_page_section = 'Home') and Product = 'Factiva'
and event_name = 'page_view' 
then user_info_session_id 
end) >> 0
