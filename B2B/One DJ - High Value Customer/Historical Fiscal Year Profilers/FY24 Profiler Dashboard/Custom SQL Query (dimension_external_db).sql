-- Dashboard   : "FY24 Profiler Dashboard"  [B2B / One DJ - High Value Customer / Historical Fiscal Year Profilers]
-- Data source : "Custom SQL Query (dimension_external_db)" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
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

linkage_submap AS ( 
	SELECT 
		lnk.duns_number,
		lnk.parent_duns, 
		lnk.head_quarter_duns, 
		lnk.global_ultimate_duns,
		coalesce(lnk.global_ult_name, ps.primary_name) as global_ult_name, 
		lnk.is_standalone,
		ps.primary_name
	FROM (
		SELECT 
			DISTINCT duns_number, 
			parent_duns, 
			head_quarter_duns, 
			COALESCE(global_ultimate_duns, duns_number) AS global_ultimate_duns, 
                        global_ultimate_primary_name global_ult_name,
			is_standalone 
		FROM dnb_firmographic_db.corporate_linkage_current 
	 	UNION ALL 
	 	SELECT 
			'999999999' AS duns_number, 
			NULL AS parent_duns, 
			NULL AS head_quarter_duns, 
			'999999999' AS global_ultimate_duns, 
                        NULL as global_ult_name,
			TRUE AS is_standalone 
	) lnk 
	JOIN primary_submap ps 
		ON lnk.duns_number = ps.duns_number 
), 

contact_submap AS (
	SELECT 
		DISTINCT duns_number, 
		primary_address_address_region_name, 
		primary_address_address_country_name, 
		primary_address_continental_region_name
	FROM dnb_firmographic_db.contact_and_location_current 
	UNION ALL -- Catch-all logic for unmapped accounts
 	SELECT 
		'999999999' AS duns_number, 
		'Unavailable' AS primary_address_address_region_name, 
		'Unavailable' AS primary_address_address_country_name, 
		'Unavailable' AS primary_address_continental_region_name 
), 

industry_detail AS (
	SELECT 
		DISTINCT duns_number, 
		is_fortune1000_listed AS is_fortune1000, 
		is_small_business, 
		primary_industry_code_us_sicv4_description AS sic4_desc, 
		array_sort(FILTER(array_agg(DISTINCT CASE WHEN industry_codes_type_description = 'D&B Standard Industry Code'
					AND substr(industry_codes_code, 1, 4) = primary_industry_code_us_sicv4 
					THEN industry_codes_code END), x ->> x IS NOT NULL)) AS sic8, -- array_sort ensures same order every run
		array_sort(FILTER(array_agg(DISTINCT CASE WHEN industry_codes_type_description = 'North American Industry Classification System 2022' 
					THEN industry_codes_code END), x ->> x IS NOT NULL)) AS naics6 
	FROM dnb_firmographic_db.industry_and_activity_current 
	WHERE LENGTH(industry_codes_code) >>= 6 
	GROUP BY 1,2,3,4
	UNION ALL 
	SELECT 
		'999999999' AS duns_number, 
		FALSE AS is_fortune1000, 
		FALSE AS is_small_business, 
		'Unavailable' AS sic4_desc, 
		NULL AS sic8, 
		NULL AS naics6 
), 

industry_submap AS (
	SELECT 
		ind.*, 
		sm.sic2_long AS primary_industry_highlevel, -- legacy naming scheme for dashboard
		sm.sic2_short AS primary_industry_toplevel, -- legacy naming scheme for dashboard
		sm.sic8_desc AS primary_sic_max_detail, 
		nm.naics6_desc AS naics_industry_detail, 
		nm.naics3_desc AS naics_industry_highlevel, 
		nm.naics2_desc AS naics_industry_toplevel, 
		nm2.naics6_desc AS naics_secondary_industry_detail 
	FROM (
		SELECT 
			DISTINCT duns_number, 
			is_fortune1000, 
			is_small_business, 
			CASE WHEN CARDINALITY(sic8) >> 0 THEN sic8[1] END AS primary_industry_sic, 
			CASE WHEN CARDINALITY(naics6) >> 0 THEN naics6[1] END AS primary_industry_naics, 
			CASE WHEN CARDINALITY(naics6) >> 1 THEN naics6[2] END AS secondary_industry_naics, 
			sic4_desc AS primary_industry_detail 
		FROM industry_detail 
		) ind 
	LEFT JOIN reference_external_db.industry_codes_sic sm 
		ON ind.primary_industry_sic = sm.sic8 
	LEFT JOIN reference_external_db.industry_codes_naics nm 
		ON ind.primary_industry_naics = nm.naics6 
	LEFT JOIN (
		SELECT naics6, naics6_desc  
		FROM reference_external_db.industry_codes_naics 
	) nm2 
		ON ind.secondary_industry_naics = nm2.naics6 
), 

