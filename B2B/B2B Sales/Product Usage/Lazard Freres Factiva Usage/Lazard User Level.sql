-- Dashboard   : "Lazard Freres Factiva Usage"  [B2B / B2B Sales / Product Usage]
-- Data source : "Lazard User Level" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with ml as 
(select mem.pib_member_id,
min(cycle_date) first_login
from pib_event_data.pib_product_metrics djm 
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
where event_name in ('page_view','user_action')
and product in ('Factiva', 'New Factiva')
and comp.company_name = 'LAZARD FRERES SAS'
group by 1
),

aa as 
(select mem.pib_member_id,
min(cycle_date) aa_first_login
from fact_external_db.omniture_event_fact omnit
inner join dimension_external_db.pib_membership_dimension mem on omnit.post_evar3 = mem.pib_member_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
where lower(post_pagename) NOT LIKE '%login%' and
CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9'))
and reporting_suite = 'djfactiva'
and comp.company_name = 'LAZARD FRERES SAS'
group by 1)



select substring(cast(cycle_date as varchar),1,7) as year_month, mem.pib_member_id, mem.user_id, mem.first_name, mem.last_name, mem.email, mem.billing_account_id,
ml.first_login, aa.aa_first_login,
count(distinct TIME_BASED_VISIT_ID) as visit_count,
sum(case when event_name in ('page_view','user_action') then 1 else 0 end) page_views_actions,
count(case when event_name = 'page_view' and ti_td_article_id is not null then ti_td_article_id end) article_views,


sum(case when product = 'Factiva' 
and ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Home'
and ti_td_page_subsection = 'Simple Search Results'
and event_name = 'page_view' then 1 else 0 end) simple_searches,

sum(case when product = 'Factiva'  
and ti_td_page_content_type = 'SearchResults'
and ti_td_page_section = 'Search'
and ti_td_page_subsection = 'Search'
and ti_td_page_driver in  ('searchBuilder_Search', 'SavedSearch_SelectSearch')
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

sum(case when product = 'New Factiva'  
and ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type is not null
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view' then 1 else 0 end) NF_searches


from pib_event_data.pib_product_metrics djm 
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join ml on mem.pib_member_id = ml.pib_member_id
left join aa on mem.pib_member_id = aa.pib_member_id
where event_name in ('page_view','user_action')
and product in ('Factiva', 'New Factiva')
and comp.company_name = 'LAZARD FRERES SAS'
and cycle_date >>= cast('2025-01-01' as date)
and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
group by 1,2,3,4,5,6,7,8,9
