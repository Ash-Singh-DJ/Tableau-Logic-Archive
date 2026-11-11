-- Published data source : "B2B DJ Search Dashboard - User Level search data"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with  
jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT'),

dat as 

(select substring(cast(full_date as varchar),1,10) as full_date, substring(cast(week_start_date as varchar),1,10) as wsd,  week_number_in_fiscal_year as fw
from  reference_external_db.date_dimension 
where full_date >> date_add('day', -1200, current_date)
)


select cycle_date, mem.pib_member_id, product, ti_td_interface_language,
dat.wsd, mem.user_id, mem.plan_id, mem.billing_account_id, comp.company_name, comp.company_industry, jf.department_code,

sum(case when product = 'Factiva' 
and ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Home'
and ti_td_page_subsection = 'Simple Search Results'
and event_name = 'page_view' then 1 else 0 end) simple_searches,

sum(case when product = 'Factiva'  
and ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Search'
and ti_td_page_subsection = 'Search'
and ti_td_page_driver = 'searchBuilder_Search'
and event_name = 'page_view'
and ti_td_search_filters_filters_author_included_count is null
and ti_td_search_filters_filters_subject_included_count is null
and ti_td_search_filters_filters_organization_included_count is null 
and ti_td_search_filters_filters_region_included_count is null
and ti_td_search_filters_filters_industry_included_count is null
and ti_td_search_filters_filters_executive_included_count is null
and ti_td_search_filters_filters_content_sources_included_count is null
and ti_td_search_filters_filters_author_excluded_count is null
and ti_td_search_filters_filters_subject_excluded_count is null
and ti_td_search_filters_filters_organization_excluded_count is null 
and ti_td_search_filters_filters_region_excluded_count is null
and ti_td_search_filters_filters_industry_excluded_count is null
and ti_td_search_filters_filters_executive_excluded_count is null
and ti_td_search_filters_filters_content_sources_excluded_count is null 
and ti_td_search_filters_filters_date_range_from is null
and ti_td_search_filters_filters_date_range_to is null
and ti_td_search_filters_filters_search_languages is null
and ti_td_search_filters_filters_keyword_count is null then 1 else 0 end) sb_searches,

sum(case when product = 'Factiva'  
and ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Search'
and ti_td_page_subsection = 'Search'
and ti_td_page_driver = 'SavedSearch_SelectSearch'
and event_name = 'page_view'
and ti_td_search_filters_filters_author_included_count is null
and ti_td_search_filters_filters_subject_included_count is null
and ti_td_search_filters_filters_organization_included_count is null 
and ti_td_search_filters_filters_region_included_count is null
and ti_td_search_filters_filters_industry_included_count is null
and ti_td_search_filters_filters_executive_included_count is null
and ti_td_search_filters_filters_content_sources_included_count is null
and ti_td_search_filters_filters_author_excluded_count is null
and ti_td_search_filters_filters_subject_excluded_count is null
and ti_td_search_filters_filters_organization_excluded_count is null 
and ti_td_search_filters_filters_region_excluded_count is null
and ti_td_search_filters_filters_industry_excluded_count is null
and ti_td_search_filters_filters_executive_excluded_count is null
and ti_td_search_filters_filters_content_sources_excluded_count is null 
and ti_td_search_filters_filters_date_range_from is null
and ti_td_search_filters_filters_date_range_to is null
and ti_td_search_filters_filters_search_languages is null
and ti_td_search_filters_filters_keyword_count is null
then 1 else 0 end) saved_searches, 

sum(case when product = 'Factiva'  
and ti_td_page_sub_subsection = 'Company Snapshot'
and ti_td_page_driver in ('Suggest', 'Lookup', 'RecentCompanySearches')
and event_name = 'page_view' then 1 else 0 end) cf_comp_searches,

sum(case when product = 'Factiva' 
and ti_td_page_sub_subsection = 'Industry Snapshot'
and ti_td_page_driver in ('Suggest', 'Lookup')
and event_name = 'page_view' then 1 else 0 end) cf_industry_searches,

sum(case when product = 'Factiva'  
and ti_td_page_sub_subsection = 'Executive Snapshot'
and ti_td_page_driver in ('Suggest', 'Lookup')
and event_name = 'page_view' then 1 else 0 end) cf_exec_searches,

sum(case when product = 'New Factiva'  
and ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'free text'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view' then 1 else 0 end) free_text_searches,

sum(case when product = 'New Factiva'  
and ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'newssubject'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view' then 1 else 0 end) news_subject_searches,

sum(case when product = 'New Factiva'  
and ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'industry'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view' then 1 else 0 end) industry_searches,

sum(case when product = 'New Factiva'  
and ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'company'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view' then 1 else 0 end) company_searches,

sum(case when product = 'New Factiva'  
and ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'source'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view' then 1 else 0 end) source_searches,

sum(case when product = 'New Factiva'  
and ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'region'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view' then 1 else 0 end) region_searches,

count(distinct visit_id) as total_visits,

count(distinct case when (ti_td_page_content_type = 'SearchResults' or
(ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type is not null
and ti_td_module_tracker like '%previous_page_location%')

or
(ti_td_page_driver in ('Suggest', 'Lookup', 'RecentCompanySearches') and 
ti_td_page_sub_subsection like '%Snapshot%' )) 

and event_name = 'page_view'
then
visit_id end) as search_visits


from pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join jf on mem.pib_member_id = jf.pib_member_id
left join dat on cast(djm.cycle_date as varchar) = dat.full_date


where product in ('Factiva', 'New Factiva')
and event_name in ('page_view', 'user_action')
and cycle_date >>= cast('2024-06-01' as date)
--and mem.pib_member_id = 'D3WZYJ7S5KA2EG2LDTRNJXGZTA'
group by 1,2,3,4,5,6,7,8,9,10,11
