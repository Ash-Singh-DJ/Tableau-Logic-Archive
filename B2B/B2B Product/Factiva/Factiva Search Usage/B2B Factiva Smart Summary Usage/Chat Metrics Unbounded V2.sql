-- Dashboard   : "B2B Factiva Smart Summary Usage"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Chat Metrics Unbounded V2" = published source "Chat Metrics Unbounded V2"  [B2B / B2B Testing]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with a as 
(select user_info_user_ref, 
min(case when 
event_name = 'user_action'
and (ti_td_action = 'chat_ask_input' or ti_td_action = 'new_unbounded_chat')
then cycle_date end) as min_date
from pib_event_data.pib_product_metrics 
where product in ('New Factiva','DJP Energy')
AND cycle_date >>= cast('2026-04-01' as date)
and event_name = 'user_action'
and (ti_td_action = 'chat_ask_input' or ti_td_action = 'new_unbounded_chat')
group by 1)


select date_time, substring(cast(cycle_date as varchar),1,10) as year_month_day, product, event_id, event_name, mem.pib_member_id, mem.user_id,
mem.billing_account_id, comp.company_name, ti_td_page_url, ti_td_page_section, ti_td_action, LAG(ti_td_action) over (partition by visit_id order by date_time) as prev_event, 
ti_td_ad_createdat, ti_td_ad_lastengaged, ti_td_ad_lastupdated, coalesce(ti_td_ad_searchid, ti_td_searchid) as ti_td_ad_searchid, coalesce(ti_td_ad_thread_depth,ti_td_thread_depth) as ti_td_ad_thread_depth, visit_id, a.min_date, date_add('day', 14, a.min_date) as min_date_14,
     case when coalesce(ti_td_ad_searchid, ti_td_searchid) is null then false  
   WHEN ROW_NUMBER() OVER (
            PARTITION BY coalesce(ti_td_ad_searchid, ti_td_searchid)
            ORDER BY date_time
        ) = 1 THEN TRUE
        ELSE FALSE
    END AS first_search_event,
    
    case when coalesce(ti_td_ad_searchid, ti_td_searchid) is null then false  
   WHEN ROW_NUMBER() OVER (
            PARTITION BY pib_member_id
               ORDER BY
                case WHEN coalesce(ti_td_ad_searchid, ti_td_searchid) IS NOT NULL THEN  date_time end
        ) = 1 THEN TRUE
        ELSE FALSE
    END AS first_search_event_ever


FROM pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left JOIN a on djm.user_info_user_ref = a.user_info_user_ref
WHERE product in ('New Factiva','DJP Energy')
and event_name in  ('page_view', 'user_action')
--and visit_id = 'DJPENERGY_20260910_E6OO2HVCQHVPEKOJVPIZBZ36TU_000005'
--and djm.user_info_user_ref = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
and (((ti_td_action like '%chat%' and ti_td_action <<>> 'select_top_hat_live_chat') or ti_td_ad_searchid <<>> '')   
or (ti_td_action = 'summary_go_deeper' and ti_td_page_section = 'keyword')) 
and cycle_date >>= cast('2026-03-01' as date)

union all 


select null as date_time, substring(cast(cycle_date as varchar),1,10) as year_month_day, product, null as event_id, null as event_name, mem.pib_member_id, mem.user_id,
mem.billing_account_id, comp.company_name, null as ti_td_page_url, null as ti_td_page_section, null as ti_td_action, null as prev_event,
null as ti_td_ad_createdat, null as ti_td_ad_lastengaged, null as ti_td_ad_lastupdated, null as ti_td_ad_searchid, null as ti_td_ad_thread_depth, visit_id,
null as min_date, null as min_date_14, null as first_search_event, null as first_search_event_ever


FROM pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
WHERE product in ('New Factiva','DJP Energy')
--and user_info_user_ref = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
and event_name in  ('page_view', 'user_action')
and cycle_date >>= cast('2026-03-01' as date)
