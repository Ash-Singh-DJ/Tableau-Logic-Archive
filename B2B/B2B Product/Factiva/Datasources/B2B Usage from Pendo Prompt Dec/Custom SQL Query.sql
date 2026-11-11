-- Published data source : "B2B Usage from Pendo Prompt Dec"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from (

with draft as 
(select raw.* , (case when product = 'New Factiva' and ti_td_page_subsection = 'Search Results' and ti_td_page_content_type = 'ResearchTools'  and lag1 = 'Simple Search Results_Factiva' and event_name = 'page_view' then 'pendo_prompt_session' end) as pendo  
from (
select cycle_date, date_time, event_id, mem.user_id, mem.pib_member_id, mem.billing_account_id, comp.company_name, plan_id,  mem.first_name, mem.last_name, visit_id, user_info_session_id , product, ti_td_page_referring_url, time_based_visit_id, ti_bd_viewport_bh, ti_bd_viewport_bw,  event_name, ti_td_page_driver, ti_td_action, ti_td_page_url, ti_td_page_section, ti_td_page_subsection, ti_td_page_content_type,
ti_td_article_id, ti_td_article_headline, concat(ti_td_page_content_type,'_',product) content_product,  lag(concat(ti_td_page_subsection,'_',product),1) IGNORE NULLS OVER (PARTITION by time_based_visit_id ORDER BY date_time) lag1
from pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
--where mem.pib_member_id = 'E6OO2HVCQHVPEZMBOMLACMADN4'
where  Product in ('Factiva', 'New Factiva')
and event_name in ('page_view', 'user_action') 
and date_time >> cast('2025-03-24' as date) 
and mem.plan_id <<>> '0086'
and mem.plan_id <<>> '0087'

--and date_time << cast('2024-12-03' as date) 
order by date_time) as raw)

select date_time, cycle_date, event_id, pib_member_id, user_id, first_name, last_name,  billing_account_id, company_name,  product, user_info_session_id, event_name, ti_td_action, ti_td_page_url, ti_td_page_section, ti_td_page_subsection, ti_td_page_content_type, ti_td_article_id, pendo, 
coalesce (pendo, lag(pendo,1) IGNORE NULLS OVER (PARTITION by user_info_session_id, product ORDER BY date_time)) test1
from draft)

where test1 is not null
