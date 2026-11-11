-- Dashboard   : "B2B True North Metrics"  [B2B / B2B Product]
-- Data source : "Reg Users" = published source "B2B True North - Reg Users"  [B2B / B2B Product / Data sources / True North Metrics Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select count(pib_member_id) as reg_user_count from dimension_external_db.pib_membership_dimension

WHERE user_status = 'A'
and lower(billing_account_id) not like '9zzz%'
          and lower(billing_account_id) not like '9fac%'
          and lower(billing_account_id) not like '9zfb%'
          and lower(billing_account_id) like '9%'
