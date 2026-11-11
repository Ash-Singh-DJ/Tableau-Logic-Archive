-- Dashboard   : "Membership Table Lookup"  [B2B / B2B Product / Factiva]
-- Data source : "Custom SQL Query (dimension_external_db)" = published source "Custom SQL Query (dimension_external_db)"  [B2B / B2B Testing]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select mem.user_id, mem.pib_member_id,  mem.email, bill.cibs_billing_account_id, comp.company_name from dimension_external_db.pib_membership_dimension mem
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two  = comp.company_sfdc_id 
where mem.user_status = 'A'
