-- Published data source : "B2B Eloqua Forms - Test"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "funnel"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH 
form_submissions as(
select DISTINCT
marketing_interactions_id, 
date(mk.created_date) submitted_date, 
COALESCE(contact_name, lds2.converted_contact_id) contact_sfdc_id
   , COALESCE(mk.lead_name, lds.lead_sfdc_id, lds2.lead_sfdc_id, lds3.lead_sfdc_id) lead_sfdc_id
   , mk.email_address
   , mk.owner_id
   , mk.name
   , mk.content_type
   , mk.sfdc_campaign_code
    , camp.name campaign_name
    , camp.type campaign_type
   , mk.sfdc_campaign_member_status
   , mk.utm_campaign
   , mk.utm_source
   , mk.utm_content
   , mk.utm_medium
   , mk.utm_term
   , mk.web_form_name
    FROM
     dimension_external_db.pib_marketing_interaction_dimension mk
   LEFT JOIN dimension_external_db.pib_leads_dimension lds ON (mk.lead_name = lds.lead_sfdc_id)
   left join dimension_external_db.pib_leads_dimension lds2 on mk.contact_name=lds2.converted_contact_id
   left join dimension_external_db.pib_leads_dimension lds3 on mk.email_address=lds3.email_address

   left join dimension_external_db.pib_campaign_dimension camp on mk.sfdc_campaign_code= camp.sfdc_campaign_id
WHERE ((date(mk.created_date) >>= date('2024-07-01')) AND (mk.web_form_name IS NOT NULL))
)
, marketing_qualified_leads as(
  SELECT fs.lead_sfdc_id, MIN(last_modified_date) as marketing_qualified_date, min(cycle_date) as marketing_qualified_cycle_date
  FROM 
  form_submissions fs 
    left join (SELECT DISTINCT web_form_name, region, product_of_interest, marketing_tactic_original, marketing_tactic_most_recent, marketing_qualified_flag, lead_status, lead_source, lead_sfdc_id, lead_score, lead_name, lead_owner,
           lead_created_date, lead_country, lead_converted_flag, lead_company, last_modified_date, content_type, buying_center, cycle_date
    FROM dimension_external_db.pib_leads_dimension_history   
    WHERE (lead_status is not null
       OR converted_contact_id IS NOT NULL OR converted_contact_id != ''
       OR converted_opportunity_id IS NOT NULL OR converted_opportunity_id != '')  ) lds on (fs.lead_sfdc_id=lds.lead_sfdc_id and fs.submitted_date<<=lds.cycle_date)
  GROUP BY fs.lead_sfdc_id ),

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
  
mql_info as (
SELECT ldh.lead_sfdc_id, ldh.lead_owner, ud.user_full_name as mql_owner, ud.user_division as mql_owner_region, td.territory_name as mql_territory, td.region_code as mql_region,
		   ldh.category_pib,
		   ldh.category_dna,
		   ldh.category_factiva,
		   ldh.category_fn_pen,
		   ldh.category_newswires,
		   ldh.category_other_pib,
		   ldh.category_wsj_csuite_memberships,
		   ldh.category_wsj_corp,
		   ldh.category_wsj_pro,
		   ldh.category_risk_compliance,
		   ldh.CATEGORY_DJ_CONTENT_LICENSING, 
		   ldh.CATEGORY_DFOA,
		   ldh.CATEGORY_MCCLOSKEY,
		   ldh.CATEGORY_OPIS,
		   ldh.CATEGORY_PCW, 
		   ldh.WSJ_ENTERPRISE_PRODUCT, 
		   ldh.r_c_corporate_lead_score,
		   ldh.r_c_financial_lead_score,
		   ldh.lattice_dna_lead_score,
		   ldh.lattice_factiva_lead_score,
		   ldh.lattice_newswires_lead_score, 
		   ldh.sales_inquiry_score,
		   ldh.prospect_lead_score,
           ldh.lead_score,
           es.factiva_fit_rating,
		   es.newswires_fit_rating,
		   es.rnc_corporate_fit_rating,
		   es.rnc_financial_fit_rating
FROM marketing_qualified_leads mql
INNER JOIN dimension_external_db.pib_leads_dimension_history ldh on ldh.lead_sfdc_id = mql.lead_sfdc_id
										and ldh.cycle_date = mql.marketing_qualified_cycle_date
LEFT JOIN dimension_external_db.pib_user_dimension ud on ldh.lead_owner = ud.user_sfdc_id

LEFT JOIN dimension_external_db.pib_territory_dimension td on td.territory_sfdc_id = ldh.primary_territory
left join eloqua_scores es on
		mql.lead_sfdc_id = es.lead_sfdc_id and mql.marketing_qualified_cycle_date = es.cycle_date
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
, 25, 26, 27, 28,29,30,31,32,33,34
),

