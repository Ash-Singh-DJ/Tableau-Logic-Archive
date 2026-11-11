-- Dashboard   : "B2B Factiva Major Feature Release Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "Front page" = published source "B2B Factiva Major Feature Release -  Front page"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with

jam as
(select (case when user_info_account_id like '9ZZZ%'
or user_info_account_id like '9ZFB%'
or user_info_account_id = '9DOW003600'
or user_info_account_id = '9DOW007100'
or user_info_account_id = '9FAC067700' then 'Internal' else 'External' end) as account_type,

(case when plan_id in ('0086', '0087') then 'Academic' else 'Non-Academic' end) as academic,


sum(case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings'  THEN 1 ELSE 0 END) rfpv_metric,

count(distinct case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings' then mem.pib_member_id END) rfpv_uu,

count(distinct case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings' then mem.billing_account_id END) rfpv_ua,


sum(case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_module_tracker like  '%FilingTypeDropdownChange%'  THEN 1 ELSE 0 END) rfdd_metric,

count(distinct case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_module_tracker like  '%FilingTypeDropdownChange%' THEN mem.pib_member_id END) rfdd_uu,

count(distinct case when product = 'New Factiva' and event_name = 'page_view' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_module_tracker like  '%FilingTypeDropdownChange%'  THEN mem.billing_account_id END) rfdd_ua,


sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_action = 'download_regulatory_filing'  THEN 1 ELSE 0 END) rfds_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_action = 'download_regulatory_filing'  THEN mem.pib_member_id END) rfds_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_page_sub_subsection = 'RegulatoryFilings' and ti_td_action = 'download_regulatory_filing'  THEN mem.billing_account_id END) rfds_ua,


sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'basic'  THEN 1 ELSE 0 END) dcrb_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'basic' THEN mem.pib_member_id END) dcrb_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'basic' THEN mem.billing_account_id END) dcrb_ua,



sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'advanced'  THEN 1 ELSE 0 END) dcra_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'advanced' THEN mem.pib_member_id END) dcra_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_company_report' and lower(ti_td_ad_report_type) = 'advanced' THEN mem.billing_account_id END) dcra_ua,


sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action in ('print_article', 'download_article_docx', 'download_article_pdf')  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) tdc_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action in ('print_article', 'download_article_docx', 'download_article_pdf')  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' then mem.pib_member_id END) tdc_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action in ('print_article', 'download_article_docx', 'download_article_pdf')  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' then mem.billing_account_id END) tdc_ua,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_article_pdf'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) pac_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_article_pdf'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' then mem.pib_member_id  END) pac_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_article_pdf'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' then mem.billing_account_id  END) pac_ua,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_article_docx'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) dac_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_article_docx'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' then mem.pib_member_id  END) dac_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'download_article_docx'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' then mem.billing_account_id  END) dac_ua,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'print_article'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) apc_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'print_article'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' then mem.pib_member_id  END) apc_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'print_article'  and cycle_date >>= cast('2024-12-04' as date) 
and ti_td_page_content_type = 'Article' then mem.billing_account_id  END) apc_ua,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'copy_summary'  and cycle_date >>= cast('2025-03-04' as date) 
THEN 1 ELSE 0 END) cop_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'copy_summary'  and cycle_date >>= cast('2025-03-04' as date)  
 then mem.pib_member_id  END) cop_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'copy_summary'  and cycle_date >>= cast('2025-03-04' as date)
then mem.billing_account_id  END) cop_ua,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view'  
and ti_td_ad_split_view_mode = 'split_view' and cycle_date >>= cast('2025-10-30' as date) 
THEN 1 ELSE 0 END) spi_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view'  
and ti_td_ad_split_view_mode = 'split_view' and cycle_date >>= cast('2025-10-30' as date) 
THEN mem.pib_member_id  END) spi_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view'  
and ti_td_ad_split_view_mode = 'split_view' and cycle_date >>= cast('2025-10-30' as date) 
THEN mem.billing_account_id  END) spi_ua,

sum(case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view'  
and ti_td_ad_split_view_mode = 'headlines' and cycle_date >>= cast('2025-10-30' as date) 
THEN 1 ELSE 0 END) hev_metric,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view'  
and ti_td_ad_split_view_mode = 'headlines' and cycle_date >>= cast('2025-10-30' as date) 
THEN mem.pib_member_id  END) hev_uu,

count(distinct case when product = 'New Factiva' and event_name = 'user_action' and ti_td_action = 'split_view_change_view'  
and ti_td_ad_split_view_mode = 'headlines' and cycle_date >>= cast('2025-10-30' as date) 
THEN mem.billing_account_id  END) hev_ua,

