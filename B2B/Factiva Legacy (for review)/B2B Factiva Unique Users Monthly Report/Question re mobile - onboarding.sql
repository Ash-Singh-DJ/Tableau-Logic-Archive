-- Dashboard   : "B2B Factiva Unique Users Monthly Report"  [B2B / Factiva Legacy (for review)]
-- Data source : "Question re mobile" (embedded in the workbook)
-- Relation    : Custom SQL "onboarding"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select cycle_date, user_info_user_ref, ti_td_action
from pib_event_data.pib_product_metrics djm
where product = 'New Factiva'
and event_name = 'user_action'
and ti_td_action = 'complete_onboarding'