disqualified_leads as (
  SELECT fs.lead_sfdc_id, MIN(last_modified_date) as disqualified_date
    FROM 
    form_submissions fs
    left join ( 
    SELECT DISTINCT web_form_name, region, product_of_interest, marketing_tactic_original, marketing_tactic_most_recent, marketing_qualified_flag, lead_status, lead_source, lead_sfdc_id, lead_score, lead_name, lead_owner,
           lead_created_date, lead_country, lead_converted_flag, lead_company, last_modified_date, content_type, buying_center, cycle_date from dimension_external_db.pib_leads_dimension_history 
    WHERE (lead_status IN ('Disqualified','Return to Marketing','Unqualified'))) lds on fs.lead_sfdc_id=lds.lead_sfdc_id and fs.submitted_date<<=lds.cycle_date
  GROUP BY fs.lead_sfdc_id),

in_working_leads as (
  SELECT fs.lead_sfdc_id, MIN(last_modified_date) as started_working_date
  
    FROM 
    form_submissions fs
    left join  (
    SELECT DISTINCT web_form_name, region, product_of_interest, marketing_tactic_original, marketing_tactic_most_recent, marketing_qualified_flag, lead_status, lead_source, lead_sfdc_id, lead_score, lead_name, lead_owner, cycle_date,
           lead_created_date, lead_country, lead_converted_flag, lead_company, last_modified_date, content_type, buying_center from dimension_external_db.pib_leads_dimension_history 
    WHERE (lead_status IN ('Working','Qualified','Future Follow-up','Converted to Opportunity','Converted to Contact Only', 'Existing Contact') 
       OR converted_contact_id IS NOT NULL OR converted_contact_id != ''
       OR converted_opportunity_id IS NOT NULL OR converted_opportunity_id != '')) lds on fs.lead_sfdc_id= lds.lead_sfdc_id and fs.submitted_date<<=lds.cycle_date
  GROUP BY 1),

sales_qualified_leads as (
 SELECT fs.lead_sfdc_id, MIN(last_modified_date) as sales_qualified_date
  FROM form_submissions fs 
  left join(
    SELECT DISTINCT web_form_name, region, product_of_interest, marketing_tactic_original, marketing_tactic_most_recent, marketing_qualified_flag, lead_status, lead_source, lead_sfdc_id, lead_score, lead_name, lead_owner,
           lead_created_date, lead_country, lead_converted_flag, lead_company, last_modified_date, content_type, buying_center, cycle_date
 FROM dimension_external_db.pib_leads_dimension_history 
    WHERE (lead_status IN ('Qualified','Converted to Opportunity','Converted to Contact Only', 'Existing Contact')
       OR converted_contact_id IS NOT NULL OR converted_contact_id != ''
       OR converted_opportunity_id IS NOT NULL OR converted_opportunity_id != '')) lds on fs.lead_sfdc_id= lds.lead_sfdc_id and fs.submitted_date<<=cycle_date
  GROUP BY 1),
 
different_primary_contacts as (
  SELECT pld.lead_sfdc_id, pld.lead_name, pld.converted_contact_id, ctd.contact_sfdc_id, opp.pib_opportunity_sfdc_id, opp.opportunity_number
  FROM dimension_external_db.pib_opportunity_dimension opp
  LEFT JOIN dimension_external_db.pib_leads_dimension pld ON opp.pib_opportunity_sfdc_id = pld.converted_opportunity_id
  LEFT JOIN dimension_external_db.pib_contact_dimension ctd ON opp.primary_contact = ctd.contact_sfdc_id
  WHERE pld.converted_contact_id <<>> ctd.contact_sfdc_id
    AND ctd.contact_sfdc_id IS NOT NULL
  GROUP BY pld.lead_sfdc_id, pld.lead_name, pld.converted_contact_id, ctd.contact_sfdc_id, opp.pib_opportunity_sfdc_id, opp.opportunity_number),

