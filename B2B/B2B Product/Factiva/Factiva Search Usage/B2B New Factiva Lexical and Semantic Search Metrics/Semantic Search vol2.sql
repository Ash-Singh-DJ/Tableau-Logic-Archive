-- Dashboard   : "B2B New Factiva Lexical and Semantic Search Metrics"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Semantic Search vol2" = published source "Semantic Search vol2"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select date_time, mem.pib_member_id, mem.user_id, bill.cibs_billing_account_id, comp.company_name, event_name, ti_td_action, ti_td_page_url, ti_td_search_type, ti_td_semantic_search_result_type     
from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
where product = 'New Factiva'
and cycle_date >>= cast('2024-06-27' as date)
and
(
(ti_td_page_section = 'keyword' 
and ti_td_page_content_type_detail = 'search results'
and ti_td_search_record_type = 'free text'
and ti_td_module_tracker like '%previous_page_location%'
and event_name = 'page_view')
or (ti_td_action like '%_ai_search' or ti_td_action like '%override%' ))
--and mem.pib_member_id = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
order by pib_member_id, date_time
