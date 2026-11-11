-- Published data source : "User Level data by Account"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query1"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(djm.cycle_date as varchar),1,7) year_month, mem.billing_account_id,
               
count(ti_td_ad_content_format) instances,
sum(case when coalesce(ti_td_ad_article_count ,1)  <<= 100 then coalesce(ti_td_ad_article_count ,1) else 0 end) article_count
from pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem ON djm.user_info_user_ref = mem.pib_member_id

where product = 'Factiva'
and (ti_td_action like '%download%' or ti_td_action like '%print%')
and cycle_date >>= cast('2025-04-01' as date)
  and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
and ti_td_ad_content_format <<>> 'SearchSummaryOnly'
group by 1,2