account_opp as (
SELECT comp.company_sfdc_id,
	   comp.company_name,
       comp.company_industry,
       comp.company_country,
       comp.lattice_dna_fit_rating AS lattice_dna_account_score,
       comp.lattice_factiva_fit_rating AS lattice_factiva_account_score,
       comp.lattice_newswires_fit_rating AS lattice_newswires_account_score,
       comp.r_c_corporate_lattice_fit_score AS lattice_rc_corporate_account_score,
       comp.r_c_financial_lattice_fit_rating AS lattice_rc_financial_account_score,
       comp.lattice_line_of_business AS company_lattice_line_of_business,
       comp.lattice_secondary_industry AS company_lattice_seconday_industry,
       comp.lattice_revenue_range AS company_lattice_revenue_range,
       comp.lattice_employee_range AS company_lattice_employee_range,
       opp.pib_opportunity_sfdc_id,
       opp.opportunity_number,
       opp.opportunity_name,
       oud.user_full_name as opp_owner,
       DATE_TRUNC('day',opp.created_date) opportunity_created_date,
       DATE_TRUNC('day',opp.open_date) opportunity_open_date,
       opp.sales_stage,
       opp.sale_type,
       opp.closed_won_date,
       DATE(opp.opportunity_closed_date) AS opp_closed_date,
       opp.win_status_flag,
       opp.annualized_opportunity_revenue,
       opp_td.territory_name AS opportunity_territory_name,
       comp_td.territory_name AS company_territory_name,
       opp_td.sales_region AS opportunity_sales_region,
       comp_td.sales_region AS company_sales_region,
       opp_td.region_code AS opportunity_region_code,
       comp_td.region_code AS company_region_code,
       opp_contact.contact_sfdc_id AS opp_contact_sfdc_id,
       opp_contact.contact_full_name AS opp_pc_contact_name,
       opp_contact.lead_source AS opp_pc_lead_source,
       opp_contact.content_type AS opp_pc_content_type,
       opp_contact.marketing_tactic_original AS opp_pc_marketing_tactic_original,
       opp_contact.marketing_tactic_most_recent AS opp_pc_marketing_tactic_most_recent,
       opp_contact.buying_center as opp_pc_buying_center,
       ps_dim.product_line AS sf_product_line,
       ps_dim.product_service AS sf_product_service,
       ps_dim.product_category AS sf_product_category,
       ps_dim.currency_iso_code,
       ps_dim.net_amount,
       ps_dim.net_one_time_amount,
       ps_dim.net_recurring_amount,
       fx.rate,
       ps_dim.forecast_month,
       ps_dim.sfdc_product_services_id,
       pd.master_product AS pd_master_product,
       pd.product_line AS pd_product_line,
       pd.bu AS pd_bu
FROM (SELECT * FROM dimension_external_db.pib_opportunity_dimension WHERE status_flag <<>> 'DELETE') opp
LEFT JOIN (SELECT * FROM dimension_external_db.pib_company_dimension WHERE status_flag <<>> 'DELETE') comp ON opp.account_id = comp.company_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') opp_td ON opp.opportunity_territory = opp_td.territory_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') oud ON opp.opportunity_owner = oud.user_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') comp_td ON comp.company_territory = comp_td.territory_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') ps_dim ON opp.pib_opportunity_sfdc_id = ps_dim.opportunity
LEFT JOIN reference_external_db.pib_product_dimension pd ON ps_dim.product_service = pd.sfdc_product 
LEFT JOIN reference_external_db.fx_rates_current fx ON ps_dim.currency_iso_code = fx.currency
LEFT JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') opp_contact ON opp.primary_contact = opp_contact.contact_sfdc_id
where ps_dim.product_line <<>> 'FN/PEN'),

