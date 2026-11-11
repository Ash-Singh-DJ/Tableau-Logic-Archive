-- Published data source : "B2B New Factiva Search and Filter Actions - Viz Draft"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with ng as
(select date_time, user_info_user_ref as EID, mem.user_id, bill.cibs_billing_account_id, comp.company_name, visit_id, event_id,  ti_td_search_record_type, coalesce(ti_td_ad_search_filters_search_number_of_filters,0) as filter_num,
coalesce(ti_td_ad_search_filters_search_number_of_filters_excluded,0) as filter_num_ex, ti_td_ad_search_filters_companies as filter_comp, ti_td_ad_search_filters_sources as filter_sources,
ti_td_ad_search_filters_time_period as filter_period, ti_td_ad_search_filters_regions as filter_region, ti_td_ad_search_filters_industries as filter_ind, ti_td_ad_search_filters_subjects as filter_sub, ti_td_ad_search_filters_organization as filter_org,ti_td_ad_search_filters_media_type as filter_media, 
ti_td_ad_search_filters_newssubject as filter_ns, ti_td_ad_search_filters_language as filter_lang 
from 
--select * from
pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two  = comp.company_sfdc_id 
where product = 'New Factiva'
--and visit_id = 'NEWFACTIVA_20230619_E6OO2HVCQHVPFICLUBMGV2NQG4_000003'
--and user_info_user_ref = 'D3WZYJ7S5KA2ELEZ622Z36VYAQ'
and ti_td_action = 'filter_search'
and event_name = 'user_action'
and cycle_date >>= cast('2023-06-01' as date)
--and ti_td_ad_search_filters_search_number_of_filters_excluded >> 0 
order by user_info_user_ref, date_time),