hvc_override AS (
	SELECT 
		DISTINCT link.global_ult_name, 
		COALESCE(guo.parent_override, link.global_ult_name) AS parent_override 
	FROM linkage_submap link
	LEFT JOIN google_sheets_db.dnb_hvcs_global_ultimate_override guo 
		ON link.global_ult_name = guo.global_ultimate_name 
), 

revenue_data AS (
	SELECT 
		COALESCE(trim(comp.primary_name), concat('Info Unavailable - ', prof.duns_number)) AS primary_name, 
		COALESCE(prof.duns_number, comp.duns_number) AS duns_number, 
		COALESCE(prof.category, 'No Business') AS category, 
	    prof.crm, 
	    prof.company_crm_name, 
		prof.company_level_id, 
	    prof.territory_name, 
		prof.account_owner, 
		prof.b2b_acct_id, 
		NULL AS opp_crm_id, -- this is for opps
		prof.brand, 
		prof.product_group, 
		prof.product, 
	    COALESCE(prof.recurring_revenue, 0) AS recurring_revenue, 
	    COALESCE(prof.non_recurring_revenue, 0) AS non_recurring_revenue, 
		COALESCE(prof.annualized_revenue, 0) AS revenue, 
		CAST(NULL AS int) AS annualized_opp_value, -- open opp value
		CAST(NULL AS int) AS xsell_value, 
		CAST(NULL AS boolean) AS is_expansion, 
		COALESCE(loc.primary_address_address_region_name, 'Unavailable') AS state, 
		COALESCE(loc.primary_address_address_country_name, 'Unavailable') AS country, 
		COALESCE(loc.primary_address_continental_region_name, 'Unavailable') AS region, 
		COALESCE(link.parent_duns, link.head_quarter_duns) AS parent_or_hq_duns, 
		COALESCE(link.global_ultimate_duns, prof.duns_number) AS global_ultimate_duns, -- In the standalone cases just use their own DUNS as their Global Ultimate 
		COALESCE(trim(link.global_ult_name), concat('Unknown - ', prof.duns_number)) AS global_ult_name, 
		COALESCE(link.is_standalone, TRUE) AS is_standalone, 
		COALESCE(inds.is_fortune1000, FALSE) AS is_fortune1000, 
		COALESCE(inds.is_small_business, FALSE) AS is_small_business, 
		inds.primary_industry_toplevel, 
		inds.primary_industry_highlevel, 
		inds.primary_industry_detail, 
		inds.primary_sic_max_detail, 
		inds.naics_industry_toplevel, 
		inds.naics_industry_highlevel, 
		inds.naics_industry_detail, 
		inds.naics_secondary_industry_detail, 
		parent_override, 
		CASE WHEN parent_override IN 
		(SELECT * FROM sandbox_hvc.high_value_clients) THEN TRUE 
		 ELSE FALSE END AS is_hvc, 
		COALESCE(hc.sector, is4.sector, is3.sector, is2.sector, is1.sector) sector, 
		COALESCE(hc.prop_group, is4.prop_group, is3.prop_group, is2.prop_group, is1.prop_group) prop_group 
	FROM sandbox_hvc.duns_profiler_tranche13 prof 
	FULL JOIN primary_submap comp 
		ON comp.duns_number = prof.duns_number 
	LEFT JOIN linkage_submap link 
		ON comp.duns_number = link.duns_number 
	LEFT JOIN contact_submap loc 
		ON comp.duns_number = loc.duns_number 
	LEFT JOIN industry_submap inds 
		ON comp.duns_number = inds.duns_number 
	LEFT JOIN hvc_override hvc 
		ON hvc.global_ult_name = link.global_ult_name 
	LEFT JOIN sandbox_hvc.industry_sectors is4 ON (substring(inds.primary_industry_naics, 1, 4) = is4.naics_code)
	LEFT JOIN sandbox_hvc.industry_sectors is3 ON (substring(inds.primary_industry_naics, 1, 3) = is3.naics_code)
	LEFT JOIN sandbox_hvc.industry_sectors is2 ON (substring(inds.primary_industry_naics, 1, 2) = is2.naics_code)
	LEFT JOIN sandbox_hvc.industry_sectors is1 ON (substring(inds.primary_industry_naics, 1, 1) = is1.naics_code)
	LEFT JOIN sandbox_hvc.holding_companies hc ON (hc.duns = prof.duns_number)
	ORDER BY category, revenue DESC
), 


