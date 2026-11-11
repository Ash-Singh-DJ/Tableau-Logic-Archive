-- Dashboard   : "Lazard Freres Factiva Usage"  [B2B / B2B Sales / Product Usage]
-- Data source : "FT data" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(cycle_date as varchar),1,7) as year_month, mem.pib_member_id, mem.user_id, mem.first_name, mem.last_name, mem.email, mem.billing_account_id,
ti_td_page_content_source_code, ti_td_article_id, ti_td_article_headline,


count(case when event_name = 'page_view' and ti_td_article_id is not null then ti_td_article_id end) article_views

from pib_event_data.pib_product_metrics djm 
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two

where event_name in ('page_view','user_action')
and product in ('Factiva', 'New Factiva')
and comp.company_name = 'LAZARD FRERES SAS'
and cycle_date >>= cast('2025-01-01' as date)
and ti_td_article_id is not null
and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
and (lower(ti_td_page_content_source_code) like '%ftft%'
or lower(ti_td_page_content_source_code) like '%ftcom%')
group by 1,2,3,4,5,6,7,8,9,10
