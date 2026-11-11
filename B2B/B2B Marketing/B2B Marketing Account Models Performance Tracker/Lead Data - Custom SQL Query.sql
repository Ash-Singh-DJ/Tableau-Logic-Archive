-- Dashboard   : "B2B Marketing Account Models Performance Tracker"  [B2B / B2B Marketing]
-- Data source : "Lead Data" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH marketing_qualified_leads as (
  SELECT lead_sfdc_id,
  		MIN(last_modified_date) as marketing_qualified_date,
  		MIN(cycle_date) as marketing_qualified_cycle_date
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

-- eloqua contact ratings
eloqua_lead_history_mapping as (
	select ech.id, pldh.lead_sfdc_id, pldh.cycle_date from csuite_external_db.eloqua_contact_history ech
	left join (SELECT * FROM dimension_external_db.pib_leads_dimension_history WHERE status_flag <<>> 'DELETE') pldh on
		ech.sfdc_lead_id = pldh.lead_sfdc_id and pldh.cycle_date = ech.cycle_date

),

eloqua_scores as (
	select elhm.*, ecrf.factiva_fit_rating, ecrf.cycle_date as fact_cycle_date
	, ecrn.newswires_fit_rating
	, rcc.rnc_corporate_fit_rating 
	, rcf.rnc_financial_fit_rating 
	from eloqua_lead_history_mapping elhm
	left join zoolander_db.eloqua_contacts_rating_factiva ecrf on
		elhm.id = ecrf.id and elhm.cycle_date = ecrf.cycle_date
	left join zoolander_db.eloqua_contacts_rating_newswires ecrn on
		elhm.id = ecrn.id and elhm.cycle_date = ecrn.cycle_date
	left join zoolander_db.eloqua_contacts_rating_rnc_corporate rcc on
		elhm.id = rcc.id and elhm.cycle_date = rcc.cycle_date
	left join zoolander_db.eloqua_contacts_rating_rnc_financial rcf on
		elhm.id = rcf.id and elhm.cycle_date = rcf.cycle_date
),

/*eloqua_lead_mapping as (
	select es.*, pld.lead_sfdc_id from eloqua_scores es
	left join (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') pld on
		es.sfdc_lead_id = pld.lead_sfdc_id
),*/

marketing_qualified_scores AS (
	SELECT pldh.lead_sfdc_id,
		   lead_score,
		   prospect_lead_score,
		   sales_inquiry_score,
		   pldh.r_c_corporate_lead_score,
		   pldh.r_c_financial_lead_score,
		   pldh.lattice_dna_lead_score,
		   pldh.lattice_factiva_lead_score,
		   pldh.lattice_newswires_lead_score,

		   es.factiva_fit_rating,
		   es.newswires_fit_rating,
		   es.rnc_corporate_fit_rating,
		   es.rnc_financial_fit_rating,
		   CASE WHEN lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_old_model,
		   
		   CASE WHEN lattice_factiva_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_factiva_model,
		   CASE WHEN lattice_newswires_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_newswires_model,
		   CASE WHEN r_c_corporate_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_rnc_corporate_model,
		   CASE WHEN r_c_financial_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_rnc_financial_model,

		   CASE WHEN es.factiva_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END qualified_factiva_model_new,
		   CASE WHEN es.newswires_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END qualified_newswires_model_new,
		   CASE WHEN es.rnc_corporate_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END qualified_rnc_corporate_model_new,
		   CASE WHEN es.rnc_financial_fit_rating IN ('A','B') THEN TRUE ELSE FALSE END qualified_rnc_financial_model_new,

		   
		   
		   CASE WHEN prospect_lead_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_prospect_lead,
		   CASE WHEN sales_inquiry_score IN ('A1','A2','B1','B2') THEN TRUE ELSE FALSE END qualified_sales_inquiry
	FROM dimension_external_db.pib_leads_dimension_history pldh
	LEFT JOIN marketing_qualified_leads mqls ON pldh.lead_sfdc_id = mqls.lead_sfdc_id
	left join eloqua_scores es on
		mqls.lead_sfdc_id = es.lead_sfdc_id and mqls.marketing_qualified_cycle_date = es.cycle_date
	WHERE pldh.cycle_date = mqls.marketing_qualified_cycle_date
),

account_opportunity_data AS (
	SELECT account_id,
		   pib_opportunity_sfdc_id, closed_won_date, opp.created_date, opp.open_date,
		   CASE WHEN win_status_flag = TRUE AND closed_won_date >>= DATE('2021-01-01') THEN TRUE ELSE FALSE END closed_flag,
		   MAX(CASE WHEN pd.bu = 'K&I' AND (lower(pd.product_line) LIKE '%factiva%' OR lower(pd.product_line) LIKE '%djx%' 
		   						OR lower(pd.product_line) LIKE '%my company today%') THEN TRUE ELSE FALSE END) factiva_flag,
		   MAX(CASE WHEN pd.bu = 'DNA' OR lower(pd.product_line) LIKE '%dna%' OR ((lower(pd.master_product) LIKE '%api%'
		   						OR lower(pd.master_product) LIKE '%feed%') AND pd.bu = 'K&I')  THEN TRUE ELSE FALSE END) dna_flag,
		   MAX(CASE WHEN pd.bu = 'NAD' THEN TRUE ELSE FALSE END) newswires_flag,
		   MAX(CASE WHEN pd.bu = 'R&C' THEN TRUE ELSE FALSE END) rnc_flag,
		   SUM(COALESCE((ps_dim.net_recurring_amount / fx.rate) * 12 + (ps_dim.net_one_time_amount / fx.rate),0)) AS sales_dollars,
		   SUM(CASE WHEN win_status_flag = TRUE AND closed_won_date >>= DATE('2021-01-01') 
		   			THEN (ps_dim.net_recurring_amount / fx.rate) * 12 + (ps_dim.net_one_time_amount / fx.rate) ELSE 0 END) AS closed_sales_dollars
	FROM (SELECT * FROM dimension_external_db.pib_opportunity_dimension WHERE status_flag <<>> 'DELETE') opp
	INNER JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') ps_dim ON opp.pib_opportunity_sfdc_id = ps_dim.opportunity
	LEFT JOIN reference_external_db.pib_product_dimension pd ON ps_dim.product_service = pd.sfdc_product
	LEFT JOIN reference_external_db.fx_rates_current AS fx ON ps_dim.currency_iso_code = fx.currency
	WHERE annualized_opportunity_revenue >>= 0
		AND (opp.created_date >>= DATE('2021-01-01') OR opp.open_date >>= DATE('2021-01-01'))
		AND (pd.product_line NOT IN ('Consumer','WSJ Professional') OR pd.product_line IS NULL)
	GROUP BY 1, 2, 3, 4, 5, 6
),

account_lead_mapping AS (
	SELECT lead_sfdc_id, contact_sfdc_id, comp.company_sfdc_id, comp.company_name
	FROM (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') pld
	FULL OUTER JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') ctd 
		ON pld.converted_contact_id = ctd.contact_sfdc_id
	LEFT JOIN (SELECT * FROM dimension_external_db.pib_company_dimension WHERE status_flag <<>> 'DELETE') comp
		ON COALESCE(ctd.account_id, pld.converted_account_id) = comp.company_sfdc_id
	GROUP BY 1, 2, 3, 4
),


different_primary_contacts as (
  SELECT pld.lead_sfdc_id, pld.lead_name, pld.converted_contact_id, ctd.contact_sfdc_id, opp.pib_opportunity_sfdc_id, opp.opportunity_number
  FROM dimension_external_db.pib_opportunity_dimension opp
  LEFT JOIN dimension_external_db.pib_leads_dimension pld ON opp.pib_opportunity_sfdc_id = pld.converted_opportunity_id
  LEFT JOIN dimension_external_db.pib_contact_dimension ctd ON opp.primary_contact = ctd.contact_sfdc_id
  WHERE pld.converted_contact_id <<>> ctd.contact_sfdc_id
    AND ctd.contact_sfdc_id IS NOT NULL
  GROUP BY pld.lead_sfdc_id, pld.lead_name, pld.converted_contact_id, ctd.contact_sfdc_id, opp.pib_opportunity_sfdc_id, opp.opportunity_number),



rejected_leads as (
  SELECT lead_sfdc_id, CAST(MIN(last_modified_date) AS DATE) as rejected_date
  FROM (
    SELECT DISTINCT web_form_name, region, product_of_interest, marketing_tactic_original, marketing_tactic_most_recent, marketing_qualified_flag, lead_status, lead_source, lead_sfdc_id, lead_score, lead_name, lead_owner,
           lead_created_date, lead_country, lead_converted_flag, lead_company, last_modified_date, content_type, buying_center
    FROM dimension_external_db.pib_leads_dimension_history
    WHERE (lead_status ='Return to Marketing'))
  GROUP BY lead_sfdc_id),

lead_history_ranked AS (
SELECT lead_sfdc_id, lead_owner, cycle_date,
	RANK() OVER(partition by lead_sfdc_id ORDER BY cycle_date desc) lead_history_rank
FROM dimension_external_db.pib_leads_dimension_history _dimension_history
WHERE lead_created_date >>= date('2019-01-01')
GROUP BY 1, 2, 3),

rejection_status AS (
SELECT lead_history_ranked.*, 
		ud.user_full_name AS current_owner_name,
		rejected_leads.rejected_date,
		CASE WHEN rejected_leads.rejected_date >> lead_history_ranked.cycle_date THEN 'BEFORE REJECTION'  ELSE 'PAST REJECTION' END AS event_relative_to_rejection
FROM rejected_leads
INNER JOIN lead_history_ranked ON rejected_leads.lead_sfdc_id = lead_history_ranked.lead_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') ud ON ud.user_sfdc_id = lead_history_ranked.lead_owner),

lead_rank_matches AS (
SELECT lead_sfdc_id, min(lead_history_rank) AS rank_match
FROM rejection_status
WHERE event_relative_to_rejection = 'BEFORE REJECTION'
GROUP BY 1),

rejector_info AS (
SELECT rs.lead_sfdc_id, rs.current_owner_name AS rejector_name, rs.rejected_date
FROM rejection_status rs
INNER JOIN lead_rank_matches lrm ON rs.lead_sfdc_id = lrm.lead_sfdc_id AND rs.lead_history_rank = lrm.rank_match)


SELECT pld.lead_sfdc_id AS lead_sfdc_id_key,
	   pld.lead_name,
	   pld.content_type,
	   pld.lead_source,
	   pld.lead_status,
	   DATE_TRUNC('day',pld.lead_created_date) lead_created_date,
	   pld.product_of_interest,
       DATE_TRUNC('day',mqls.marketing_qualified_cycle_date) marketing_qualified_cycle_date,
       DATE_TRUNC('day',mqls.marketing_qualified_date) marketing_qualified_date,
       pld.converted_contact_id,
       pld.prospect_lead_score AS pls_current,
       mqs.*,
       alm.company_sfdc_id,
       alm.company_name,
       aod.*,
       rejector_info.rejector_name,
	   rejector_info.rejected_date,
	   ctd.contact_sfdc_id,
       ctd.contact_status,
       DATE_TRUNC('day', ctd.created_date) contact_created_date,
       COALESCE(ctd.account_id, pld.converted_account_id) account_join_id
FROM (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') pld
FULL OUTER JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension 
				 WHERE status_flag <<>> 'DELETE' AND contact_sfdc_id NOT IN 
				 (SELECT contact_sfdc_id FROM different_primary_contacts)) ctd ON pld.converted_contact_id = ctd.contact_sfdc_id
LEFT join marketing_qualified_leads mqls ON pld.lead_sfdc_id = mqls.lead_sfdc_id
LEFT JOIN marketing_qualified_scores mqs ON pld.lead_sfdc_id = mqs.lead_sfdc_id
LEFT JOIN account_lead_mapping alm ON pld.lead_sfdc_id = alm.lead_sfdc_id
LEFT JOIN account_opportunity_data aod ON alm.company_sfdc_id = aod.account_id 
			 and aod.pib_opportunity_sfdc_id = pld.converted_opportunity_id
LEFT JOIN rejector_info ON rejector_info.lead_sfdc_id = pld.lead_sfdc_id
WHERE mqls.marketing_qualified_cycle_date >>= DATE('2023-06-21') 
/*	AND (category_pib = TRUE OR category_dna = TRUE OR category_factiva = TRUE OR category_newswires = TRUE 
    		OR category_risk_compliance = TRUE OR category_other_pib = TRUE 
    		OR factiva_flag OR dna_flag OR rnc_flag OR newswires_flag
    		or category_wsj_pro = true or category_wsj_csuite_memberships = true or category_wsj_corp = true
    		or category_fn_pen = true)*/
    --and pld.lead_sfdc_id = '00Q5Y00002QPnsqUAD'
    -- factiva: 00Q5Y00002M38gdUAB
    -- rnc financial: 00Q5Y000022khcVUAQ  
    -- null VP case: 00Q1O00001oi2NXUAY
