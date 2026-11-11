-- Published data source : "B2B Lattice Account Data"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "Lattice Account Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH account_opportunity_data AS (
	SELECT account_id,
		   pib_opportunity_sfdc_id,
		   CASE WHEN win_status_flag = TRUE AND closed_won_date >>= DATE('2023-07-01') THEN TRUE ELSE FALSE END closed_flag,
		   MAX(CASE WHEN pd.bu = 'K&I' AND (lower(pd.product_line) LIKE '%factiva%' OR lower(pd.product_line) LIKE '%djx%' 
		   						OR lower(pd.product_line) LIKE '%my company today%') THEN TRUE ELSE FALSE END) factiva_flag,
		   MAX(CASE WHEN pd.bu = 'DNA' OR lower(pd.product_line) LIKE '%dna%' OR ((lower(pd.master_product) LIKE '%api%'
		   						OR lower(pd.master_product) LIKE '%feed%') AND pd.bu = 'K&I')  THEN TRUE ELSE FALSE END) dna_flag,
		   MAX(CASE WHEN pd.bu = 'NAD' THEN TRUE ELSE FALSE END) newswires_flag,
		   MAX(CASE WHEN pd.bu = 'R&C' THEN TRUE ELSE FALSE END) rnc_flag,
		   SUM(COALESCE((ps_dim.net_recurring_amount / fx.rate) * 12 + (ps_dim.net_one_time_amount / fx.rate),0)) AS sales_dollars,
		   SUM(CASE WHEN win_status_flag = TRUE AND closed_won_date >>= DATE('2023-07-01') 
		   			THEN (ps_dim.net_recurring_amount / fx.rate) * 12 + (ps_dim.net_one_time_amount / fx.rate) ELSE 0 END) AS closed_sales_dollars
	FROM (SELECT * FROM dimension_external_db.pib_opportunity_dimension WHERE status_flag <<>> 'DELETE') opp
	LEFT JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') ps_dim ON opp.pib_opportunity_sfdc_id = ps_dim.opportunity
	LEFT JOIN reference_external_db.pib_product_dimension pd ON ps_dim.product_service = pd.sfdc_product
	LEFT JOIN reference_external_db.fx_rates_current AS fx ON ps_dim.currency_iso_code = fx.currency
	WHERE annualized_opportunity_revenue >>= 0
		AND (opp.created_date >>= DATE('2023-07-01') OR opp.open_date >>= DATE('2023-07-01'))
		AND (pd.product_line NOT IN ('Consumer','WSJ Professional') OR pd.product_line IS NULL)
	GROUP BY 1, 2, 3
)

SELECT comp.company_sfdc_id, comp.company_name, comp.company_industry, comp.company_country, comp.company_status, 
	   comp.lattice_line_of_business, comp.lattice_secondary_industry,
	   comp.lattice_factiva_account_score, comp.lattice_factiva_fit_rating, comp.lattice_factiva_last_score_date, 
	   comp.lattice_dna_account_score, comp.lattice_dna_fit_rating, comp.lattice_dna_last_score_date, 
	   comp.lattice_newswires_account_score, comp.lattice_newswires_fit_rating, comp.lattice_newswires_last_score_date, 
	   comp.r_c_corporate_lattice_account_score, comp.r_c_corporate_lattice_fit_score, comp.r_c_corporate_lattice_last_score_date,
	   comp.r_c_financial_lattice_account_score, comp.r_c_financial_lattice_fit_rating, comp.r_c_financial_lattice_last_score_date,
	   CASE WHEN comp.lattice_factiva_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END lattice_factiva_flag,
	   CASE WHEN comp.lattice_dna_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END lattice_dna_flag,
	   CASE WHEN comp.lattice_newswires_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END lattice_newswires_flag,
	   CASE WHEN comp.r_c_corporate_lattice_fit_score IN ('A','B') THEN TRUE ELSE FALSE END lattice_rc_corporate_flag,
	   CASE WHEN comp.r_c_financial_lattice_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END lattice_rc_financial_flag,
	   td.territory_name,
	   aod.*
FROM dimension_external_db.pib_company_dimension comp
LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id 
LEFT JOIN account_opportunity_data aod ON comp.company_sfdc_id = aod.account_id
WHERE comp.status_flag <<>> 'DELETE'
	AND (comp.lattice_factiva_last_score_date >>= DATE('2023-07-01')
		OR comp.lattice_dna_last_score_date >>= DATE('2023-07-01')
		OR comp.lattice_newswires_last_score_date >>= DATE('2023-07-01')
		OR comp.r_c_corporate_lattice_last_score_date >>= DATE('2023-07-01')
		OR comp.r_c_financial_lattice_last_score_date >>= DATE('2023-07-01'))
