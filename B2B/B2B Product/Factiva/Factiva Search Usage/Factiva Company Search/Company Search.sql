-- Dashboard   : "Factiva Company Search"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Company Search" = published source "Company Search"  [B2B / B2B Testing]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select year_month, product, pib_member_id, billing_account_id, company_name, plan_id,
(case when product = 'Factiva' then ti_td_profile_name 
when product = 'New Factiva' then ti_td_page_subsection end) as search_comp_name,
(nf_company_searches + cf_comp_searches) as total_searches
from

(select substring(cast(cycle_date as varchar),1,7) as year_month, product, ti_td_page_subsection, ti_td_profile_name,
mem.pib_member_id, mem.billing_account_id, mem.plan_id, comp.company_name,

sum(case when product = 'New Factiva'  
and ti_td_page_content_type = 'ResearchTools'
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'company'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view' then 1 else 0 end) nf_company_searches,


sum(case when product = 'Factiva'  
and ti_td_page_sub_subsection = 'Company Snapshot'
and ti_td_page_driver in ('Suggest', 'Lookup', 'RecentCompanySearches')
and event_name = 'page_view' then 1 else 0 end) cf_comp_searches

from pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 

where product in ('Factiva', 'New Factiva')
and event_name in ('page_view', 'user_action')
and ((ti_td_search_record_type = 'company' and ti_td_page_content_type_detail = 'search results') or  
(ti_td_page_sub_subsection = 'Company Snapshot'
and ti_td_page_driver in ('Suggest', 'Lookup', 'RecentCompanySearches'))) 
and cycle_date >>= cast('2024-12-01' as date)

group by 1,2,3,4,5,6,7,8)
