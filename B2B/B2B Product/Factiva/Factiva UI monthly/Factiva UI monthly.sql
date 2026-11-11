-- Dashboard   : "Factiva UI monthly"  [B2B / B2B Product / Factiva]
-- Data source : "Factiva UI monthly" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(cycle_date as varchar),1,7) as year_month, bad.cibs_billing_account_id, bad.salesforce_access_description, 
comp.company_name, comp.company_sfdc_id, mem.plan_id, pr.product_line,

count(distinct case when event_name in ('page_view', 'user_action') then  mem.pib_member_id end) as user_count,

count(distinct case when event_name in ('page_view', 'user_action') then  visit_id end) as visit_count,

sum(case when event_name = 'page_view' and ti_td_article_id is not null then 1 else 0 end) as article_views,

sum(case when product = 'Factiva' and ti_td_action like '%download%' and ti_td_ad_content_format <<>> 'SearchSummaryOnly'
and coalesce(ti_td_ad_article_count ,1)  <<= 100 then coalesce(ti_td_ad_article_count ,1) else 0 end) as article_downloads
            
        
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join reference_external_db.pib_product_dimension pr on mem.plan_id = pr.access_code 

WHERE product in ('Factiva', 'New Factiva')
and event_name in ('page_view', 'user_action')
and mem.plan_id <<>> '0086'
and mem.plan_id <<>> '0087'
and mem.billing_account_id not like '9ZZZ%'
and mem.billing_account_id not like '9ZFB%'
and mem.billing_account_id <<>> '9DOW003600'
and mem.billing_account_id <<>> '9DOW007100'
and mem.billing_account_id <<>> '9FAC067700'

and cycle_date >>= cast('2024-01-01' as date)
group by 1,2,3,4,5,6,7
