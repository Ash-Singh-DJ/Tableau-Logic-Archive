-- Published data source : "Smart Summary V2 True North"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with jf as
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT'),

wk as
(select substring(cast(full_date as varchar),1,10) year_month_day, substring(cast(week_start_date as varchar),1,10) week_start, day_of_week from reference_external_db.date_dimension
where substring(cast(full_date as varchar),1,10) >>= cast('2021-01-01' as varchar)
order by full_date)



select date_time, event_id, cycle_date, cast(cycle_date as varchar) year_month_day, wk.week_start,  mem.user_id, mem.pib_member_id, jf.department_code, 
mem.email, mem.first_name, mem.last_name, mem.plan_id,
comp.company_name, bad.cibs_billing_account_id, event_name, ti_td_action, ti_td_semantic_search_summary_view, 
ti_td_semantic_search_summary_available, ti_td_page_url, lag(ti_td_page_url, 1) over (partition by visit_id order by date_time) as url_lag, 
visit_id, ti_td_page_section, ti_td_page_content_type, ti_td_module_tracker,
concat(upper(substr(to_base(crc32(to_utf8(visit_id)), 36), 1, 8)),upper(substr(to_base(crc32(to_utf8(mem.user_id)), 36), 1, 8))) as hash_id
              
        
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join jf on mem.pib_member_id = jf.pib_member_id
LEFT JOIN wk on cast(djm.cycle_date as varchar) = wk.year_month_day

WHERE product = 'New Factiva'
and cycle_date >>= cast('2025-03-01' as date)
and ti_td_page_section = 'keyword'
--and user_info_user_ref = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
 and ( (event_name = 'page_view'
 and ti_td_page_content_type_detail = 'search results'
 and ti_td_search_record_type = 'free text'
 and ti_td_module_tracker like '%previous_page_location%'
 )
 or  
 (event_name = 'user_action'
 and ti_td_action like '%summary%'
and (ti_td_action <<>> 'smart_summary_available')
and (ti_td_semantic_search_summary_view is not null or ti_td_summary_view is not null  or ti_td_lens is not null)
 )
 or 
((event_name = 'page_view' or ti_td_action like 'article_%') and ti_td_module_tracker like '%searchSummary%'
and ti_td_page_content_type = 'Article')
or  
(event_name = 'user_action'
 and ti_td_action = 'copy_summary')
)
