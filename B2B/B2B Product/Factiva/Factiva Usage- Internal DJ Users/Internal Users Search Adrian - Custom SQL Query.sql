-- Dashboard   : "Factiva Usage: Internal DJ Users"  [B2B / B2B Product / Factiva]
-- Data source : "Internal Users Search Adrian" (embedded in the workbook)
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




cy as 
(with lena as 
(select date_time, post_evar3 as EID, geo_country
FROM fact_external_db.omniture_event_fact omnit
where reporting_suite = 'djfactiva'
--and post_evar3 = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
group by 1,2,3)

select * from lena 
where date_time = (select max(date_time) from lena lenb where lena.EID = lenb.EID))



select substring(cast(djm.cycle_date as varchar),1,7) year_month, mem.user_status, mem.user_id, mem.pib_member_id, mem.first_name, mem.last_name, mem.email, mem.billing_account_id, comp.company_name, jf.department_code, cy.geo_country, ref1.country_name,
ref1.region, product,
count(distinct case when event_name = 'page_view' or event_name = 'user_action' then djm.visit_id end) visits,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type is not null
and event_name = 'page_view'
and ti_td_module_tracker like '%previous_page_location%'
and djm.product = 'New Factiva' then 1 else 0 end) total_NF_Searches,

sum(case when product = 'New Factiva' and ti_td_page_section = 'Search Builder' and event_name = 'user_action'
and ti_td_action in ('initial_search','modify_search') then 1 else 0 end) as NF_SB_searches,


sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'keyword'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'free text'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view'
and djm.product = 'New Factiva' then 1 else 0 end) NF_Free_text_Searches,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'Company'
and ti_td_page_content_type_detail = 'search results'
and (ti_td_search_record_type = 'company' or ti_td_search_record_type = 'industry') 
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view'
and djm.product = 'New Factiva' then 1 else 0 end) NF_CompanyIndustry_Searches,

sum(case when ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Home'
and ti_td_page_subsection = 'Simple Search Results'
and event_name = 'page_view'
and djm.product = 'Factiva' then 1 else 0 end) Simple_Searches,

sum(case when ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Search'
and ti_td_page_subsection = 'Search'
and ti_td_page_driver = 'searchBuilder_Search'
and event_name = 'page_view'
and djm.product = 'Factiva' 
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
and ti_td_search_filters_filters_content_sources_excluded_count is null then 1 else 0 end) SB_Searches,

sum(case when ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Search'
and ti_td_page_subsection = 'Search'
and ti_td_page_driver = 'SavedSearch_SelectSearch'
and event_name = 'page_view'
and djm.product = 'Factiva' then 1 else 0 end) Saved_Searches,

sum(case when ti_td_page_content_type = 'ResearchTools'
and ti_td_page_section = 'Companies and Markets'
and (ti_td_page_sub_subsection = 'Company Snapshot' or ti_td_page_sub_subsection = 'Industry Snapshot') 
and event_name = 'page_view'
and djm.product = 'Factiva' then 1 else 0 end) CompInd_Snapshots,

sum(case when ti_td_article_id is not null and event_name = 'page_view' then 1 else 0 end) as article_views,

sum(case when event_name = 'user_action' and product = 'New Factiva'
 and (ti_td_action like '%summary%' or ti_td_action like '%lens%')
and (ti_td_semantic_search_summary_view is not null or ti_td_summary_view is not null  or ti_td_lens is not null)
then 1 else 0 end) as summary_clicks,

count(distinct case when event_name = 'user_action' and product = 'New Factiva'
and ti_td_action in ('new_unbounded_chat', 'chat_ask_input') then ti_td_ad_searchid end) as chat_threads  


FROM pib_event_data.pib_product_metrics djm
inner JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN cy on mem.pib_member_id = cy.EID 
left join reference_external_db.country_reference ref1 on cy.geo_country = ref1.geo_country 
left join jf on mem.pib_member_id = jf.pib_member_id 
WHERE product in ('New Factiva', 'Factiva')
and event_name in ('user_action','page_view')
and djm.cycle_date >>= cast('2025-04-01' as date)
and (
 mem.billing_account_id like '9ZFB%'

 or mem.billing_account_id = '9DOW003600'
 or mem.billing_account_id = '9DOW007100'
 or mem.billing_account_id = '9FAC067700')
 and first_name <<>> 'test'
 and last_name <<>> 'test'
 and lower(mem.email) not like '%yopmail%'
 and mem.email not like '%ubs%'
 and mem.email not like '%mailinator%'
 and mem.email not like '%jpmorgan%'
 --and  mem.user_status = 'A'
and ti_td_page_url  not like '%pub-betaaissummary%'
and ti_td_page_url  not like '%dj.beta%'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14
having count(distinct case when event_name = 'page_view' or event_name = 'user_action' then djm.visit_id end) >> 0
