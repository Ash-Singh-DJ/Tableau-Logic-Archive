-- Dashboard   : "Factiva Search Samples"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Expert Searches" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from (

with g as ( 

with pt as
(
select substring(cast(event_datetime as varchar),1,16) as date_time,
client_user_id, request_headers_x_dj_access_point_code ,

transaction_resource_target,  coalesce(keyword_search_term, search_term_with_codes) as keyword_search_term, 
content_languages, date_range, length(keyword_search_term) as search_characters
from pib_event_data.pib_platform_trace
where 
--(transaction_resource_target = '/content/semantic-search' or transaction_resource_target = '/content/search')
--and request_headers_x_dj_access_point_code = 'FH'
--and request_message_body like '%scope%'
cycle_date >>= cast('2023-06-01' as date)
and cycle_date << cast('2025-11-03' as date)
and (keyword_search_term is not null or search_term_with_codes is not null)
--and  client_user_id = 'E000588565'
--and  strpos(request_message_body, keyword_search_term) >> 0 
--and lower(request_message_body) not like '%"value":"rst=%'
--and request_message_body not like '%"value":"wc>>0%'
group by 1,2,3,4,5,6,7,8
)


select substring(cast(djm.date_time as varchar),1,16) as date_time,
mem.pib_member_id,
mem.user_id,
mem.plan_id,
visit_id,
ti_td_search_filters_factiva_expert_search_descriptor,
ti_td_search_filters_factiva_expert_search_code,
ti_td_search_filters_search_languages,
ti_td_search_number_of_characters,
pt.keyword_search_term, 
pt.request_headers_x_dj_access_point_code 

from pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
left join pt on (substring(cast(djm.date_time as varchar),1,16) = pt.date_time
and mem.user_id = pt.client_user_id
and djm.ti_td_search_number_of_characters = pt.search_characters)

--where mem.user_id = 'E000588565'
where Product in ('Factiva')
and djm.event_name in ('page_view', 'user_action') 
and djm.date_time >>= cast('2023-06-01' as date)
and djm.date_time << cast('2025-11-03' as date)
and ti_td_page_content_type = 'SearchResults'
and mem.billing_account_id not like '9ZZZ%'
and mem.billing_account_id not like '9ZFB%'
and mem.billing_account_id <<>> '9DOW003600'
and mem.billing_account_id <<>> '9DOW007100'
and mem.billing_account_id <<>> '9FAC067700'
and ti_td_search_filters_factiva_expert_search_code is not null
--and date_time << cast('2023-06-02' as date) 
order by djm.date_time)

select g.*,  concat(upper(substr(to_base(crc32(to_utf8(pib_member_id)), 36), 1, 8)),substring(user_id,7,3)) as hash_id, RANK() over (partition by pib_member_id, visit_id order by date_time) as rnk
from g
where g.keyword_search_term is not null
group by 1,2,3,4,5,6,7,8,9,10,11,12)

where rnk = 1
