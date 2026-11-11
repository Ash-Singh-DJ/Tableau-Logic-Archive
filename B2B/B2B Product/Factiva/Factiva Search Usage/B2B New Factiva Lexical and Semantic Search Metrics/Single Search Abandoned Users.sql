-- Dashboard   : "B2B New Factiva Lexical and Semantic Search Metrics"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Single Search Abandoned Users" = published source "Single Search Abandoned Users"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with pw as 
(select mem.pib_member_id, 
count(distinct case when event_name = 'page_view' or event_name = 'user_action' then cycle_date end) nf_active_days

from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
where product = 'New Factiva'

AND cycle_date >>= date_add('day', -32, current_date)
AND cycle_date << current_date

group by 1)


select mem.pib_member_id, mem.user_id, mem.plan_id,  pw.nf_active_days, mem.billing_account_id,

count(distinct case when
ti_td_page_content_type = 'ResearchTools' 
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'free text' 
and product = 'New Factiva'
and event_name = 'page_view'
and (ti_td_search_type is null or ti_td_search_type = '') 
then user_info_session_id end) lex_search_sessions,


count(distinct case when
ti_td_page_content_type = 'ResearchTools' 
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'free text' 
and product = 'New Factiva'
and event_name = 'page_view' 
and ti_td_search_type = 'semantic search'
then user_info_session_id end) sem_search_sessions,


count(distinct case when
ti_td_page_content_type = 'ResearchTools' 
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'free text' 
and product = 'New Factiva'
and event_name = 'page_view' 
then user_info_session_id end) search_sessions

from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join pw on mem.pib_member_id = pw.pib_member_id
where product = 'New Factiva'

AND cycle_date >>= date_add('day', -92, current_date)
AND cycle_date << date_add('day', -32, current_date)

group by 1,2,3,4,5

having 
count(distinct case when
ti_td_page_content_type = 'ResearchTools' 
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'free text' 
and product = 'New Factiva'
and event_name = 'page_view' 
then user_info_session_id end) >> 0
