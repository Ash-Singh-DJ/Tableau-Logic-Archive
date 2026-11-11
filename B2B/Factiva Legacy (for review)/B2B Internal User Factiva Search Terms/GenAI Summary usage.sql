-- Dashboard   : "B2B Internal User Factiva Search Terms"  [B2B / Factiva Legacy (for review)]
-- Data source : "GenAI Summary usage" = published source "B2B Internal Usage Factiva Search Terms - GenAI Summary usage"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select date_time, cycle_date, mem.user_id, mem.pib_member_id, comp.company_name, bad.cibs_billing_account_id, event_name, ti_td_action, ti_td_semantic_search_summary_available, ti_td_page_url, lag(ti_td_page_url, 1) over (partition by visit_id order by date_time) as url_lag, 
visit_id, ti_td_page_section, ti_td_page_content_type, ti_td_module_tracker 
              
        
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two

WHERE product = 'New Factiva' 
 and ((event_name = 'page_view'
 and ti_td_page_content_type_detail = 'search results'
 and ti_td_search_record_type = 'free text'
 and ti_td_module_tracker like '%previous_page_location%'
 and (ti_td_semantic_search_summary_available = true or ti_td_semantic_search_summary_available = false ))
 or 
(event_name = 'user_action'
 and ti_td_action = 'expand_summary')
 or 
 ((event_name = 'page_view' or ti_td_action like 'article_%') and ti_td_module_tracker like '%searchSummary%')
 )
 

and cycle_date >>= cast('2024-07-01' as date)
