-- Published data source : "B2B Classic vs New Factiva Search Dashboard - All Factiva Content Lang"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT 
substring(cast(cycle_date as varchar),1,7) as year_month,
product,
bill.cibs_billing_account_id,
plan_id,
comp.company_name,
comp.company_sfdc_id,
comp.company_industry,
lower(ti_td_content_source_language) lang,

sum(CASE WHEN djm.event_name = 'page_view' THEN 1 ELSE 0 END) page_views,

sum(CASE WHEN djm.event_name = 'page_view' AND ti_td_article_id is not null

THEN 1 ELSE 0 END) article_views

from pib_event_data.pib_product_metrics djm
 inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
 left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id
 left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
 
 where product in ('Factiva', 'New Factiva')
 and event_name = 'page_view'
 --and ti_td_article_id is not null
 
AND cycle_date >>= cast('2023-03-09' as date)
--AND cycle_date <<= cast('2023-08-31' as date)

        
and mem.billing_account_id not like '9ZZZ%'
and mem.billing_account_id not like '9ZFB%'

and mem.billing_account_id <<>> '9DOW003600'
and mem.billing_account_id <<>> '9DOW007100'
and mem.billing_account_id <<>> '9FAC067700'
GROUP BY 1,2,3,4,5,6,7,8