opportunities AS (
	SELECT *, 'B2B' AS pillar FROM sandbox_mk.opps_b2b 
	UNION ALL 
	SELECT *, 'OPIS' AS pillar FROM sandbox_mk.opps_cma 
	UNION ALL 
	SELECT *, 'Advertising' AS pillar FROM sandbox_mk.opps_adv 
), 

opps_data AS (
	SELECT 
		COALESCE(trim(comp.primary_name), concat('Info Unavailable - ', opps.duns_n)) AS primary_name, 
		COALESCE(opps.duns_n, comp.duns_number) AS duns_number, 
		COALESCE(opps.pillar, 'No Business') AS category, 
		opps.crm, 
		opps.company_crm_name, 
		opps.company_sfdc_id AS company_level_id, 
		opps.territory_name, 
		opps.account_owner, 
		opps.b2b_acct_id, 
		opps.opp_crm_id, 
		opps.product_line AS brand, 
		CASE 
			WHEN product_service LIKE '%GenAI%' THEN 'Generative AI' 
			WHEN opr.mapping IS NOT NULL THEN opr.mapping 
			WHEN lower(product_service) LIKE '%managed service%' THEN 'Managed Services' 
			WHEN lower(product_service) LIKE '%mngd srvc%' THEN 'Managed Services' 
			WHEN lower(product_service) LIKE '%professional service%' THEN 'Professional Services' 
			WHEN lower(product_service) LIKE '%prof service%' THEN 'Professional Services' 
			WHEN lower(product_service) LIKE '%prof svc%' THEN 'Professional Services' 
			WHEN product_service LIKE '%ASAM%' THEN 'ASAM' 
			WHEN product_service LIKE '%AAMS%' THEN 'ASAM' 
			WHEN product_service LIKE '%atchlist-API%' THEN 'Watchlist API' 
			WHEN product_service LIKE '%SAM API%' THEN 'Screening & Monitoring API' 
			WHEN lower(product_service) LIKE '%third party%' THEN 'RiskCenter Third Party' 
			WHEN lower(product_service) LIKE '%sanc control%' THEN 'Sanctions Control & Ownership Feed'
			WHEN lower(product_service) LIKE '%lists for pay%' THEN 'Lists for Payments & Transactions Screening - Feed' 
			WHEN lower(product_service) LIKE '%adverse media%' THEN 'Adverse Media' 
			WHEN lower(product_service) LIKE '%adv media%' THEN 'Adverse Media' 
			WHEN lower(product_service) LIKE '%screening & monitor%' THEN 'Screening & Monitoring' 
			WHEN lower(product_service) LIKE '%integrity check%' THEN 'Integrity Check' 
			WHEN lower(product_service) LIKE '%state-owned companies%' THEN 'State-Owned Companies' 
			WHEN lower(product_service) LIKE '%dual-use goods%' THEN 'Dual-Use Goods' 
			WHEN lower(product_service) LIKE '%fcs w factiva%' THEN 'Financial Crime + Factiva' 
			WHEN lower(product_service) LIKE '%trade compliance%' THEN 'RiskCenter Trade Compliance' 
			WHEN lower(product_service) LIKE '%sanction insight%' THEN 'Sanctions Insight' 
			WHEN product_category = 'Legacy and CP2' THEN 'UI Products' 
			WHEN product_category = 'Integration Services' THEN 'Workflow/Integration' 
			WHEN product_category = 'Legacy DNA' THEN 'Other' 
			WHEN product_category = 'Factiva' THEN 'UI Products' 
			WHEN product_category = 'RiskFeeds' THEN 'Specialized Feed' 
			WHEN product_service = 'Scr&Mon-AdvMedia (Entities)-API' THEN 'Screening & Monitoring API' 
			ELSE product_category 
		END AS product_group, 
		opps.product_service AS product, 
	    CAST(NULL AS int) AS recurring_revenue, 
	    CAST(NULL AS int) AS non_recurring_revenue, 
		CAST(NULL AS int) AS revenue, 
		COALESCE(opps.annual_amount, 0) AS annualized_opp_value, -- open opp value
		CAST(NULL AS int) AS xsell_value, 
		CAST(NULL AS boolean) AS is_expansion, 
		COALESCE(loc.primary_address_address_region_name, 'Unavailable') AS state, 
		COALESCE(loc.primary_address_address_country_name, 'Unavailable') AS country, 
		COALESCE(loc.primary_address_continental_region_name, 'Unavailable') AS region, 
		COALESCE(link.parent_duns, link.head_quarter_duns) AS parent_or_hq_duns, 
		COALESCE(link.global_ultimate_duns, opps.duns_n) AS global_ultimate_duns, -- In the standalone cases just use their own DUNS as their Global Ultimate 
		COALESCE(trim(BOTH FROM link.global_ult_name), concat('Unknown - ', opps.duns_n)) AS global_ult_name, 
		COALESCE(link.is_standalone, TRUE) AS is_standalone, 
		COALESCE(inds.is_fortune1000, FALSE) AS is_fortune1000, 
		COALESCE(inds.is_small_business, FALSE) AS is_small_business, 
		inds.primary_industry_toplevel, 
		inds.primary_industry_highlevel, 
		inds.primary_industry_detail, 
		inds.primary_sic_max_detail, 
		inds.naics_industry_toplevel, 
		inds.naics_industry_highlevel, 
		inds.naics_industry_detail, 
		inds.naics_secondary_industry_detail, 
		parent_override, 
		CASE WHEN parent_override IN 
		(SELECT * FROM sandbox_hvc.high_value_clients) THEN TRUE 
		 ELSE FALSE END AS is_hvc, 
		COALESCE(hc.sector, is4.sector, is3.sector, is2.sector, is1.sector) sector, 
		COALESCE(hc.prop_group, is4.prop_group, is3.prop_group, is2.prop_group, is1.prop_group) prop_group  
	FROM opportunities opps 
	FULL JOIN primary_submap comp 
		ON comp.duns_number = opps.duns_n 
	LEFT JOIN linkage_submap link 
		ON comp.duns_number = link.duns_number 
	LEFT JOIN contact_submap loc 
		ON comp.duns_number = loc.duns_number 
	LEFT JOIN industry_submap inds 
		ON comp.duns_number = inds.duns_number 
	LEFT JOIN hvc_override hvc 
		ON hvc.global_ult_name = link.global_ult_name 
	LEFT JOIN sandbox_hvc.industry_sectors is4 ON (substring(inds.primary_industry_naics, 1, 4) = is4.naics_code)
	LEFT JOIN sandbox_hvc.industry_sectors is3 ON (substring(inds.primary_industry_naics, 1, 3) = is3.naics_code)
	LEFT JOIN sandbox_hvc.industry_sectors is2 ON (substring(inds.primary_industry_naics, 1, 2) = is2.naics_code)
	LEFT JOIN sandbox_hvc.industry_sectors is1 ON (substring(inds.primary_industry_naics, 1, 1) = is1.naics_code)
	LEFT JOIN sandbox_hvc.holding_companies hc ON (hc.duns = comp.duns_number)
	LEFT JOIN sandbox_hvc.opp_prod_mapping opr 
		ON opps.product_service = opr.opportunity_product 
	ORDER BY brand, annualized_opp_value DESC 
) 


SELECT * FROM revenue_data 
UNION ALL 
SELECT * FROM opps_data
