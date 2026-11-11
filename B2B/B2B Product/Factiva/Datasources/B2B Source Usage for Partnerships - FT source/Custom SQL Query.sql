-- Published data source : "B2B Source Usage for Partnerships - FT source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(cycle_date as varchar),1,7) year_month, event_name, mem.pib_member_id, mem.user_id, product, mem.billing_account_id,
	       comp.company_name, ti_td_action, 

UPPER(case when product = 'New Factiva' then substring(ti_td_page_content_source_code, strpos(ti_td_page_content_source_code,'[')+2, 
(strpos(ti_td_page_content_source_code,']')-strpos(ti_td_page_content_source_code,'[')-3)) else ti_td_page_content_source_code end) as source_code,
'article_views' as type,

sum(case when ti_td_page_content_type = 'Article' and ti_td_article_id is not null then 1 else 0 end) article_count


--Lag(ti_td_page_content_source, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lag_source
from pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
---where ti_td_page_content_source_code like '%FTFTA%'
WHERE product in ('Factiva', 'New Factiva')
and cycle_date >>= cast('2023-01-01' as date)
and ti_td_page_content_type = 'Article'
and (ti_td_action like '%articles%' or ti_td_action is null)
and ti_td_article_id is not null 
and (UPPER(ti_td_page_content_source_code) like '%FTFTA%' or UPPER(ti_td_page_content_source_code) like '%FTCMA%'
or UPPER(ti_td_page_content_source_code) like '%FDNL%' or UPPER(ti_td_page_content_source_code) like '%HEFIDAG%') 

--and (ti_td_page_content_source = 'Financial Times' or ti_td_page_content_source = 'Financial Times (FT.Com)')
--and user_info_account_id not like '9ZZZ%'
--and user_info_account_id not like '9ZFB%'
--and user_info_account_id <<>> '9DOW003600'
--and user_info_account_id <<>> '9DOW007100'
--and user_info_account_id <<>> '9FAC067700'
group by 1,2,3,4,5,6,7,8,9,10

union ALL


select year_month, event_name, pib_member_id, user_id, product, billing_account_id,
	       company_name, ti_td_action, lag_source_code as source_code, 'downloads' as type, SUM(ti_td_ad_article_count) as article_count 

from (

select cycle_date, substring(cast(cycle_date as varchar),1,7) as year_month, event_name, event_id, mem.pib_member_id, mem.user_id, product, mem.billing_account_id,
	       comp.company_name, ti_td_action, ti_td_page_content_source, ti_td_page_content_source_code, ti_td_ad_article_count,
	       Lag(ti_td_page_content_source, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lag_source_name,
	       Lag(ti_td_page_content_source_code, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lag_source_code,
	       'downloads' as type

--sum(case when ti_td_action = 'download_selected_articles' and ti_td_article_id is not null then 1 else 0 end) article_count

from pib_event_data.pib_product_metrics djm
left join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
where product = 'Factiva'
and cycle_date >>= cast('2023-01-01' as date)
--and user_info_account_id not like '9ZZZ%'
--and user_info_account_id not like '9ZFB%'
--and user_info_account_id <<>> '9DOW003600'
--and user_info_account_id <<>> '9DOW007100'
--and user_info_account_id <<>> '9FAC067700'
order by date_time

)

where ti_td_action = 'download_selected_articles' 
and (lag_source_code like '%FTFTA%' or lag_source_code like '%FTCMA%' or lag_source_code like '%FDNL%' or lag_source_code like '%HEFIDAG%' )
and ti_td_ad_article_count = 1

group by 1,2,3,4,5,6,7,8,9,10
