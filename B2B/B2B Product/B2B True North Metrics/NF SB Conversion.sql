-- Dashboard   : "B2B True North Metrics"  [B2B / B2B Product]
-- Data source : "NF SB Conversion" = published source "NF SB Conversion"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 


wk as
(select substring(cast(full_date as varchar),1,10) year_month_day, substring(cast(week_start_date as varchar),1,10) week_start, day_of_week from reference_external_db.date_dimension
where substring(cast(full_date as varchar),1,10) >>= cast('2021-01-01' as varchar)
order by full_date),

sb1 as 
(select date_time, cycle_date, event_id, user_info_user_ref,  
visit_id, event_name, ti_td_page_driver, ti_td_action, ti_td_page_url, 
ti_td_page_section, ti_td_page_subsection, ti_td_page_content_type, ti_td_article_id 
from pib_event_data.pib_product_metrics
where Product = 'New Factiva'
and event_name in ('page_view', 'user_action')
and ((ti_td_action not like '%filter%' and ti_td_action <<>> 'sort_by'
and ti_td_action <<>> 'pagination_search' and ti_td_action <<>> 'split_view_change_view' ) or ti_td_action is null) 
and date_time >>= cast('2026-01-01' as date)
--and user_info_user_ref = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
--and visit_id = 'NEWFACTIVA_20260202_E6OO2HVCQHVPEKOJVPIZBZ36TU_000002'
order by date_time),

sb2 as 
(select date_time, cycle_date, (case when ti_td_action in ('initial_search','modify_search') then concat('SS-',event_id) end) as search_seq,
user_info_user_ref,  
visit_id, event_name, ti_td_page_driver, ti_td_action, ti_td_page_url, 
ti_td_page_section, ti_td_page_subsection, ti_td_page_content_type,
LEAD(ti_td_article_id) OVER (PARTITION BY visit_id ORDER BY date_time) as article_id_lead,
LEAD(ti_td_page_section) OVER (PARTITION BY visit_id ORDER BY date_time) as page_section_lead,
LEAD(ti_td_action) OVER (PARTITION BY visit_id ORDER BY date_time) as action_lead
from sb1)

select date_time, substring(cast(cycle_date as varchar),1,7) as year_month, week_start,  search_seq, user_info_user_ref, mem.billing_account_id, mem.plan_id, mem.user_id, event_name, action_lead, 
page_section_lead, article_id_lead
from sb2
join dimension_external_db.pib_membership_dimension mem on sb2.user_info_user_ref = mem.pib_member_id
LEFT JOIN wk on cast(sb2.cycle_date as varchar) = wk.year_month_day
where search_seq is not null
