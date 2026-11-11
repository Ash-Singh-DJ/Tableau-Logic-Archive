-- Dashboard   : "DJ B2B Xsell Dashboard (Deprecated)"  [B2B / B2B Sales / Cross-sell & Upsell]
-- Data source : "Main CustomSQL Stack" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dnb_firmographic_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH primary_submap AS ( -- anti-duplication submapping
 	SELECT 
 		DISTINCT duns_number, 
 		primary_name 
 	FROM dnb_firmographic_db.company_information_current 
 	UNION ALL -- Catch-all logic for unmapped accounts
 	SELECT 
		'999999999' AS duns_number, 
		'Unmapped Accounts' AS primary_name 
), 


revenue_data AS ( 
	SELECT 
		COALESCE(trim(comp.primary_name), concat('Info Unavailable - ', prof.duns_number)) AS primary_name, 
		COALESCE(prof.duns_number, comp.duns_number) AS duns_number, 
		COALESCE(firm.state, 'Unavailable') AS state, 
		COALESCE(firm.country, 'Unavailable') AS country, 
		COALESCE(firm.region, 'Unavailable') AS region, 
		firm.naics_industry_high AS naics_industry_toplevel, 
		firm.naics_industry_mid AS naics_industry_highlevel, 
		firm.sector, 
		firm.prop_group, 
	    prof.company_crm_name, 
		prof.company_level_id, 
	    prof.territory_name, 
		prof.account_owner, 
		prof.regional_sales_director, 
		prof.b2b_acct_id, 
		prof.brand, 
		prof.product_group, 
		prof.product, 
		COALESCE(prof.annualized_revenue, 0) AS revenue, 
		0 AS snapshot_revenue, 
		CAST(NULL AS int) AS xsell_value, 
		CAST(NULL AS boolean) AS is_expansion, 
		CAST(NULL AS boolean) AS is_best_option, 
		COALESCE(firm.global_ultimate_duns, prof.duns_number) AS global_ultimate_duns, 
		COALESCE(trim(firm.global_ultimate_name), concat('Unknown - ', prof.duns_number)) AS global_ult_name, 
		prof.partnership AS is_partnership, 
		COALESCE(firm.is_multinational, FALSE) AS multinational, 
		COALESCE(firm.is_large_company, FALSE) AS large_company 
	FROM sandbox_mk.b2b_revenue prof 
	FULL JOIN primary_submap comp 
		ON comp.duns_number = prof.duns_number 
	LEFT JOIN sandbox_hvc.firmographic_summary firm 
		ON comp.duns_number = firm.duns_number 
	ORDER BY brand, revenue DESC
), 


xsell AS (
	SELECT 
		targeted_duns, 
		target_sfdc_id, 
		targeted_name, 
		comp.company_name targeted_sf_name, 
		terr.territory_name, 
		usr.user_full_name acct_owner, 
		usr2.user_full_name rsd, 
		CASE WHEN substr(targeted_product, 1, 4) = 'FTVA' THEN 'Factiva' 
			WHEN substr(targeted_product, 1, 4) = 'RNC ' THEN 'Risk & Compliance' 
			WHEN substr(targeted_product, 1, 4) = 'NWRS' THEN 'Newswires' END brand, 
		regexp_extract(targeted_product, '[A-Z]+ - (.+)', 1) targeted_product_name, 
		CASE WHEN existing_product = 'whitespace' THEN TRUE ELSE FALSE END expansion, 
		CASE WHEN is_best_option = 'True' THEN TRUE ELSE FALSE END is_best_option, 
		max(CAST(targeted_product_spend AS double)) targeted_product_spend 
	FROM sandbox_mk.temp_table xsel 
	LEFT JOIN dimension_external_db.pib_company_dimension comp 
		ON xsel.target_sfdc_id = comp.company_sfdc_id 
	LEFT JOIN dimension_external_db.pib_territory_dimension terr 
		ON comp.company_territory = terr.territory_sfdc_id 
	LEFT JOIN dimension_external_db.pib_user_dimension usr 
		ON terr.territory_owner = usr.user_sfdc_id 
	LEFT JOIN dimension_external_db.pib_user_dimension usr2 
		ON terr.regional_sales_director = usr2.user_sfdc_id 
	WHERE /*cycle_date = (SELECT max(cycle_date) AS cycle_date FROM sandbox_hvc.xsell_suggestions)
		AND*/ target_sfdc_id <<>> '' AND target_sfdc_id IS NOT NULL 
	GROUP BY 1,2,3,4,5,6,7,8,9,10,11 
	ORDER BY target_sfdc_id 
), 

