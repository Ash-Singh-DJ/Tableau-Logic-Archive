-- Dashboard   : "B2B True North FY27"  [B2B]
-- Data source : "SS and AI Usage" = published source "SS and AI Usage"  [B2B]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select year_month_day, EID, visit_id, plan_id, product, company_name, cibs_billing_account_id, company_industry,
event_name, ti_td_ad_searchid, ti_td_action,  action_lead, action_lead_2, action_lead_3, action_lead_4, action_lead_5,
ti_td_page_section, ti_td_page_subsection, ti_td_semantic_search_summary_available, ti_td_page_url,

CASE
    WHEN DATE_TRUNC('MONTH',cycle_date)  = DATE_TRUNC('MONTH', DATE_ADD('MONTH', -1, CURRENT_DATE))
        THEN 'LATEST_MONTH'
    WHEN DATE_TRUNC('MONTH',cycle_date) = DATE_TRUNC('MONTH', DATE_ADD('MONTH', -2, CURRENT_DATE))
        THEN 'PRIOR_MONTH'
    WHEN DATE_TRUNC('MONTH',cycle_date) = DATE_TRUNC(
                         'MONTH',
                         DATE_ADD(
                             'YEAR', -1,
                             DATE_ADD('MONTH', -1, CURRENT_DATE)
                         )
                     )
        THEN 'PRIOR_YEAR'
END AS PERIOD_FLAG

from (
select date_time, event_id, cast(cycle_date as varchar) year_month_day, cycle_date, product, mem.pib_member_id as EID, mem.plan_id,
comp.company_name, bad.cibs_billing_account_id, comp.company_industry, event_name, ti_td_action, ti_td_ad_searchid,
lead(ti_td_action, 1) over (partition by ti_td_page_url order by date_time) as action_lead,
lead(ti_td_action, 2) over (partition by ti_td_page_url  order by date_time) as action_lead_2,
lead(ti_td_action, 3) over (partition by ti_td_page_url  order by date_time) as action_lead_3,
lead(ti_td_action, 4) over (partition by ti_td_page_url  order by date_time) as action_lead_4,
lead(ti_td_action, 5) over (partition by ti_td_page_url  order by date_time) as action_lead_5,

ti_td_semantic_search_summary_view, ti_td_lens, ti_td_summary_view, ti_td_search_result_type, 
ti_td_summary_search_type,
ti_td_semantic_search_summary_available, ti_td_page_url, lag(ti_td_page_url, 1) over (partition by visit_id order by date_time) as url_lag, 
visit_id, ti_td_page_section, ti_td_page_subsection, ti_td_page_content_type, ti_td_module_tracker, ti_td_ad_company_name, ti_td_ad_state, ti_td_ad_section_name 
                     
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
WHERE product = 'New Factiva'
and cycle_date >>= cast('2025-12-01' as date)
--and visit_id = 'NEWFACTIVA_20260414_D3WZYJYBD4BQBZHWW5GQ5PYAAA_000001'
--and mem.pib_member_id = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
 and ( (event_name = 'page_view'
 and ti_td_page_content_type_detail = 'search results'
 and ti_td_search_record_type in ('free text','company')
 and ti_td_module_tracker like '%previous_page_location%'
)
 or 
 (event_name = 'user_action'
 and (ti_td_action like '%summary%' or ti_td_action like '%lens%')
and (ti_td_semantic_search_summary_view is not null or ti_td_summary_view is not null  or ti_td_lens is not null)
 )
  or 
 (event_name = 'user_action' and ti_td_page_subsection = 'Smart Report')
 or 
 (event_name = 'user_action' and ti_td_action = 'smart_summary_available')
 or
 ((ti_td_action like '%chat%' and ti_td_action <<>> 'select_top_hat_live_chat' and ti_td_action <<>> 'direct_chat') or ti_td_ad_searchid <<>> '')
 ))
 
 where (ti_td_action is null or ti_td_action <<>> 'smart_summary_available')

union all


select year_month_day, EID, visit_id, plan_id, product, company_name, cibs_billing_account_id, company_industry,
event_name, ti_td_ad_searchid, ti_td_action,  action_lead, action_lead_2, action_lead_3, action_lead_4, action_lead_5,
ti_td_page_section, ti_td_page_subsection, ti_td_semantic_search_summary_available, ti_td_page_url,

CASE
    WHEN DATE_TRUNC('MONTH',cycle_date)  = DATE_TRUNC('MONTH', DATE_ADD('MONTH', -1, CURRENT_DATE))
        THEN 'LATEST_MONTH'
    WHEN DATE_TRUNC('MONTH',cycle_date) = DATE_TRUNC('MONTH', DATE_ADD('MONTH', -2, CURRENT_DATE))
        THEN 'PRIOR_MONTH'
    WHEN DATE_TRUNC('MONTH',cycle_date) = DATE_TRUNC(
                         'MONTH',
                         DATE_ADD(
                             'YEAR', -1,
                             DATE_ADD('MONTH', -1, CURRENT_DATE)
                         )
                     )
        THEN 'PRIOR_YEAR'
END AS PERIOD_FLAG

from (
select date_time, event_id, cast(cycle_date as varchar) year_month_day, cycle_date, product, mem.pib_member_id as EID, mem.plan_id,
comp.company_name, bad.cibs_billing_account_id, comp.company_industry, event_name, ti_td_action, ti_td_ad_searchid,
lead(ti_td_action, 1) over (partition by ti_td_page_url order by date_time) as action_lead,
lead(ti_td_action, 2) over (partition by ti_td_page_url  order by date_time) as action_lead_2,
lead(ti_td_action, 3) over (partition by ti_td_page_url  order by date_time) as action_lead_3,
lead(ti_td_action, 4) over (partition by ti_td_page_url  order by date_time) as action_lead_4,
lead(ti_td_action, 5) over (partition by ti_td_page_url  order by date_time) as action_lead_5,

ti_td_semantic_search_summary_view, ti_td_lens, ti_td_summary_view, ti_td_search_result_type, 
ti_td_summary_search_type,
ti_td_semantic_search_summary_available, ti_td_page_url, lag(ti_td_page_url, 1) over (partition by visit_id order by date_time) as url_lag, 
visit_id, ti_td_page_section, ti_td_page_subsection, ti_td_page_content_type, ti_td_module_tracker, ti_td_ad_company_name, ti_td_ad_state, ti_td_ad_section_name 
                     
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
WHERE product = 'Dragonfly'
and cycle_date >>= cast('2026-04-01' as date)
--and visit_id = 'NEWFACTIVA_20260414_D3WZYJYBD4BQBZHWW5GQ5PYAAA_000001'
--and mem.pib_member_id = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
 and ( (event_name = 'page_view'
and ti_td_page_url like '%query=%'
and ti_td_page_section = 'Search'
)
 or 
 (event_name = 'user_action' and  (ti_td_action = 'ai_assistant_query_submitted')))
)
