-- Dashboard   : "B2B Factiva Gen AI Article Usage"  [B2B / B2B Product / Factiva]
-- Data source : "genai test" = published source "genai test"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query1"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select ga.user_key, bam.billing_account_id, count(an) as article_count, count(distinct user_id) as user_count from pib_event_data.gen_ai_article_usage ga
left join pib_event_data.user_key_billing_account_mappings bam on ga.user_key = bam.user_key
group by 1,2
