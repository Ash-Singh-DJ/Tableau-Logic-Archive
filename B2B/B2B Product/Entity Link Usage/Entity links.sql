-- Dashboard   : "Entity Link Usage"  [B2B / B2B Product]
-- Data source : "Entity links" = published source "Entity links"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from (
select date_time, cycle_date, user_info_user_ref, visit_id, event_name, mem.billing_account_id, ti_td_module_tracker, ti_td_page_section, ti_td_action, ti_td_entity_links_displayed, ti_td_page_url, 
ti_td_search_record_type , mem.plan_id, comp.company_name,
 LAG(ti_td_entity_links_displayed, 2) OVER (PARTITION by visit_id ORDER BY date_time asc) as lag_entiy_links,
 LAG(ti_td_entity_links_displayed, 1) OVER (PARTITION by visit_id ORDER BY date_time asc) as lag_entiy_links1,
 LEAD(ti_td_page_section, 1) OVER (PARTITION by visit_id ORDER BY date_time asc) as lead_page_section
from pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
where product = 'New Factiva'
and event_name in ('user_action', 'page_view')
--and mem.pib_member_id = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
and cycle_date >>= cast('2025-12-01' as date)

--and mem.billing_account_id not like '9ZFB%'
--and mem.billing_account_id not like '9ZZZ%')
 
and (ti_td_entity_links_displayed is not null or ti_td_module_tracker like '%ENTITY_LINK%' or ti_td_action = 'entity_link_click'))