COUNT(distinct case when product = 'New Factiva' AND ti_td_page_section = 'Search Builder'
and event_name in ('user_action', 'page_view') and cycle_date >>= cast('2026-01-26' as date) then visit_id end) as nsbv_metric,

COUNT(distinct case when product = 'New Factiva' AND ti_td_page_section = 'Search Builder'
and event_name in ('user_action', 'page_view') and cycle_date >>= cast('2026-01-26' as date) then mem.pib_member_id end) as nsbv_uu,

COUNT(distinct case when product = 'New Factiva' AND ti_td_page_section = 'Search Builder'
and event_name in ('user_action', 'page_view') and cycle_date >>= cast('2026-01-26' as date) then mem.billing_account_id end) as nsbv_ua,

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action in ('initial_search','modify_search') and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) as nsbs_metric,

count(distinct case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action in ('initial_search','modify_search') and cycle_date >>= cast('2026-01-26' as date) then mem.pib_member_id end) as nsbs_uu,

count(distinct case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action in ('initial_search','modify_search') and cycle_date >>= cast('2026-01-26' as date) then mem.billing_account_id end) as nsbs_ua,

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'page_view'
and ti_td_article_id is not null and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) as nsba_metric,

count(distinct case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'page_view'
and ti_td_article_id is not null and cycle_date >>= cast('2026-01-26' as date) then mem.pib_member_id end) as nsba_uu,

count(distinct case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'page_view'
and ti_td_article_id is not null and cycle_date >>= cast('2026-01-26' as date) then mem.billing_account_id end) as nsba_ua,

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'filter_search' and cycle_date >>= cast('2026-01-26' as date) then 1 else 0 end) as nsbf_metric,

count(distinct case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'filter_search' and cycle_date >>= cast('2026-01-26' as date) then mem.pib_member_id  end) as nsbf_uu,

count(distinct case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'filter_search' and cycle_date >>= cast('2026-01-26' as date) then mem.billing_account_id end) as nsbf_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'create_list' then 1 else 0 end) as crli_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'create_list' then mem.pib_member_id end) as crli_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'create_list' then mem.billing_account_id end) as crli_ua,

sum(case when event_name = 'user_action' and ti_td_action = 'edit_list' then 1 else 0 end) as edli_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'edit_list' then mem.pib_member_id end) as edli_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'edit_list' then mem.billing_account_id end) as edli_ua,

sum(case when ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'apply_pre_search_filter' and ti_td_ad_filter_category = 'lists' then 1 else 0 end) as appl_metric,

count(distinct case when ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'apply_pre_search_filter' and ti_td_ad_filter_category = 'lists' then mem.pib_member_id end) as appl_uu,

count(distinct case when ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action = 'apply_pre_search_filter' and ti_td_ad_filter_category = 'lists' then mem.billing_account_id end) as appl_ua,

sum(case when event_name in ('user_action','page_view') and ti_td_page_section = 'My Lists' then 1 else 0 end) as myli_metric,

count(distinct case when event_name in ('user_action','page_view') and ti_td_page_section = 'My Lists' then mem.pib_member_id end) as myli_uu,

count(distinct case when event_name in ('user_action','page_view') and ti_td_page_section = 'My Lists' then mem.billing_account_id end) as myli_ua,

sum(case when event_name = 'user_action' and ti_td_action  = 'summary_go_deeper' and ti_td_page_section = 'keyword' and cycle_date >>= cast('2026-02-16' as date) then 1 else 0 end) as god_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'summary_go_deeper' and ti_td_page_section = 'keyword' and cycle_date >>= cast('2026-02-16' as date) then mem.pib_member_id end) as god_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'summary_go_deeper' and ti_td_page_section = 'keyword' and cycle_date >>= cast('2026-02-16' as date) then mem.billing_account_id end) as god_ua,

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_ask_input' and cycle_date >>= cast('2026-02-16' as date) then ti_td_ad_searchid end) as cti_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_ask_input' and cycle_date >>= cast('2026-02-16' as date) then mem.pib_member_id end) as cti_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_ask_input' and cycle_date >>= cast('2026-02-16' as date) then mem.billing_account_id end) as cti_ua,


count(distinct case when event_name = 'user_action' and ti_td_action = 'new_unbounded_chat' then ti_td_ad_searchid end) as unc_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'new_unbounded_chat' then mem.pib_member_id end) as unc_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'new_unbounded_chat' then mem.billing_account_id end) as unc_ua,



count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_search_history' and cycle_date >>= cast('2026-02-16' as date) then ti_td_ad_searchid end) as ctr_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_search_history' and cycle_date >>= cast('2026-02-16' as date) then mem.pib_member_id end) as ctr_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'chat_search_history' and cycle_date >>= cast('2026-02-16' as date) then mem.billing_account_id end) as ctr_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as lss_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.pib_member_id end) as lss_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.billing_account_id end) as lss_ua,

