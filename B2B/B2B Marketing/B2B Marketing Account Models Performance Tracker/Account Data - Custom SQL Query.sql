-- Dashboard   : "B2B Marketing Account Models Performance Tracker"  [B2B / B2B Marketing]
-- Data source : "Account Data" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH account_opportunity_data AS (
	SELECT account_id,
		   pib_opportunity_sfdc_id,
		   CASE WHEN win_status_flag = TRUE AND closed_won_date >>= DATE('2022-07-01') THEN TRUE ELSE FALSE END closed_flag,
		   MAX(CASE WHEN pd.bu = 'K&I' AND (lower(pd.product_line) LIKE '%factiva%' OR lower(pd.product_line) LIKE '%djx%' 
		   						OR lower(pd.product_line) LIKE '%my company today%') THEN TRUE ELSE FALSE END) factiva_flag,
		   MAX(CASE WHEN pd.bu = 'DNA' OR lower(pd.product_line) LIKE '%dna%' OR ((lower(pd.master_product) LIKE '%api%'
		   						OR lower(pd.master_product) LIKE '%feed%') AND pd.bu = 'K&I')  THEN TRUE ELSE FALSE END) dna_flag,
		   MAX(CASE WHEN pd.bu = 'NAD' THEN TRUE ELSE FALSE END) newswires_flag,
		   MAX(CASE WHEN pd.bu = 'R&C' THEN TRUE ELSE FALSE END) rnc_flag,
		   SUM(COALESCE((ps_dim.net_recurring_amount / fx.rate) * 12 + (ps_dim.net_one_time_amount / fx.rate),0)) AS sales_dollars,
		   SUM(CASE WHEN win_status_flag = TRUE AND closed_won_date >>= DATE('2022-07-01') 
		   			THEN (ps_dim.net_recurring_amount / fx.rate) * 12 + (ps_dim.net_one_time_amount / fx.rate) ELSE 0 END) AS closed_sales_dollars
	FROM (SELECT * FROM dimension_external_db.pib_opportunity_dimension WHERE status_flag <<>> 'DELETE') opp
	LEFT JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') ps_dim ON opp.pib_opportunity_sfdc_id = ps_dim.opportunity
	LEFT JOIN reference_external_db.pib_product_dimension pd ON ps_dim.product_service = pd.sfdc_product
	LEFT JOIN reference_external_db.fx_rates_current AS fx ON ps_dim.currency_iso_code = fx.currency
	WHERE annualized_opportunity_revenue >>= 0
		AND (opp.created_date >>= DATE('2022-07-01') OR opp.open_date >>= DATE('2022-07-01'))
		AND (pd.product_line NOT IN ('Consumer','WSJ Professional') OR pd.product_line IS NULL)
	GROUP BY 1, 2, 3
)

SELECT comp.company_sfdc_id, comp.company_name, comp.company_industry, comp.company_country, comp.company_status,
		mod_fact.factiva_account_score, mod_fact.factiva_fit_rating, mod_fact.cycle_date as factiva_last_cycle_date,
		mod_news.newswires_account_score, mod_news.newswires_fit_rating, mod_news.cycle_date as newswires_last_cycle_date, 
		mod_rccorp.rnc_corporate_account_score, mod_rccorp.rnc_corporate_fit_rating, mod_rccorp.cycle_date as rnc_corporate_last_cycle_date,
		mod_rcfin.rnc_financial_account_score, mod_rcfin.rnc_financial_fit_rating, mod_rcfin.cycle_date as rnc_financial_last_cycle_date,
		CASE WHEN mod_fact.factiva_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END model_factiva_flag,
	   CASE WHEN mod_news.newswires_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END model_newswires_flag,
	   CASE WHEN mod_rccorp.rnc_corporate_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END model_rc_corporate_flag,
	   CASE WHEN mod_rcfin.rnc_financial_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END model_rc_financial_flag,
	   td.territory_name,
	   aod.*
FROM dimension_external_db.pib_company_dimension comp
LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id 
LEFT JOIN account_opportunity_data aod ON comp.company_sfdc_id = aod.account_id
left join zoolander_db.pib_account_model_factiva mod_fact on mod_fact.sfdc_id = comp.company_sfdc_id 
left join zoolander_db.pib_account_model_newswires mod_news on mod_news.sfdc_id = comp.company_sfdc_id
left join zoolander_db.pib_account_model_rnc_corporate mod_rccorp on mod_rccorp.sfdc_id = comp.company_sfdc_id
left join zoolander_db.pib_account_model_rnc_financial mod_rcfin on mod_rcfin.sfdc_id = comp.company_sfdc_id
WHERE comp.status_flag <<>> 'DELETE'
	AND (mod_fact.cycle_date  = (select max(cycle_date) from zoolander_db.pib_account_model_factiva))
	and (mod_news.cycle_date = (select max(cycle_date) from zoolander_db.pib_account_model_newswires))
	and (mod_rccorp.cycle_date = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_corporate)
		or mod_rcfin.cycle_date = (select max(cycle_date) from zoolander_db.pib_account_model_rnc_financial)
		)
