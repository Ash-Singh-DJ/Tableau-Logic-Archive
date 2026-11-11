-- Dashboard   : "B2B New Factiva Lexical and Semantic Search Metrics"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Search Sequence II" = published source "Search Sequence II"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Relation    : Custom SQL "Usage"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select user_info_user_ref as EID, count(distinct case when product = 'Factiva' AND cycle_date >>= date_add('day', -180, current_date)
AND cycle_date <<= date_add('day', -1, current_date) then visit_id end) as cf_visits,
count(distinct case when product = 'New Factiva' AND cycle_date >>= date_add('day', -180, current_date)
AND cycle_date <<= date_add('day', -1, current_date) then visit_id end) as nf_visits,
min(cycle_date) as first_login,
max(case when ti_td_action = 'complete_onboarding' then cycle_date end) onbo_date


FROM pib_event_data.pib_product_metrics
where product in ('Factiva', 'New Factiva')
and event_name in ('page_view', 'user_action')
--and user_info_user_ref = 'E6OO2HVCQHVPEKOJVPIZBZ36TU'
group by 1
