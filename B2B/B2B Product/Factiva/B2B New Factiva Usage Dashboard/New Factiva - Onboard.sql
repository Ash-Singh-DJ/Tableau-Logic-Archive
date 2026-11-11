-- Dashboard   : "B2B New Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "New Factiva" (embedded in the workbook)
-- Relation    : Custom SQL "Onboard"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select date_time, user_info_user_ref as EID, user_info_account_id, ti_td_action as t_action, ti_td_ad_digest_email_enabled, 
(case when ti_td_ad_digest_email_enabled = true then 'enabled' 
else 'disabled' end) as onbo_digest_state, ti_td_ad_email_frequency as onbo_digest_freq 
from pib_event_data.pib_product_metrics
where ti_td_action = 'complete_onboarding'
--and ti_td_ad_digest_email_enabled is not NULL
and date_time >>= cast('2022-10-03' as date)
order by date_time
