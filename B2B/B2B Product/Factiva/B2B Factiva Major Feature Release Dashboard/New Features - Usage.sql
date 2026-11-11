-- Dashboard   : "B2B Factiva Major Feature Release Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "New Features" = published source "B2B Factiva Major Feature Release - New Features"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Usage"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
                
                  
                
                
with 

jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')

select SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, 
 EID,
 mem.user_id,
mem.plan_id,
user_info_account_id as billing_account,
 comp.company_name,
 comp.company_industry,
 comp.company_country,
 jf.department_code,


sum(case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings'  THEN 1 ELSE 0 END) rf_pvs,

sum(case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_module_tracker like  '%FilingTypeDropdownChange%'  THEN 1 ELSE 0 END) rf_dropdown_clicks,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_action = 'download_regulatory_filing'  THEN 1 ELSE 0 END) rf_downloads,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'basic'  THEN 1 ELSE 0 END) basic_comp_report_download,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'advanced'  THEN 1 ELSE 0 END)  adv_comp_report_download,

 
 sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action in ('print_article', 'download_article_docx', 'download_article_pdf')  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) total_download_print_clicks,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_article_pdf'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) pdf_downloads,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_article_docx'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) docx_downloads,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'print_article'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) print_clicks,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'copy_summary'  and cycle_date >>= cast('2025-03-04' as date) 
THEN 1 ELSE 0 END) copy_text,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view'  
and ti_td_ad_split_view_mode = 'split_view' and cycle_date >>= cast('2025-10-30' as date) 
THEN 1 ELSE 0 END) split_view_switch_clicks,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view'  
and ti_td_ad_split_view_mode = 'headlines' and cycle_date >>= cast('2025-10-30' as date) 
THEN 1 ELSE 0 END) headline_view_switch_clicks,

COUNT(distinct case when product = 'New Factiva' AND ti_td_page_section = 'Search Builder'
and event_name in ('user_action', 'page_view') and cycle_date >>= cast('2026-01-26' as date) then visit_id end) as nfsb_visits,

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action in ('initial_search','modify_search') and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) as nfsb_searches,

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'page_view'
and ti_td_article_id is not null and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) as nfsb_articles,

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'filter_search' and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) as nfsb_filters,

sum(case when event_name = 'user_action' and ti_td_action = 'create_list' then 1 else 0 end) as create_lists,

sum(case when event_name = 'user_action' and ti_td_action = 'edit_list' then 1 else 0 end) as edit_lists,

sum(case when ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'apply_pre_search_filter' and ti_td_ad_filter_category = 'lists' then 1 else 0 end) as apply_list_filter,

sum(case when event_name in ('user_action','page_view') and ti_td_page_section = 'My Lists' then 1 else 0 end) as my_lists_clicks,

sum(case when event_name = 'user_action' and ti_td_action  = 'summary_go_deeper' and ti_td_page_section = 'keyword' and cycle_date >>= cast('2026-02-16' as date) then 1 else 0 end) as go_deeper_clicks,

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_ask_input' and cycle_date >>= cast('2026-02-16' as date) then ti_td_ad_searchid end) as chat_threads_started,

count(distinct case when event_name = 'user_action' and ti_td_action = 'new_unbounded_chat' then ti_td_ad_searchid end) as unbounded_new_chat_threads,

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_search_history' and cycle_date >>= cast('2026-02-16' as date) then ti_td_ad_searchid end) as chat_threads_returned,