funnel_view as (

SELECT DISTINCT fs.*, 

       --COALESCE(pld.lead_source, ctd.lead_source) lead_source,
       COALESCE(ctd.lead_source, pld.lead_source) lead_source,
       --pld.lead_source,
       DATE_TRUNC('day',pld.lead_created_date) lead_created_date,
       pld.product_of_interest,
       DATE_TRUNC('day',mqls.marketing_qualified_date) marketing_qualified_date,
       pld.region,
       COALESCE(ctd.marketing_tactic_original, pld.marketing_tactic_original) marketing_tactic_original,
       --pld.marketing_tactic_original,
       COALESCE(ctd.marketing_tactic_most_recent, pld.marketing_tactic_most_recent) marketing_tactic_most_recent,
       --pld.marketing_tactic_most_recent,
       pld.lead_status,
       --- Lead Scores -------------
       COALESCE(ctd.lead_score, pld.lead_score) lead_score,
       --pld.lead_score,
       COALESCE(pld.sales_inquiry_score, ctd.sales_inquiry_score) sales_inquiry_score,
       --pld.sales_inquiry_score,
       COALESCE(ctd.prospect_lead_score, pld.prospect_lead_score) prospect_lead_score,
       --pld.prospect_lead_score,
       ------ Lead Scores ----------- 
       COALESCE(ctd.contact_full_name, pld.lead_name) contact_lead_name,
       --pld.lead_name as contact_lead_name,
       --COALESCE(ctd.email_address, pld.email_address) email_address,
       --pld.email_address,
       COALESCE(ctd.owner_id, pld.lead_owner) as owner_sfdc_id,
       --pld.lead_owner as owner_id,
      ud.user_full_name AS owner_name,
       COALESCE(ctd.contact_country, pld.lead_country) contact_lead_country,
       --pld.lead_country as contact_lead_country,
       coalesce(pld.lead_country, pld.lead_country_name) lead_country_name,
       pld.lead_converted_flag,
       pld.lead_company,
       COALESCE(ctd.buying_center, pld.buying_center) buying_center,
       --pld.buying_center,
       pld.category_pib,
       pld.category_dna,
       pld.category_factiva,
       pld.category_fn_pen,
       pld.category_newswires,
       pld.category_other_pib,
       pld.category_wsj_csuite_memberships,
       pld.category_wsj_corp,
       pld.category_wsj_pro,
       pld.category_risk_compliance,
       pld.CATEGORY_DJ_CONTENT_LICENSING, 
	 pld.CATEGORY_DFOA,
		   pld.CATEGORY_MCCLOSKEY,
		   pld.CATEGORY_OPIS,
		   pld.CATEGORY_PCW, 
		   pld.WSJ_ENTERPRISE_PRODUCT, 
       pld.r_c_corporate_lead_score,
       pld.r_c_financial_lead_score,
       pld.lattice_dna_lead_score,
       pld.lattice_factiva_lead_score,
       pld.lattice_newswires_lead_score,
       mql_info.r_c_corporate_lead_score as mql_r_c_corporate_lead_score,
	   mql_info.r_c_financial_lead_score as mql_r_c_financial_lead_score,
	   mql_info.lattice_dna_lead_score as mql_lattice_dna_lead_score,
	   mql_info.lattice_factiva_lead_score as mql_lattice_factiva_lead_score,
	   mql_info.lattice_newswires_lead_score as mql_lattice_newswires_lead_score,
       mql_info.sales_inquiry_score as mql_sales_inquiry_score,
	   mql_info.prospect_lead_score as mql_prospect_lead_score,
       mql_info.lead_score as mql_lead_score,
       mql_info.factiva_fit_rating,
       mql_info.newswires_fit_rating,
	   mql_info.rnc_corporate_fit_rating,
	   mql_info.rnc_financial_fit_rating,
       DATE_TRUNC('day',dls.disqualified_date) disqualified_date,
       pld.converted_contact_id,
       pld.converted_opportunity_id,
       pld.converted_account_id,
       pld.lattice_line_of_business AS lead_lattice_line_of_business,
       pld.lattice_secondary_industry AS lead_lattice_secondary_industry,
       pld.lattice_revenue_range AS lead_lattice_revenue_range,
       pld.lattice_employee_range AS lead_lattice_employee_range,
       DATE_TRUNC('day',iwls.started_working_date) started_working_date,
       DATE_TRUNC('day',sqls.sales_qualified_date) sales_qualified_date
       ,
       ctd.contact_status,
       DATE_TRUNC('day',ctd.created_date) contact_created_date,
       COALESCE(ctd.account_id, pld.converted_account_id) account_join_id
       ,
       ac.*
FROM form_submissions fs 
left join (SELECT * FROM dimension_external_db.pib_leads_dimension WHERE status_flag <<>> 'DELETE') pld on fs.lead_sfdc_id=pld.lead_sfdc_id
left join (SELECT * FROM dimension_external_db.pib_contact_dimension 
				 WHERE status_flag <<>> 'DELETE' ) ctd ON fs.contact_sfdc_id = ctd.contact_sfdc_id
LEFT JOIN marketing_qualified_leads mqls ON pld.lead_sfdc_id = mqls.lead_sfdc_id
LEFT JOIN disqualified_leads dls ON pld.lead_sfdc_id = dls.lead_sfdc_id
LEFT JOIN in_working_leads iwls ON pld.lead_sfdc_id = iwls.lead_sfdc_id
LEFT JOIN sales_qualified_leads sqls ON pld.lead_sfdc_id = sqls.lead_sfdc_id
LEFT JOIN mql_info on pld.lead_sfdc_id = mql_info.lead_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') ud ON COALESCE(ctd.owner_id, pld.lead_owner) = ud.user_sfdc_id
left join account_opp ac on ac.company_sfdc_id = COALESCE(ctd.account_id, pld.converted_account_id)
--left join account_opp ac on ac.company_sfdc_id = pld.converted_account_id

)

select * from funnel_view where submitted_date<<= opportunity_created_date and 
(date_diff('day', date(submitted_date), date(opportunity_created_date)) <<= 365) or opportunity_created_date is null
