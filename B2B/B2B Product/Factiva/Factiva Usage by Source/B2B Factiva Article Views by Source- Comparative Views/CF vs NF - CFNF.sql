-- Dashboard   : "B2B Factiva Article Views by Source: Comparative Views"  [B2B / B2B Product / Factiva / Factiva Usage by Source]
-- Data source : "CF vs NF" = published source "B2B Factiva Article Views by Source: Comparative Views - CF vs NF"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "CFNF"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, mem.billing_account_id, 
(case when (mem.plan_id = '0086' or mem.plan_id = '0087') then 'aca' end) as aca, ti_td_module_tracker,
(case when ti_td_module_tracker like '%searchSummary%' then 'SmartSummary' end) smartsum,


product, UPPER(ti_td_page_content_source_code) as SourceCode,  count(*) as article_views

from pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two  = comp.company_sfdc_id 

where cycle_date >>= cast('2024-01-01' as date)


and product in ('Factiva','New Factiva')
and event_name in ('user_action', 'page_view')
and ti_td_article_id is not null
--and ti_td_module_tracker like '%searchSummary%'

--and mem.billing_account_id  not like '9ZFB%'
--and mem.billing_account_id  not like '9ZZZ%'
--and mem.billing_account_id  <<>> '9DOW003600'
--and mem.billing_account_id  <<>> '9DOW007100'
--and mem.billing_account_id  <<>> '9FAC067700'
group by 1,2,3,4,5,6,7
