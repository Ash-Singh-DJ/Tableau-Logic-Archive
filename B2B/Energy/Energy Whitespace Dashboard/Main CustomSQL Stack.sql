-- Dashboard   : "Energy Whitespace Dashboard"  [B2B / Energy]
-- Data source : "Main CustomSQL Stack" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dnb_firmographic_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
/*
New Custom SQL Query that will be the input to the Energy Whitespace Dashboard on Tableau.
*/


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

opis_sales AS (
	SELECT 
		DISTINCT sales_rep, 
		lt5, lt4, lt3 
	FROM sandbox_hvc.opis_sales_hierarchy 
	WHERE fiscal_year = (SELECT max(fiscal_year) FROM sandbox_hvc.opis_sales_hierarchy)
), 

-- NEW CTE TO PRIORITIZE NON-BLANK VALUES
prioritized_psd AS (
  SELECT 
      product_service,
      product_family,
      product_line,
      -- Assign a rank to each product_service's rows.
      -- The row with a non-empty product_family gets rank 1.
      ROW_NUMBER() OVER(PARTITION BY product_service ORDER BY product_family DESC) as rn
  FROM dimension_external_db.pib_product_services_dimension
  WHERE product_line = 'Base Chemicals' AND product_service IS NOT NULL
),

-- PROD OVERRIDE ADJUSTED
prod_override AS (
    SELECT 
        product_service, 
        mapping
    FROM sandbox_spb.cmm_prod_override 

    UNION ALL 

    SELECT 
        product_service, 
        mapping
    FROM sandbox_spb.opis_prod_override 

    UNION ALL

    SELECT 
        psd.product_service, 
        COALESCE(cma.mapping, 
                 CASE WHEN psd.product_family IN ('Paid Presentation', 'Training') THEN 'Other CMA' 
                      -- Handle the case where the prioritized row might still have a blank family
                      WHEN psd.product_family = '' THEN 'Other CMA'
                      ELSE psd.product_family 
                 END, 
                 'Other CMA') AS mapping 
    FROM prioritized_psd psd -- Using the CTE from above
    LEFT JOIN sandbox_spb.cma_prod_override cma ON cma.product_service = psd.product_service
    WHERE psd.rn = 1
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
	    prof.company_crm_name, 
		prof.company_level_id, 
	    prof.territory_name, 
		prof.account_owner, 
		COALESCE(prof.lt5, lt345.lt5, 'Hierarchy Not Found') lt5, 
		COALESCE(prof.lt4, lt345.lt4, 'Hierarchy Not Found') lt4, 
		COALESCE(prof.lt3, lt345.lt3, 'Hierarchy Not Found') lt3, 
		prof.b2b_acct_id, 
		prof.brand, 
		CASE WHEN prof.brand = 'OPIS Core' THEN COALESCE(ovr.mapping, 'Other OPIS')
			WHEN prof.brand = 'Chemical Market Analytics' THEN COALESCE(ovr.mapping, 'Other CMA')
			WHEN prof.brand = 'Coal, Metals & Mining' THEN COALESCE(ovr.mapping, 'Other CMM')
			ELSE 'Other' END product_group, 
		prof.product, 
		COALESCE(prof.annualized_revenue, 0) AS revenue, 
		0 AS snapshot_revenue, 
		-1 AS xsell_value, -- CHANGED VALUE TO AN INVALID NUMBER SINCE IT IS NOT USED FOR THIS VERSION
		CAST(NULL AS boolean) AS is_expansion, 
		CAST(NULL AS boolean) AS is_best_option, 
		COALESCE(firm.global_ultimate_duns, prof.duns_number) AS global_ultimate_duns, 
		COALESCE(trim(firm.global_ultimate_name), concat('Unknown - ', prof.duns_number)) AS global_ult_name, 
		COALESCE(firm.is_multinational, FALSE) AS multinational, 
		COALESCE(firm.is_large_company, FALSE) AS large_company, 
		firm.sector, 
		firm.prop_group 
	FROM sandbox_spb.opis_revenue prof 
	FULL JOIN primary_submap comp 
		ON comp.duns_number = prof.duns_number 
	LEFT JOIN prod_override ovr 
		ON prof.product = ovr.product_service 
	LEFT JOIN sandbox_hvc.firmographic_summary firm 
		ON comp.duns_number = firm.duns_number 
	LEFT JOIN (SELECT DISTINCT lt5, lt4, lt3 FROM opis_sales) lt345 ON prof.account_owner = lt345.lt5 -- in cases where owner is an LT5
	ORDER BY brand, revenue DESC 
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
		COALESCE(usr.user_full_name, 'Account Owner Not Found') account_owner, 
		--usr2.user_full_name regional_sales_director, 
		COALESCE(hier.lt5, lt345.lt5, 'Hierarchy Not Found') lt5, 
		COALESCE(hier.lt4, lt345.lt4, 'Hierarchy Not Found') lt4, 
		COALESCE(hier.lt3, lt345.lt3, 'Hierarchy Not Found') lt3, 
		b2b_acct_id, 
		snp.brand, 
		CASE WHEN snp.brand = 'OPIS Core' THEN COALESCE(ovr.mapping, 'Other OPIS')
			WHEN snp.brand = 'Chemical Market Analytics' THEN COALESCE(ovr.mapping, 'Other CMA')
			WHEN snp.brand = 'Coal, Metals & Mining' THEN COALESCE(ovr.mapping, 'Other CMM')
			ELSE 'Other' END product_group, 
		product, 
		revenue AS snapshot_revenue, 
		lpad(global_ultimate_duns, 9, '0') AS global_ultimate_duns, 
		global_ult_name 
	FROM sandbox_hvc.fy24_profiler_data_snapshot snp 
	LEFT JOIN prod_override ovr 
		ON snp.product = ovr.product_service 
	LEFT JOIN dimension_external_db.pib_company_dimension comp 
		ON snp.company_level_id = comp.company_sfdc_id 
	LEFT JOIN dimension_external_db.pib_territory_dimension terr 
		ON comp.company_territory = terr.territory_sfdc_id 
	LEFT JOIN dimension_external_db.pib_user_dimension usr 
		ON terr.territory_owner = usr.user_sfdc_id 
	LEFT JOIN opis_sales hier 
		ON usr.user_full_name = hier.sales_rep 
	LEFT JOIN (SELECT DISTINCT lt5, lt4, lt3 FROM opis_sales) lt345 ON usr.user_full_name = lt345.lt5
	WHERE category = 'OPIS' 
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
		company_crm_name, 
		company_level_id, 
		territory_name, 
		account_owner, 
		--regional_sales_director, -- replaced by LT3/4/5
		lt5, lt4, lt3, 
		b2b_acct_id, 
		brand, 
		product_group, 
		product, 
		0 AS revenue, 
		snapshot_revenue, 
		-1 AS xsell_value, -- -- CHANGED VALUE TO AN INVALID NUMBER SINCE IT IS NOT USED FOR THIS VERSION
		CAST(NULL AS boolean) AS is_expansion, 
		CAST(NULL AS boolean) AS is_best_option, 
		snap.global_ultimate_duns, 
		snap.global_ult_name, 
		COALESCE(firm.is_multinational, FALSE) AS multinational, 
		COALESCE(firm.is_large_company, FALSE) AS large_company, 
		firm.sector, 
		firm.prop_group 
	FROM snapshot snap 
	LEFT JOIN sandbox_hvc.firmographic_summary firm 
		ON snap.duns_number = firm.duns_number 
), 


total_subq AS (
	SELECT * FROM revenue_data 
	UNION ALL 
	SELECT * FROM snapshot_data 
) 


SELECT 
	ts.*,
	--COALESCE(im.iabm, 'Other') AS industry 
	CASE WHEN prop_group = 'Other' THEN concat(prop_group, ' ', sector) ELSE prop_group END industry 
FROM total_subq ts 
--LEFT JOIN sandbox_mk.industry_config im -- DEPRECATE THIS
--	ON ts.naics_industry_highlevel = im.naics
WHERE brand IS NOT NULL