sum(case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as saved_search_loads,

sum(case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then 1 else 0 end) as saved_search_edits,

sum(case when event_name = 'user_action' and ti_td_action = 'create_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as saved_search_creates,


sum(case when event_name = 'user_action' and ti_td_action = 'run_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then 1 else 0 end) as saved_search_runs,

sum(case when event_name = 'page_view' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then 1 else 0 end) as my_saved_search_pvs,


sum(case when event_name = 'user_action' and ti_td_action = 'smart_report_load_state' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then 1 else 0 end) as company_insights_requests,

sum(case when event_name = 'user_action' and ti_td_action = 'smart_report_download_docx' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then 1 else 0 end) as company_insights_downloads,

sum(case when event_name = 'user_action' and ti_td_action = 'article_bulk_download' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as nf_bulk_downloads,

sum(case when event_name = 'user_action' and ti_td_action = 'article_bulk_view' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as nf_bulk_views,

sum(case when event_name = 'user_action' and ti_td_action = 'article_save_add_bulk' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as nf_bulk_saves,

sum(case when event_name = 'user_action' and ti_td_action like 'classic_factiva_%' 
and product = 'New Factiva' then 1 else 0 end) as nf_navigation_clicks,

sum(case when event_name = 'page_view' and ti_td_page_section = 'My Alerts' 
and product = 'New Factiva' then 1 else 0 end) as alerts_pvs,

sum(case when event_name = 'user_action' and ti_td_action = 'click_alert_view_results' 
and product = 'New Factiva' then 1 else 0 end) as alert_view_results,

sum(case when event_name = 'user_action' and ti_td_action = 'create_alert'
and product = 'New Factiva' then 1 else 0 end) as create_alert_clciks



from pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref 
left join jf on mem.pib_member_id = jf.pib_member_id

where product in ('Factiva','New Factiva')
AND cycle_date >>= cast('2025-01-01' as date)
group by 1,2,3,4,5,6,7,8,9

having

sum(case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings'  THEN 1 ELSE 0 END) >> 0 or

sum(case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_module_tracker like  '%FilingTypeDropdownChange%'  THEN 1 ELSE 0 END) >> 0 or

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_action = 'download_regulatory_filing'  THEN 1 ELSE 0 END) >> 0 or

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'basic'  THEN 1 ELSE 0 END) >> 0 or

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'advanced'  THEN 1 ELSE 0 END) >> 0 or

 
sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action in ('print_article', 'download_article_docx', 'download_article_pdf')  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) >> 0 or

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'copy_summary'  and cycle_date >>= cast('2025-03-04' as date) 
THEN 1 ELSE 0 END) >> 0 or 

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view' 
and cycle_date >>= cast('2025-10-30' as date) THEN 1 ELSE 0 END) >> 0 or 

COUNT(distinct case when product = 'New Factiva' AND ti_td_page_section = 'Search Builder'
and event_name in ('user_action', 'page_view') and cycle_date >>= cast('2026-01-26' as date) then visit_id end) >> 0 or 

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action in ('initial_search','modify_search') and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) >> 0 or 

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'page_view'
and ti_td_article_id is not null and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) >> 0 or 

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'filter_search' and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) >> 0 or


sum(case when event_name = 'user_action' and ti_td_action = 'create_list' then 1 else 0 end) >> 0 or

sum(case when event_name = 'user_action' and ti_td_action = 'edit_list' then 1 else 0 end) >> 0 or

sum(case when ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'apply_pre_search_filter' and ti_td_ad_filter_category = 'lists' then 1 else 0 end) >> 0 or

sum(case when event_name in ('user_action','page_view') and ti_td_page_section = 'My Lists' then 1 else 0 end) >> 0 or

sum(case when event_name = 'user_action' and ti_td_action  = 'summary_go_deeper' and ti_td_page_section = 'keyword' and cycle_date >>= cast('2026-02-16' as date) then 1 else 0 end) >> 0 or

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_ask_input' and cycle_date >>= cast('2026-02-16' as date) then ti_td_ad_searchid end) >> 0 or

count(distinct case when event_name = 'user_action' and ti_td_action = 'new_unbounded_chat' then ti_td_ad_searchid end) >> 0 or

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_search_history' and cycle_date >>= cast('2026-02-16' as date) then ti_td_ad_searchid end) >> 0 or 

sum(case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search'
and product = 'New Factiva' then 1 else 0 end) >> 0 or

sum(case when event_name = 'user_action' and ti_td_action = 'create_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) >> 0 or

sum(case when event_name = 'user_action' and ti_td_action = 'run_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then 1 else 0 end) >> 0 or

sum(case when event_name = 'page_view' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then 1 else 0 end) >> 0 or 

sum(case when event_name = 'user_action' and ti_td_action = 'smart_report_load_state' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then 1 else 0 end) >> 0  or

sum(case when event_name = 'user_action' and ti_td_action = 'smart_report_download_docx' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then 1 else 0 end) >> 0 or 


sum(case when event_name = 'user_action' and ti_td_action = 'article_bulk_download' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) >> 0 or

sum(case when event_name = 'user_action' and ti_td_action = 'article_bulk_view' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) >> 0 or 

sum(case when event_name = 'user_action' and ti_td_action = 'article_save_add_bulk' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) >> 0 or 

sum(case when event_name = 'user_action' and ti_td_action like 'classic_factiva_%' 
and product = 'New Factiva' then 1 else 0 end) >> 0 or 

sum(case when event_name = 'page_view' and ti_td_page_section = 'My Alerts' 
and product = 'New Factiva' then 1 else 0 end) >> 0 or 

sum(case when event_name = 'user_action' and ti_td_action = 'click_alert_view_results' 
and product = 'New Factiva' then 1 else 0 end) >> 0 or 

sum(case when event_name = 'user_action' and ti_td_action = 'create_alert'
and product = 'New Factiva' then 1 else 0 end) >> 0                            