sum(case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then 1 else 0 end) as ess_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then mem.pib_member_id end) as ess_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'retrieve_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then mem.billing_account_id end) as ess_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'create_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as css_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'create_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.pib_member_id end) as css_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'create_saved_search' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.billing_account_id end) as css_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'run_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then 1 else 0 end) as rss_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'run_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then mem.pib_member_id end) as rss_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'run_saved_search' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then mem.billing_account_id end) as rss_ua,


sum(case when event_name = 'page_view' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then 1 else 0 end) as mss_metric,

count(distinct case when event_name = 'page_view' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then mem.pib_member_id end) as mss_uu,

count(distinct case when event_name = 'page_view' and ti_td_page_section = 'My Saved Searches'
and product = 'New Factiva' then mem.billing_account_id end) as mss_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'smart_report_load_state' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then 1 else 0 end) as cin_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'smart_report_load_state' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then mem.pib_member_id end) as cin_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'smart_report_load_state' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then mem.billing_account_id end) as cin_ua,
 

sum(case when event_name = 'user_action' and ti_td_action = 'smart_report_download_docx' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then 1 else 0 end) as cid_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'smart_report_download_docx' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then mem.pib_member_id end) as cid_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'smart_report_download_docx' and ti_td_page_subsection = 'Smart Report'
and product = 'New Factiva' then mem.billing_account_id end) as cid_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'article_bulk_download' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as bec_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'article_bulk_download' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.pib_member_id end) as bec_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'article_bulk_download' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.billing_account_id end) as bec_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'article_bulk_view' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as bvc_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'article_bulk_view' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.pib_member_id end) as bvc_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'article_bulk_view' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.billing_account_id end) as bvc_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'article_save_add_bulk' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then 1 else 0 end) as bsc_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'article_save_add_bulk' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.pib_member_id end) as bsc_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'article_save_add_bulk' and ti_td_page_section = 'Search Builder'
and product = 'New Factiva' then mem.billing_account_id end) as bsc_ua,

sum(case when event_name = 'user_action' and ti_td_action like 'classic_factiva_%' 
and product = 'New Factiva' then 1 else 0 end) as nbc_metric,

count(distinct case when event_name = 'user_action' and ti_td_action like 'classic_factiva_%' 
and product = 'New Factiva' then mem.pib_member_id end) as nbc_uu,

count(distinct case when event_name = 'user_action' and ti_td_action like 'classic_factiva_%' 
and product = 'New Factiva' then mem.billing_account_id end) as nbc_ua,

sum(case when event_name = 'page_view' and ti_td_page_section = 'My Alerts' 
and product = 'New Factiva' then 1 else 0 end) as apv_metric,

count(distinct case when event_name = 'page_view' and ti_td_page_section = 'My Alerts' 
and product = 'New Factiva' then mem.pib_member_id end) as apv_uu,

count(distinct case when event_name = 'page_view' and ti_td_page_section = 'My Alerts' 
and product = 'New Factiva' then mem.billing_account_id end) as apv_ua,

sum(case when event_name = 'user_action' and ti_td_action = 'click_alert_view_results' 
and product = 'New Factiva' then 1 else 0 end) as ava_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'click_alert_view_results'  
and product = 'New Factiva' then mem.pib_member_id end) as ava_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'click_alert_view_results' 
and product = 'New Factiva' then mem.billing_account_id end) as ava_ua,


sum(case when event_name = 'user_action' and ti_td_action = 'create_alert'
and product = 'New Factiva' then 1 else 0 end) as acc_metric,

count(distinct case when event_name = 'user_action' and ti_td_action = 'create_alert'
and product = 'New Factiva' then mem.pib_member_id end) as acc_uu,

count(distinct case when event_name = 'user_action' and ti_td_action = 'create_alert'
and product = 'New Factiva' then mem.billing_account_id end) as acc_ua


from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
where product  = 'New Factiva'
AND cycle_date >>= cast('2025-01-01' as date)
group by 1,2
) 


