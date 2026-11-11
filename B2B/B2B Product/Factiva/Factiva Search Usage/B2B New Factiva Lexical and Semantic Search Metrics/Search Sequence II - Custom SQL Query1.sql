-- Dashboard   : "B2B New Factiva Lexical and Semantic Search Metrics"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Search Sequence II" = published source "Search Sequence II"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Relation    : Custom SQL "Custom SQL Query1"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with lena as (
select date_time, user_info_user_ref, ti_td_action, ti_td_ad_content_language  
from  pib_event_data.pib_product_metrics
where ti_td_action in ('complete_onboarding', 'save_content_language' )
and cycle_date >> cast('2021-01-01' as date)
order by user_info_user_ref, date_time)


select date_time, user_info_user_ref, ti_td_action, ti_td_ad_content_language from lena
where date_time = (select max(date_time) from lena lenb where (lena.user_info_user_ref = lenb.user_info_user_ref) )
