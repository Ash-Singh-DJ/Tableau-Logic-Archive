-- Published data source : "B2B Factiva Segments Client Insights - User Seg Micro 6mo"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / zoolander_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH contact_submap AS (
	SELECT 
		DISTINCT duns_number, 
		array_agg(primary_address_address_country_name)[1] AS primary_address_address_country_name, 
		array_agg(primary_address_continental_region_name)[1] AS primary_address_continental_region_name 
	FROM dimension_external_db.dnb_contact_and_location 
	GROUP BY 1 
	UNION ALL -- Catch-all logic for unmapped accounts
 	SELECT 
		'999999999' AS duns_number, 
		'Unavailable' AS primary_address_address_country_name, 
		'Unavailable' AS primary_address_continental_region_name 
) 

SELECT  
	us.*, 
	mem.email, 
	mem.first_name, 
	mem.last_name,
	comp.company_country, 
	bil.country AS billing_acount_country, 
	td.region_code, 
	dnb_cl.primary_address_continental_region_name
FROM zoolander_db.factiva_micro_user_seg_6mo us
LEFT JOIN dimension_external_db.pib_membership_dimension mem
	ON us.user_id = mem.user_id AND us.pib_member_id = mem.pib_member_id
LEFT JOIN dimension_external_db.pib_billing_account_dimension bil 
  	ON mem.billing_account_id = bil.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp 
	ON comp.company_sfdc_id = bil.salesforce_company_two
LEFT JOIN dimension_external_db.pib_territory_dimension td 
	ON comp.company_territory = td.territory_sfdc_id 
LEFT JOIN contact_submap dnb_cl
	ON dnb_cl.duns_number = us.duns_number
WHERE cycle_date = (SELECT max(cycle_date) FROM zoolander_db.factiva_micro_user_seg_6mo)
