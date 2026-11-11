-- Published data source : "B2B Factiva Academic User Metrics - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, 
mem.pib_member_id, concat(ti_bd_client_ip_address, ti_bd_user_agent) as ip_agent, mem.billing_account_id, mem.plan_id, 


comp.company_name, product, ti_td_page_content_platform_presentation as device, 
sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) desktop_page_views,

sum(case when (product = 'Factiva' and event_name = 'page_view' and ti_td_article_id is not null) or 
(product = 'New Factiva' and ((event_name = 'page_view' and ti_td_article_id is not null) or (event_name = 'user_action' and ti_td_action like 'article_%' and ti_td_article_id is not null )))
then 1 else 0 END) as article_views,

COUNT(distinct case when event_name = 'page_view' or event_name = 'user_action' THEN visit_id END) visit_count

   
      from pib_event_data.pib_product_metrics omni


join dimension_external_db.pib_membership_dimension mem on omni.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 

where product in ('Factiva', 'New Factiva')
and plan_id in ('0086', '0087')
AND cycle_date >> date_add('day', -800, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
GROUP BY 1,2,3,4,5,6,7,8
having sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) >> 0
