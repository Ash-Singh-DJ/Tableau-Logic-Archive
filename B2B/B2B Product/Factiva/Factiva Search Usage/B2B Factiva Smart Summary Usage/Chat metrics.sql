-- Dashboard   : "B2B Factiva Smart Summary Usage"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Chat metrics" = published source "Chat metrics"  [B2B / B2B Testing]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select date_time, substring(cast(cycle_date as varchar),1,10) as year_month_day, event_id, event_name, mem.pib_member_id, mem.user_id,
mem.billing_account_id, comp.company_name, ti_td_page_url, ti_td_page_section, ti_td_action, 
ti_td_ad_createdat, ti_td_ad_lastengaged, ti_td_ad_lastupdated, ti_td_ad_searchid, ti_td_ad_thread_depth, visit_id
FROM pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
WHERE product = 'New Factiva'
and event_name in  ('page_view', 'user_action')
--and user_info_user_ref = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
and (ti_td_action like '%chat%' or ti_td_ad_searchid <<>> '')   
and ti_td_action <<>> 'select_top_hat_live_chat'
and cycle_date >>= cast('2026-03-01' as date)

union all

select null as date_time, substring(cast(cycle_date as varchar),1,10) as year_month_day, null as event_id, null as event_name, mem.pib_member_id, mem.user_id,
mem.billing_account_id, comp.company_name, null as ti_td_page_url, null as ti_td_page_section, null as ti_td_action, 
null as ti_td_ad_createdat, null as ti_td_ad_lastengaged, null as ti_td_ad_lastupdated, null as ti_td_ad_searchid, null as ti_td_ad_thread_depth, visit_id 
FROM pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
WHERE product = 'New Factiva'
and event_name in  ('page_view', 'user_action')
and cycle_date >>= cast('2026-03-01' as date)
