-- Dashboard   : "B2B Proquest IP Address Report"  [B2B / B2B Content Licensing- PAL]
-- Data source : "Proquest" = published source "B2B Proquest IP Address - Datasource"  [B2B / B2B Product / Newswires / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select cycle_date, user_info_account_id, comp.company_name, ter.territory_name,   user_info_user_ref, mem.user_id, mem.plan_id, visit_id, ti_bd_client_ip_address,
user_info_session_id,
min(date_time) start_time, max(date_time) end_time,
sum(case when event_name = 'page_view' then 1 else 0 END) page_views,
sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_page_section <<>> 'Search'
and ti_td_page_section <<>> 'Companies and Markets' then 1 else 0 end) article_views,
sum(case when event_name = 'user_action' and (ti_td_action = 'download_selected_articles' or ti_td_action = 'save_selected_articles') 
and ti_td_ad_article_count >> 0 and ti_td_ad_article_count <<= 100 then ti_td_ad_article_count else 0 end) Article_downloads,
sum(case when event_name = 'user_action' and ti_td_action = 'view_selected_articles'
and ti_td_ad_article_count >> 0 and ti_td_ad_article_count <<= 100 then ti_td_ad_article_count else 0 end) View_Selected_articles,
sum(case when event_name = 'page_view' and ti_td_page_section = 'Companies and Markets' then 1 else 0 end) ce_page_views,
sum(case when event_name = 'page_view' and ti_td_page_sub_subsection = 'Get Quotes' then 1 else 0 end) get_quote_requests,
sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_page_section = 'Companies and Markets' 
and ti_td_page_content_source in ('Refinitiv Analyst Collection', 'MarketLine Company Profiles') then 1 else 0 end) analyst_report_views 

from pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id	
left join dimension_external_db.pib_territory_dimension ter on bill.salesforce_territory = ter.territory_sfdc_id 
where product in ( 'Factiva', 'New Factiva' )
and (territory_name = 'Proquest' or user_info_account_id = '9IND010100')
and (user_info_account_id not like '9ZZZ%'
or user_info_account_id = '9ZZZ030200') 
AND cycle_date >> date_add('day', -380, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
group by 1,2,3,4,5,6,7,8,9,10
having sum(case when event_name = 'page_view' or event_name = 'user_action' then 1 else 0 END) >> 0