bh as 
(select row_number() over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as row_num, 
date_time, EID, user_id, cibs_billing_account_id, company_name, visit_id, ti_td_search_record_type, filter_num, filter_num_ex,
coalesce(lag(filter_num,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time),0) as filter_num_lag,
coalesce(lag(filter_num_ex,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time),0) as filter_num_ex_lag,
filter_comp, lag(filter_comp,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_comp_lag,
filter_sources, lag(filter_sources,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_sources_lag,
filter_period, lag(filter_period,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_period_lag,
filter_region, lag(filter_region,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_region_lag,
filter_ind, lag(filter_ind,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_ind_lag,
filter_sub, lag(filter_sub,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_sub_lag,
filter_media, lag(filter_media,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_media_lag,
filter_org, lag(filter_org,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_org_lag,
filter_lang, lag(filter_lang,1) over(PARTITION BY visit_id, ti_td_search_record_type order by date_time) as filter_lang_lag

from ng),

gu as
(select date_time, EID, user_id, cibs_billing_account_id, company_name,  ti_td_search_record_type, (case when (filter_num - filter_num_lag = 1) and filter_comp like '%included%'
and (filter_comp_lag is null or filter_comp_lag <<>> filter_comp)  then 'comp_filter_apply'

when (filter_num_ex - filter_num_ex_lag = 1) and filter_comp like '%excluded%'
and (filter_comp_lag is null or filter_comp_lag <<>> filter_comp) then 'comp_ex_filter_apply'

when (filter_num - filter_num_lag = 1) and filter_sources like '%included%'
and (filter_sources_lag is null or filter_sources_lag <<>> filter_sources) then 'sources_filter_apply'

when (filter_num_ex - filter_num_ex_lag = 1) and filter_sources like '%excluded%'
and (filter_sources_lag is null or filter_sources_lag <<>> filter_sources) then 'sources_ex_filter_apply'

when (filter_num - filter_num_lag = 1) and filter_region like '%included%' 
and (filter_region_lag is null or filter_region_lag <<>> filter_region) then 'region_filter_apply'

when (filter_num_ex - filter_num_ex_lag = 1) and filter_region like '%excluded%'
and (filter_region_lag is null or filter_region_lag <<>> filter_region) then 'region_ex_filter_apply'

when (filter_num - filter_num_lag = 1) and filter_ind like '%included%'
and (filter_ind_lag is null or filter_ind_lag <<>> filter_ind) then 'ind_filter_apply'

when (filter_num_ex - filter_num_ex_lag = 1) and filter_ind like '%excluded%'
and (filter_ind_lag is null or filter_ind_lag <<>> filter_ind) then 'ind_ex_filter_apply'

when (filter_num - filter_num_lag = 1) and filter_sub like '%included%'
and (filter_sub_lag is null or filter_sub_lag <<>> filter_sub) then 'sub_filter_apply'

when (filter_num_ex - filter_num_ex_lag = 1) and filter_sub like '%excluded%'
and (filter_sub_lag is null or filter_sub_lag <<>> filter_sub) then 'sub_ex_filter_apply'

when (filter_num - filter_num_lag = 1) and filter_media <<>> 'All'
and (filter_media_lag is null or filter_media_lag <<>> filter_media) then 'media_filter_apply'

when (filter_num - filter_num_lag = 1) and filter_lang like '%included%'
and (filter_lang_lag is null or filter_lang_lag <<>> filter_lang) then 'lang_filter_apply'

when (filter_num_ex - filter_num_ex_lag = 1) and filter_lang like '%excluded%'
and (filter_lang_lag is null or filter_lang_lag <<>> filter_lang) then 'lang_ex_filter_apply'

when (filter_num - filter_num_lag = -1) and filter_comp is null 
and filter_comp_lag is not null then 'comp_filter_remove'
when (filter_num - filter_num_lag = -1) and filter_sub is null 
and filter_sub_lag is not null then 'sub_filter_remove'
when (filter_num - filter_num_lag = -1) and filter_sources is null 
and filter_sources_lag is not null then 'sources_filter_remove'
when (filter_num - filter_num_lag = -1) and filter_region is null 
and filter_region_lag is not null then 'region_filter_remove'
when (filter_num - filter_num_lag = -1) and filter_media is not null 
and filter_media_lag <<>> filter_media then 'media_filter_remove'
when (filter_num - filter_num_lag = -1) and filter_ind is null 
and filter_ind_lag is not null then 'ind_filter_remove'

when (filter_num - filter_num_lag = -1) and filter_lang is null 
and filter_lang_lag is not null then 'lang_filter_remove'
when (filter_num - filter_num_lag = -1) and filter_org is null 
and filter_org_lag is not null then 'org_filter_remove'

when filter_period <<>> filter_period_lag or 
(filter_num = 1 and row_num = 1 and filter_period is not null 
and filter_region is null and filter_comp is null and filter_sources is null and 
filter_ind is null and filter_sub is null and filter_org is null and filter_lang is null and filter_media = 'All')
then filter_period

end) fil_action
from bh)
select * from gu where fil_action is not null

union all 

select date_time, user_info_user_ref as EID, mem.user_id, bill.cibs_billing_account_id, comp.company_name, ti_td_search_record_type,
(case when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'company' and ti_td_module_tracker not like '%InterestClick%' then 'comp_search_box' 
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'industry' and ti_td_module_tracker not like '%InterestClick%' then 'ind_search_box'
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'region' and ti_td_module_tracker not like '%InterestClick%' then 'reg_search_box'
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'newssubject' and ti_td_module_tracker not like '%InterestClick%' then 'ns_search_box'
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'free text' and ti_td_module_tracker not like '%InterestClick%' then 'free_text_search_box'
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'company' and ti_td_module_tracker like '%InterestClick%' then 'comp_search_interest'
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'industry' and ti_td_module_tracker like '%InterestClick%' then 'ind_search_interest' 
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'region' and ti_td_module_tracker like '%InterestClick%' then 'reg_search_interest' 
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'newssubject' and ti_td_module_tracker like '%InterestClick%' then 'ns_search_interest' 
when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' 
and ti_td_search_record_type = 'free text' and ti_td_module_tracker like '%InterestClick%' then 'free_text_search_interest' 
end) fil_action
from pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two  = comp.company_sfdc_id 
where product = 'New Factiva'
and ti_td_search_record_type is not null
and ti_td_page_content_type_detail = 'search results'
and event_name = 'page_view'
--and visit_id = 'NEWFACTIVA_20230619_E6OO2HVCQHVPFICLUBMGV2NQG4_000003'
and cycle_date >>= cast('2023-06-01' as date)

and ti_td_module_tracker is not null


union all 

select date_time, user_info_user_ref as EID, mem.user_id, bill.cibs_billing_account_id, comp.company_name,  lower(ti_td_page_section) as ti_td_search_record_type, 
(case when ti_td_action like 'filter%' or ti_td_action = 'view_original_article' then ti_td_action
when ti_td_action = 'toggle_translated' and ti_td_ad_translated_on = true then 'toggle_translated_on'  
when ti_td_action = 'toggle_translated' and ti_td_ad_translated_on = false then 'toggle_translated_off' end) as fil_action 

from pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two  = comp.company_sfdc_id 
where product = 'New Factiva'
and event_name = 'user_action'
--and user_info_user_ref = 'E6OO2HVCQHVPEPANGQ24BZENIA'
---and visit_id = 'NEWFACTIVA_20230619_E6OO2HVCQHVPFICLUBMGV2NQG4_000003'
and (ti_td_action like 'filter_pane%' or ti_td_action = 'filters_open' or ti_td_action = 'filters_close' or ti_td_action = 'toggle_translated' or ti_td_action = 'view_original_article') 
and cycle_date >>= cast('2023-06-01' as date)

union all 

select date_time, user_info_user_ref as EID, mem.user_id, bill.cibs_billing_account_id, comp.company_name, ti_td_search_record_type, ti_td_ad_order_by as fil_action
from pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two  = comp.company_sfdc_id 
where product = 'New Factiva'
and event_name = 'user_action'
--and visit_id = 'NEWFACTIVA_20230619_E6OO2HVCQHVPFICLUBMGV2NQG4_000003'
and ti_td_action = 'sort_by'
and cycle_date >>= cast('2023-06-01' as date)
