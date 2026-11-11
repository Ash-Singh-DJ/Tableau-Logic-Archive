-- Published data source : "B2B Lattice Lead Data"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH marketing_qualified_leads as (
  SELECT lead_sfdc_id, 
  		 MIN(cycle_date) as marketing_qualified_date
  FROM (
    SELECT DISTINCT web_form_name, region, product_of_interest, marketing_tactic_original, marketing_tactic_most_recent, marketing_qualified_flag, lead_status, lead_source, lead_sfdc_id, lead_score, lead_name, lead_owner,
           lead_created_date, lead_country, lead_converted_flag, lead_company, last_modified_date, content_type, buying_center, cycle_date
    FROM dimension_external_db.pib_leads_dimension_history
    WHERE (lead_status IN ('Untouched','Working','Qualified','Future Follow-up','Converted to Opportunity','Converted to Contact Only',
                           'Disqualified','Return to Marketing','Unqualified')
       OR converted_contact_id IS NOT NULL OR converted_contact_id != ''
       OR converted_opportunity_id IS NOT NULL OR converted_opportunity_id != ''))
  GROUP BY lead_sfdc_id
),

marketing_qualified_scores AS (
	SELECT pldh.lead_sfdc_id,
		   lead_score,
		   prospect_lead_score,
		   sales_inquiry_score,
		   lattice_dna_lead_score,
		   lattice_factiva_lead_score,
		   r_c_corporate_lead_score,
		   r_c_financial_lead_score,
		   lattice_newswires_lead_score,
		   CASE WHEN lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_old_model,
		   CASE WHEN lattice_dna_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_dna_model,
		   CASE WHEN lattice_factiva_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_factiva_model,
		   CASE WHEN lattice_newswires_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_newswires_model,
		   CASE WHEN r_c_corporate_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_rnc_corporate_model,
		   CASE WHEN r_c_financial_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_rnc_financial_model,
		   CASE WHEN prospect_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_prospect_lead,
		   CASE WHEN sales_inquiry_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_sales_inquiry
	FROM dimension_external_db.pib_leads_dimension_history pldh
	LEFT JOIN marketing_qualified_leads mqls ON pldh.lead_sfdc_id = mqls.lead_sfdc_id
	WHERE pldh.cycle_date = mqls.marketing_qualified_date
),

account_opportunity_data AS (
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
),

account_lead_mapping AS (
	SELECT lead_sfdc_id, contact_sfdc_id, comp.company_sfdc_id, comp.company_name
	FROM (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') pld
	FULL OUTER JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') ctd 
		ON pld.converted_contact_id = ctd.contact_sfdc_id
	LEFT JOIN (SELECT * FROM dimension_external_db.pib_company_dimension WHERE status_flag <<>> 'DELETE') comp
		ON COALESCE(ctd.account_id, pld.converted_account_id) = comp.company_sfdc_id
	GROUP BY 1, 2, 3, 4
)

SELECT pld.lead_sfdc_id AS lead_sfdc_id_key,
	   pld.lead_name,
	   pld.content_type,
	   pld.lead_source,
	   pld.lead_status,
	   DATE_TRUNC('day',pld.lead_created_date) lead_created_date,
	   pld.product_of_interest,
       DATE_TRUNC('day',mqls.marketing_qualified_date) marketing_qualified_date,
       pld.prospect_lead_score AS pls_current,
       mqs.*,
       alm.company_sfdc_id,
       alm.company_name,
       aod.*
FROM (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') pld
LEFT JOIN marketing_qualified_leads mqls ON pld.lead_sfdc_id = mqls.lead_sfdc_id
LEFT JOIN marketing_qualified_scores mqs ON pld.lead_sfdc_id = mqs.lead_sfdc_id
LEFT JOIN account_lead_mapping alm ON pld.lead_sfdc_id = alm.lead_sfdc_id
LEFT JOIN account_opportunity_data aod ON alm.company_sfdc_id = aod.account_id
WHERE mqls.marketing_qualified_date >>= DATE('2023-07-01')
    AND (category_pib = TRUE OR category_dna = TRUE OR category_factiva = TRUE OR category_newswires = TRUE 
    		OR category_risk_compliance = TRUE OR category_other_pib = TRUE 
    		OR factiva_flag OR dna_flag OR rnc_flag OR newswires_flag)