xsell_data AS (
	SELECT 
		COALESCE(trim(comp.primary_name), concat('Info Unavailable - ', xsel.targeted_duns)) AS primary_name, 
		COALESCE(xsel.targeted_duns, comp.duns_number) AS duns_number, 
		COALESCE(firm.state, 'Unavailable') AS state, 
		COALESCE(firm.country, 'Unavailable') AS country, 
		COALESCE(firm.region, 'Unavailable') AS region, 
		firm.naics_industry_high AS naics_industry_toplevel, 
		firm.naics_industry_mid AS naics_industry_highlevel, 
		firm.sector, 
		firm.prop_group, 
		xsel.targeted_sf_name AS company_crm_name, 
		xsel.target_sfdc_id AS company_level_id, 
		xsel.territory_name, 
		xsel.acct_owner account_owner, 
		xsel.rsd regional_sales_director, 
		'Cross-Sell Target' AS b2b_acct_id, 
		xsel.brand, 
		xsel.targeted_product_name AS product_group, 
		'Xsell' AS product, 
		CAST(NULL AS int) AS revenue, 
		CAST(NULL AS int) AS snapshot_revenue, 
		xsel.targeted_product_spend AS xsell_value, 
		xsel.expansion AS is_expansion, 
		xsel.is_best_option, 
		COALESCE(firm.global_ultimate_duns, xsel.targeted_duns) AS global_ultimate_duns,  
		COALESCE(trim(BOTH FROM firm.global_ultimate_name), concat('Unknown - ', xsel.targeted_duns)) AS global_ult_name, 
		CASE WHEN upper(xsel.territory_name) LIKE '%BD %' THEN TRUE ELSE FALSE END AS is_partnership, 
		COALESCE(firm.is_multinational, FALSE) AS multinational, 
		COALESCE(firm.is_large_company, FALSE) AS large_company 
	FROM xsell xsel 
	FULL JOIN primary_submap comp 
		ON comp.duns_number = xsel.targeted_duns 
	LEFT JOIN sandbox_hvc.firmographic_summary firm 
		ON comp.duns_number = firm.duns_number 
	ORDER BY brand, xsell_value DESC 
), 


prod_override AS (
	SELECT high_level, mapping, 
		regexp_extract(product, '[A-Z]+ - (.+)', 1) product_name
	FROM sandbox_hvc.ftva_prod_override 
	WHERE product NOT IN ('FTVA - Risk Database Premium', 'FTVA - Risk Agent Fees')
	UNION ALL 
	SELECT high_level, mapping, 
		regexp_extract(product, '[A-Z]+ - (.+)', 1) product_name
	FROM sandbox_hvc.nwrs_prod_override 
	UNION ALL 
	SELECT high_level, mapping, 
		regexp_extract(product, '[A-Z]+ - (.+)', 1) product_name
	FROM sandbox_hvc.rnc_prod_override 
), 

snapshot AS (
	SELECT  
		primary_name, 
		lpad(duns_number, 9, '0') AS duns_number, 
		country, 
		region, 
		naics_industry_toplevel, 
		naics_industry_highlevel, 
		company_crm_name, 
		company_level_id, 
		terr.territory_name, 
		usr.user_full_name account_owner, 
		usr2.user_full_name regional_sales_director, 
		b2b_acct_id, 
		CASE WHEN brand = 'Risk & Compliance Partnership' THEN 'Risk & Compliance' 
			 WHEN brand = 'Newswires Partnership' THEN 'Newswires'
			 WHEN brand = 'Factiva Partnership' THEN 'Factiva' 
			 ELSE brand END brand, 
		CASE WHEN brand IN ('Risk & Compliance','Newswires','Factiva',
			'Risk & Compliance Partnership','Newswires Partnership','Factiva Partnership') 
			 THEN COALESCE(CASE WHEN ovr.mapping LIKE '%remove%' THEN 'Other' ELSE ovr.mapping END, 'Other') 
			 ELSE snp.product_group END product_group, 
		product, 
		revenue AS snapshot_revenue, 
		lpad(global_ultimate_duns, 9, '0') AS global_ultimate_duns, 
		global_ult_name 
	FROM sandbox_hvc.fy24_profiler_data_snapshot snp 
	LEFT JOIN prod_override ovr 
		ON snp.product = ovr.product_name 
	LEFT JOIN dimension_external_db.pib_company_dimension comp 
		ON snp.company_level_id = comp.company_sfdc_id 
	LEFT JOIN dimension_external_db.pib_territory_dimension terr 
		ON comp.company_territory = terr.territory_sfdc_id 
	LEFT JOIN dimension_external_db.pib_user_dimension usr 
		ON terr.territory_owner = usr.user_sfdc_id 
	LEFT JOIN dimension_external_db.pib_user_dimension usr2 
		ON terr.regional_sales_director = usr2.user_sfdc_id 
	WHERE category <<>> 'No Business' AND product <<>> 'Bespoke Partnership'
), 

snapshot_data AS (
	SELECT 
		snap.primary_name, 
		snap.duns_number, 
		NULL AS state, 
		snap.country, 
		snap.region, 
		naics_industry_toplevel, 
		naics_industry_highlevel, 
		firm.sector, 
		firm.prop_group, 
		company_crm_name, 
		company_level_id, 
		territory_name, 
		account_owner, 
		regional_sales_director, 
		b2b_acct_id, 
		brand, 
		product_group, 
		product, 
		0 AS revenue, 
		snapshot_revenue, 
		CAST(NULL AS int) AS xsell_value, 
		CAST(NULL AS boolean) AS is_expansion, 
		CAST(NULL AS boolean) AS is_best_option, 
		snap.global_ultimate_duns, 
		snap.global_ult_name, 
		CASE WHEN upper(territory_name) LIKE '%BD %' THEN TRUE ELSE FALSE END AS is_partnership, 
		COALESCE(firm.is_multinational, FALSE) AS multinational, 
		COALESCE(firm.is_large_company, FALSE) AS large_company 
	FROM snapshot snap 
	LEFT JOIN sandbox_hvc.firmographic_summary firm 
		ON snap.duns_number = firm.duns_number 
	WHERE brand IN ('Risk & Compliance','Newswires','Factiva')
), 


total_subq AS (
	SELECT * FROM revenue_data 
	UNION ALL 
	SELECT * FROM xsell_data 
	UNION ALL 
	SELECT * FROM snapshot_data 
) 


SELECT 
	ts.*,
	CASE WHEN prop_group = 'Other' THEN concat(prop_group, ' ', sector) ELSE prop_group END industry 
FROM total_subq ts
