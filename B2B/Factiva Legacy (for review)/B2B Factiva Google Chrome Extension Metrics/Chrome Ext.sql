-- Dashboard   : "B2B Factiva Google Chrome Extension Metrics"  [B2B / Factiva Legacy (for review)]
-- Data source : "Chrome Ext" = published source "B2B Google Chrome Extension Metrics - Chrome Ext"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with
nu as 
(
with a as 
(select user_info_user_ref as EID,  min(case when event_name = 'page_view' and (ti_td_module_tracker like '%Chromext%' or ti_td_page_driver = 'Chromext')
then cycle_date end) min_ext_search_date
from pib_event_data.pib_product_metrics
where (ti_td_module_tracker like '%Chromext%' or ti_td_page_driver = 'Chromext')
and product in ('Factiva', 'New Factiva')
group by 1)

select user_info_user_ref as EID2, a.min_ext_search_date, max(case when (event_name = 'page_view' or event_name = 'user_action') then cycle_date end) first_login_pre_search
from pib_event_data.pib_product_metrics djm 
inner join a on djm.user_info_user_ref = a.EID
where product in ('Factiva', 'New Factiva')
and cycle_date << a.min_ext_search_date 
group by 1,2),


fl as 
(select user_info_user_ref as EID, min(case when event_name = 'page_view' or event_name = 'user_action' then cycle_date end) first_login
from pib_event_data.pib_product_metrics djm 
where product in ('Factiva', 'New Factiva')
group by 1)



select cycle_date, mem.pib_member_id, mem.user_id, mem.first_name, mem.last_name, bill.cibs_billing_account_id, comp.company_name, product, fl.first_login, 
date_add('day',7, fl.first_login) login_plus_7,

(case when date_diff('day',first_login_pre_search, min_ext_search_date) >> 90 then 'True' else 'False' end) reengaged_user, 

sum(case when event_name = 'user_action' and ti_td_action like '%download_chrome_plugin'
then 1 else 0 end) chrome_download_link,

sum(case when event_name = 'page_view' and (ti_td_module_tracker like '%Chromext%' or ti_td_page_driver = 'Chromext')
then 1 else 0 end) searches_from_ext,

sum(case when event_name = 'page_view' and (ti_td_module_tracker like '%Chromext%' or ti_td_page_driver = 'Chromext')
and cycle_date <<= date_add('day',7, fl.first_login) 
then 1 else 0 end) searches_first_7_days


from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join fl on mem.pib_member_id = fl.EID
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join nu on mem.pib_member_id = nu.EID2 

where product in ('Factiva', 'New Factiva')
and cycle_date >>= cast('2023-06-01' as date)
and (ti_td_action like '%download_chrome_plugin' or ti_td_module_tracker like '%Chromext%' or ti_td_page_driver = 'Chromext')  
group by 1,2,3,4,5,6,7,8,9,10,11
