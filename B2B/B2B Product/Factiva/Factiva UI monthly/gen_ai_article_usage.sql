-- Dashboard   : "Factiva UI monthly"  [B2B / B2B Product / Factiva]
-- Data source : "gen_ai_article_usage" = published source "gen_ai_article_usage"  [B2B / B2B Product / Factiva]
-- Relation    : Custom SQL "Comp lookup"
-- Connection  : Athena (AwsDataCatalog / pib_event_data), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select bam.user_key, bam.billing_account_id, comp.company_name from pib_event_data.user_key_billing_account_mappings bam
left join dimension_external_db.pib_billing_account_dimension bill on bam.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