select account_type, academic, 'rfpv' as Code, rfpv_metric as value_metric, rfpv_uu as value_uu, rfpv_ua as value_ua from jam
union all
select account_type, academic, 'rfdd' as Code, rfdd_metric as value_metric, rfdd_uu as value_uu, rfdd_ua as value_ua from jam
union all
select account_type, academic, 'rfds' as Code, rfds_metric as value_metric, rfds_uu as value_uu, rfds_ua as value_ua from jam
union all
select account_type, academic, 'dcrb' as Code, dcrb_metric as value_metric, dcrb_uu as value_uu, dcrb_ua as value_ua from jam
union all
select account_type, academic, 'dcra' as Code, dcra_metric as value_metric, dcra_uu as value_uu, dcra_ua as value_ua from jam
union all
select account_type, academic, 'tdc' as Code, tdc_metric as value_metric, tdc_uu as value_uu, tdc_ua as value_ua from jam
union all
select account_type, academic, 'pac' as Code, pac_metric as value_metric, pac_uu as value_uu, pac_ua as value_ua from jam
union all
select account_type, academic, 'dac' as Code, dac_metric as value_metric, dac_uu as value_uu, dac_ua as value_ua from jam
union all
select account_type, academic, 'apc' as Code, apc_metric as value_metric, apc_uu as value_uu, apc_ua as value_ua from jam
union all
select account_type, academic, 'cop' as Code, cop_metric as value_metric, cop_uu as value_uu, cop_ua as value_ua from jam
union all
select account_type, academic, 'spi' as Code, spi_metric as value_metric, spi_uu as value_uu, spi_ua as value_ua from jam
union all
select account_type, academic, 'hev' as Code, hev_metric as value_metric, hev_uu as value_uu, hev_ua as value_ua from jam
union all
select account_type, academic, 'nsbv' as Code, nsbv_metric as value_metric, nsbv_uu as value_uu, nsbv_ua as value_ua from jam
union all
select account_type, academic, 'nsbs' as Code, nsbs_metric as value_metric, nsbs_uu as value_uu, nsbs_ua as value_ua from jam
union all
select account_type, academic, 'nsba' as Code, nsba_metric as value_metric, nsba_uu as value_uu, nsba_ua as value_ua from jam
union all
select account_type, academic, 'nsbf' as Code, nsbf_metric as value_metric, nsbf_uu as value_uu, nsbf_ua as value_ua from jam
union all
select account_type, academic, 'crli' as Code, crli_metric as value_metric, crli_uu as value_uu, crli_ua as value_ua from jam
union all
select account_type, academic, 'edli' as Code, edli_metric as value_metric, edli_uu as value_uu, edli_ua as value_ua from jam
union all
select account_type, academic, 'appl' as Code, appl_metric as value_metric, appl_uu as value_uu, appl_ua as value_ua from jam
union all
select account_type, academic, 'myli' as Code, myli_metric as value_metric, myli_uu as value_uu, myli_ua as value_ua from jam
union all
select account_type, academic, 'god' as Code, god_metric as value_metric, god_uu as value_uu, god_ua as value_ua from jam
union all
select account_type, academic, 'cti' as Code, cti_metric as value_metric, cti_uu as value_uu, cti_ua as value_ua from jam
union all
select account_type, academic, 'unc' as Code, unc_metric as value_metric, unc_uu as value_uu, unc_ua as value_ua from jam
union all
select account_type, academic, 'ctr' as Code, ctr_metric as value_metric, ctr_uu as value_uu, ctr_ua as value_ua from jam
union all
select account_type, academic, 'lss' as Code, lss_metric as value_metric, lss_uu as value_uu, lss_ua as value_ua from jam
union all
select account_type, academic, 'ess' as Code, ess_metric as value_metric, ess_uu as value_uu, ess_ua as value_ua from jam
union all
select account_type, academic, 'css' as Code, css_metric as value_metric, css_uu as value_uu, css_ua as value_ua from jam
union all
select account_type, academic, 'rss' as Code, rss_metric as value_metric, rss_uu as value_uu, rss_ua as value_ua from jam
union all
select account_type, academic, 'mss' as Code, mss_metric as value_metric, mss_uu as value_uu, mss_ua as value_ua from jam
union all
select account_type, academic, 'cin' as Code, cin_metric as value_metric, cin_uu as value_uu, cin_ua as value_ua from jam
union all
select account_type, academic, 'cid' as Code, cid_metric as value_metric, cid_uu as value_uu, cid_ua as value_ua from jam
union all
select account_type, academic, 'bec' as Code, bec_metric as value_metric, bec_uu as value_uu, bec_ua as value_ua from jam
union all
select account_type, academic, 'bvc' as Code, bvc_metric as value_metric, bvc_uu as value_uu, bvc_ua as value_ua from jam
union all
select account_type, academic, 'bsc' as Code, bsc_metric as value_metric, bsc_uu as value_uu, bsc_ua as value_ua from jam
union all
select account_type, academic, 'apv' as Code, apv_metric as value_metric, apv_uu as value_uu, apv_ua as value_ua from jam
union all
select account_type, academic, 'acc' as Code, acc_metric as value_metric, acc_uu as value_uu, acc_ua as value_ua from jam
union all
select account_type, academic, 'ava' as Code, ava_metric as value_metric, ava_uu as value_uu, ava_ua as value_ua from jam
union all
select account_type, academic, 'nbc' as Code, nbc_metric as value_metric, nbc_uu as value_uu, nbc_ua as value_ua from jam
