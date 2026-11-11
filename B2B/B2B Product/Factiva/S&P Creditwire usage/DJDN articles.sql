-- Dashboard   : "S&P Creditwire usage"  [B2B / B2B Product / Factiva]
-- Data source : "DJDN articles" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select cycle_date, substring(cast(cycle_date as varchar),1,7) as year_month, product, ti_td_page_content_source_code, ti_td_article_headline, ti_td_article_id,
ti_td_page_driver, ti_td_action, ti_td_page_url, ti_td_page_section, ti_td_page_subsection, ti_td_page_content_type,
user_info_user_ref,
mem.user_id, bill.cibs_billing_account_id, comp.company_name, mem.plan_id 
from pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
where product in ('Factiva', 'New Factiva')
and ti_td_article_id is not null
and cycle_date >>= cast('2025-05-01' as date)
and lower(ti_td_article_headline) like '%s&pgr%'
and upper(ti_td_page_content_source_code) like '%DJDN%'
and event_name in ('user_action' , 'page_view')
