-- Published data source : "B2B Platform Trace API Metrics - Data Source"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query1"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT bad.cibs_billing_account_id,
	   bad.salesforce_status AS billing_account_sf_status,
	   comp.company_sfdc_id, 
           comp.company_name,
	   comp.company_country, 
	   comp.company_industry,
	   td.territory_name,
	   grr.geo_region, 
	   usr.user_full_name territory_owner,
	   rsd_usr.user_full_name rsd
FROM dimension_external_db.pib_billing_account_dimension bad
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id
LEFT JOIN sandbox_mk.geo_region_rollup grr ON td.territory_name = grr.sales_territory 
LEFT JOIN dimension_external_db.pib_user_dimension usr ON td.territory_owner = usr.user_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension rsd_usr ON td.regional_sales_director = rsd_usr.user_sfdc_id
