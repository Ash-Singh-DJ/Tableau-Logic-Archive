-- Published data source : "B2B Marketing Events Dataset - Reworked"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
            
              
            
            
            
            
            
            
            
            
/*
 * Start with a dataset of opportunities, joined to company and contact information (where the contact info is joined via the opp's primary contact)
 * Remove rows with a lead source that contains Marketing or CVent, since those are classified as Marketing Generated and Cvent Generated in the Dashboard 
 * 	(and thus cannot be Marketing Associated Opps)
 */
 WITH opps_no_marketing_prim_contact_lead_source AS 
(SELECT distinct company_sfdc_id, company_name, pib_opportunity_sfdc_id, opportunity_number, contact.lead_source AS primary_contact_lead_source, opp.created_date AS opportunity_create_date
FROM dimension_external_db.pib_opportunity_dimension opp
LEFT JOIN dimension_external_db.pib_company_dimension comp ON opp.account_id = comp.company_sfdc_id 
LEFT JOIN dimension_external_db.pib_contact_dimension contact ON opp.primary_contact = contact.contact_sfdc_id
WHERE (contact.lead_source IS NULL OR (contact.lead_source NOT LIKE 'Marketing%' and lower(contact.lead_source) NOT LIKE '%cvent%'))
),

/*
 * Create a separate set of contact-company combinations so that we can identify which accounts have Marketing-sourced contacts
 */
account_contact_data AS (
SELECT DISTINCT company_sfdc_id, company_name, contact.contact_sfdc_id, contact.lead_source, contact.created_date 
FROM dimension_external_db.pib_contact_dimension contact
LEFT JOIN dimension_external_db.pib_company_dimension comp ON contact.account_id = comp.company_sfdc_id),

/*
 * Take our opportunity dataset and join it to the account-contact dataset on the company/account ID. 
 * This creates a dataset of opportunity-account-contact combinations for all opps that are not Marketing Generated or Cvent Generated
 * We add a datediff of the contacts' create date and the opportunity create date in order to write logic to identify opps with marketing-sourced contacts created in X months relative to the opp creation date
 */
core_dataset AS (
SELECT opps.*, acd.lead_source AS contact_lead_source, acd.created_date AS contact_created_date,
		date_diff('MONTH', acd.created_date, opportunity_create_date) AS contact_opp_create_diff
FROM opps_no_marketing_prim_contact_lead_source opps
LEFT JOIN account_contact_data acd ON opps.company_sfdc_id = acd.company_sfdc_id),

/*
 * Marketing Associated Opportunities are those where the associated company/account has a Marketing-sourced contact created within 12 months of the opportunity create date
 * This table calls out those specific opportunity IDs
 */
mkt_associated_opps AS (
SELECT DISTINCT pib_opportunity_sfdc_id
FROM core_dataset
WHERE contact_opp_create_diff >>= 0
AND contact_opp_create_diff << 12
AND contact_lead_source LIKE 'Marketing%'),

/*
 * Add a date dimension for joining FY info for the created & closed won dates
 * 
 */
date_dim as (
select date(full_date) AS dat, 
	   DATE_ADD('day', -1, date(full_date)) AS dat_adj,
	   week_number_in_fiscal_year as fiscal_week, 
	   month_number_in_fiscal_year as fiscal_month, 
	   fiscal_quarter_name AS fiscal_quarter,
	   concat(fiscal_month_name, CAST(fiscal_year AS varchar)) fiscal_month_name_and_yr,
	   CAST(fiscal_year AS varchar) AS fiscal_year 
from reference_external_db.date_dimension
where full_date >>= date('2022-07-01')
and full_date <<= date_add('day', 1500, current_date)),

/*
 * Here we add a Fiscal Year category, and then do splits of the Marketing Associated opps to identify revenue and number of product-service line-items by fiscal year
 */
ma_data_for_union AS 
(SELECT  'Current FY' AS snapshot_category,
		opp_create_date.fiscal_year AS opp_create_FY,
       opp.created_date,
        opp.win_status_flag,
	   mao.pib_opportunity_sfdc_id,
	   psa.sfdc_product_services_id,
	   opp.opportunity_number,
	   comp.company_sfdc_id,
	   comp.company_name,
	   opp.opportunity_country,
	   opp.sales_stage,
       opp.sale_type,
       opp_close_date.fiscal_year AS opp_close_FY,
       opp.opportunity_closed_date,
       opp.closed_won_date,
       opp.opportunity_name,
       psa.forecast_month,
	   terr.territory_name AS opportunity_territory_name,
       terr.sales_region AS opportunity_sales_region,
       terr.region_code AS opportunity_region_code,
       usr.user_full_name AS opp_owner,
       psa.product_service,
       psa.product_line,
       psa.product_category,
       psa.net_one_time_amount / fx.rate as net_one_time_amount_usd,
       psa.net_recurring_amount / fx.rate * 12 as net_annualized_recurring_usd,
       opp.opportunity_amount,
       opp_contact.contact_sfdc_id AS opp_contact_sfdc_id,
       opp_contact.contact_full_name AS opp_pc_contact_name,
       opp_contact.lead_source AS opp_pc_lead_source,
       opp_contact.content_type AS opp_pc_content_type,
       opp_contact.marketing_tactic_original AS opp_pc_marketing_tactic_original,
       opp_contact.marketing_tactic_most_recent AS opp_pc_marketing_tactic_most_recent,
       opp_contact.buying_center as opp_pc_buying_center,
       'Marketing Associated' AS opp_itemization
FROM mkt_associated_opps mao
LEFT JOIN dimension_external_db.pib_opportunity_dimension opp ON opp.pib_opportunity_sfdc_id = mao.pib_opportunity_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') psa ON opp.pib_opportunity_sfdc_id = psa.opportunity
LEFT JOIN dimension_external_db.pib_company_dimension comp ON comp.company_sfdc_id = opp.account_id 
LEFT JOIN dimension_external_db.pib_territory_dimension terr ON opp.opportunity_territory = terr.territory_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension usr ON opp.opportunity_owner = usr.user_sfdc_id
LEFT JOIN reference_external_db.fx_rates_current fx ON psa.currency_iso_code = fx.currency
LEFT JOIN date_dim AS opp_create_date ON date(opp.created_date) = opp_create_date.dat
LEFT JOIN date_dim AS opp_close_date ON date(opp.opportunity_closed_date) = opp_close_date.dat
LEFT JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') opp_contact ON opp.primary_contact = opp_contact.contact_sfdc_id
WHERE psa.product_line <<>> 'FN/PEN'
AND opp.created_date >>= date('2022-07-01')),

/*  
 * Identify Marketing Generated & Cvent Generated opps
 */
marketing_generated_and_cvent_opps AS (
SELECT pib_opportunity_sfdc_id,
		CASE WHEN contact.lead_source LIKE 'Marketing%' THEN 'Marketing Generated'
			 WHEN lower(contact.lead_source) LIKE '%cvent%' THEN 'Cvent Generated'
			 ELSE NULL END AS opp_itemization
FROM dimension_external_db.pib_opportunity_dimension opp
LEFT JOIN dimension_external_db.pib_company_dimension comp ON opp.account_id = comp.company_sfdc_id 
LEFT JOIN dimension_external_db.pib_contact_dimension contact ON opp.primary_contact = contact.contact_sfdc_id
WHERE contact.lead_source LIKE 'Marketing%' OR lower(contact.lead_source) LIKE '%cvent%'
GROUP BY 1, 2),

/* Create list of MA MG and CVENT opps to not include in the All Other Opps dataset we will union together */ 
mg_cvent_ma_opp_list as (
SELECT pib_opportunity_sfdc_id FROM marketing_generated_and_cvent_opps
union all 
select pib_opportunity_sfdc_id FROM mkt_associated_opps),

/*
 * Create same format dataset for Marketing Generated/Cvent Generated
 */
mg_cvent_for_union AS (
SELECT  'Current FY' AS snapshot_category,
		opp_create_date.fiscal_year AS opp_create_FY,
        opp.created_date,
        opp.win_status_flag,
	   mgco.pib_opportunity_sfdc_id,
	   psa.sfdc_product_services_id,
	   opp.opportunity_number,
	   comp.company_sfdc_id,
	   comp.company_name,
	   opp.opportunity_country,
	   opp.sales_stage,
       opp.sale_type,
       opp_close_date.fiscal_year AS opp_close_FY,
       opp.opportunity_closed_date,
       opp.closed_won_date,
       opp.opportunity_name,
       psa.forecast_month,
	   terr.territory_name AS opportunity_territory_name,
       terr.sales_region AS opportunity_sales_region,
       terr.region_code AS opportunity_region_code,
       usr.user_full_name AS opp_owner,
       psa.product_service,
       psa.product_line,
       psa.product_category,
       psa.net_one_time_amount / fx.rate as net_one_time_amount_usd,
       psa.net_recurring_amount / fx.rate * 12 as net_annualized_recurring_usd,
       opp.opportunity_amount,
       opp_contact.contact_sfdc_id AS opp_contact_sfdc_id,
       opp_contact.contact_full_name AS opp_pc_contact_name,
       opp_contact.lead_source AS opp_pc_lead_source,
       opp_contact.content_type AS opp_pc_content_type,
       opp_contact.marketing_tactic_original AS opp_pc_marketing_tactic_original,
       opp_contact.marketing_tactic_most_recent AS opp_pc_marketing_tactic_most_recent,
       opp_contact.buying_center as opp_pc_buying_center,
       mgco.opp_itemization
FROM marketing_generated_and_cvent_opps mgco
LEFT JOIN dimension_external_db.pib_opportunity_dimension opp ON opp.pib_opportunity_sfdc_id = mgco.pib_opportunity_sfdc_id
LEFT JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') psa ON opp.pib_opportunity_sfdc_id = psa.opportunity
LEFT JOIN dimension_external_db.pib_company_dimension comp ON comp.company_sfdc_id = opp.account_id 
LEFT JOIN dimension_external_db.pib_territory_dimension terr ON opp.opportunity_territory = terr.territory_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension usr ON opp.opportunity_owner = usr.user_sfdc_id
LEFT JOIN reference_external_db.fx_rates_current fx ON psa.currency_iso_code = fx.currency
LEFT JOIN date_dim AS opp_create_date ON date(opp.created_date) = opp_create_date.dat
LEFT JOIN date_dim AS opp_close_date ON date(opp.opportunity_closed_date)  = opp_close_date.dat
LEFT JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') opp_contact ON opp.primary_contact = opp_contact.contact_sfdc_id
WHERE psa.product_line <<>> 'FN/PEN'
AND opp.created_date >>= date('2022-07-01')),

/*
 * Create same format dataset for All Other Opps
 */
all_other_opps_for_union AS (
SELECT  'Current FY' AS snapshot_category,
		opp_create_date.fiscal_year AS opp_create_FY,
        opp.created_date,
        opp.win_status_flag,
	   opp.pib_opportunity_sfdc_id,
	   psa.sfdc_product_services_id,
	   opp.opportunity_number,
	   comp.company_sfdc_id,
	   comp.company_name,
	   opp.opportunity_country,
	   opp.sales_stage,
       opp.sale_type,
       opp_close_date.fiscal_year AS opp_close_FY,
       opp.opportunity_closed_date,
       opp.closed_won_date,
       opp.opportunity_name,
       psa.forecast_month,
	   terr.territory_name AS opportunity_territory_name,
       terr.sales_region AS opportunity_sales_region,
       terr.region_code AS opportunity_region_code,
       usr.user_full_name AS opp_owner,
       psa.product_service,
       psa.product_line,
       psa.product_category,
       psa.net_one_time_amount / fx.rate as net_one_time_amount_usd,
       psa.net_recurring_amount / fx.rate * 12 as net_annualized_recurring_usd,
       opp.opportunity_amount,
       opp_contact.contact_sfdc_id AS opp_contact_sfdc_id,
       opp_contact.contact_full_name AS opp_pc_contact_name,
       opp_contact.lead_source AS opp_pc_lead_source,
       opp_contact.content_type AS opp_pc_content_type,
       opp_contact.marketing_tactic_original AS opp_pc_marketing_tactic_original,
       opp_contact.marketing_tactic_most_recent AS opp_pc_marketing_tactic_most_recent,
       opp_contact.buying_center as opp_pc_buying_center,
       'All Other Opps' as opp_itemization
FROM dimension_external_db.pib_opportunity_dimension opp
LEFT JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') psa ON opp.pib_opportunity_sfdc_id = psa.opportunity
LEFT JOIN dimension_external_db.pib_company_dimension comp ON comp.company_sfdc_id = opp.account_id 
LEFT JOIN dimension_external_db.pib_territory_dimension terr ON opp.opportunity_territory = terr.territory_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension usr ON opp.opportunity_owner = usr.user_sfdc_id
LEFT JOIN reference_external_db.fx_rates_current fx ON psa.currency_iso_code = fx.currency
LEFT JOIN date_dim AS opp_create_date ON date(opp.created_date) = opp_create_date.dat
LEFT JOIN date_dim AS opp_close_date ON date(opp.opportunity_closed_date) = opp_close_date.dat
LEFT JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') opp_contact ON opp.primary_contact = opp_contact.contact_sfdc_id
WHERE psa.product_line <<>> 'FN/PEN'
AND opp.created_date >>= date('2022-07-01')
and pib_opportunity_sfdc_id not in (SELECT pib_opportunity_sfdc_id FROM mg_cvent_ma_opp_list)),

current_snapshot_set AS (
SELECT * FROM ma_data_for_union
UNION ALL
SELECT * FROM mg_cvent_for_union
UNION ALL
SELECT * FROM all_other_opps_for_union),

/* Layer in Campaign relationships to the Current set*/

/* Campaign Hierarchy & Names */

campaign_hierarchy AS (
SELECT hier.*, camp1.name AS campaign_name,
				camp1.type AS campaign_type,
				camp2.name AS ultimate_campaign_parent_name,
				camp2.type AS ultimate_campaign_parent_type,
				camp3.name AS direct_parent_campaign_name,
				camp3.type AS direct_parent_campaign_type,
				camp4.name AS direct_child_campaign_name,
				camp4.type AS direct_child_campaign_type
FROM sandbox_spb.pib_campaign_hierarchy hier
LEFT JOIN dimension_external_db.pib_campaign_dimension camp1 ON camp1.sfdc_campaign_id = hier.sfdc_campaign_id
LEFT JOIN dimension_external_db.pib_campaign_dimension camp2 ON camp2.sfdc_campaign_id = hier.ultimate_campaign_parent_id
LEFT JOIN dimension_external_db.pib_campaign_dimension camp3 ON camp3.sfdc_campaign_id = hier.direct_parent_sfdc_campaign_id
LEFT JOIN dimension_external_db.pib_campaign_dimension camp4 ON camp4.sfdc_campaign_id = hier.direct_child_sfdc_campaign_id),

ci_sub AS (
/* CAMPAIGN INFLUENCE */
SELECT  opp.pib_opportunity_sfdc_id,  camp.name, camp.TYPE AS campaign_type, camp.start_date AS campaign_start_date, 
		campaign_start_date.fiscal_year AS campaign_FY_start,
		camp.sfdc_campaign_id, 
		camp.event_date,
		/*campaign_hierarchy.ultimate_campaign_parent_name,
		campaign_hierarchy.ultimate_campaign_parent_type,
		campaign_hierarchy.direct_parent_campaign_name,
		campaign_hierarchy.direct_parent_campaign_type,
		campaign_hierarchy.direct_child_campaign_name,
		campaign_hierarchy.direct_child_campaign_type,*/
		'Campaign Influence' AS campaign_relationship
FROM dimension_external_db.pib_opportunity_dimension opp
JOIN dimension_external_db.pib_campaign_influence ci ON opp.pib_opportunity_sfdc_id = ci.opportunity_id 
JOIN dimension_external_db.pib_campaign_dimension camp ON ci.campaign_id = camp.sfdc_campaign_id
--LEFT JOIN campaign_hierarchy ON campaign_hierarchy.sfdc_campaign_id = camp.sfdc_campaign_id
LEFT JOIN date_dim AS campaign_start_date ON date(camp.start_date) = campaign_start_date.dat),

pc_sub AS (
/* Primary contact */
SELECT opp.pib_opportunity_sfdc_id,  camp.name, camp.TYPE AS campaign_type, camp.start_date AS campaign_start_date, 
		campaign_start_date.fiscal_year AS campaign_FY_start,
		camp.sfdc_campaign_id, 
		camp.event_date,
		/*campaign_hierarchy.ultimate_campaign_parent_name,
		campaign_hierarchy.ultimate_campaign_parent_type,
		campaign_hierarchy.direct_parent_campaign_name,
		campaign_hierarchy.direct_parent_campaign_type,
		campaign_hierarchy.direct_child_campaign_name,
		campaign_hierarchy.direct_child_campaign_type,*/
		'Primary Contact' AS campaign_relationship
FROM dimension_external_db.pib_opportunity_dimension opp
JOIN dimension_external_db.pib_contact_dimension con ON opp.primary_contact = con.contact_sfdc_id 
JOIN dimension_external_db.pib_campaign_member_dimension camp_mem ON con.contact_sfdc_id = camp_mem.contact_id 
JOIN dimension_external_db.pib_campaign_dimension camp ON camp_mem.campaign_id = camp.sfdc_campaign_id
--LEFT JOIN campaign_hierarchy ON campaign_hierarchy.sfdc_campaign_id = camp.sfdc_campaign_id
LEFT JOIN date_dim AS campaign_start_date ON date(camp.start_date) = campaign_start_date.dat),

camp_opp_relationships AS
(SELECT * FROM ci_sub
UNION ALL
SELECT * FROM pc_sub),
	  	
current_snapshot_set_campaigns AS (
SELECT css.*, cor.name AS campaign_name,
		cor.sfdc_campaign_id,
		/*cor.campaign_type,
		cor.campaign_start_date,
		cor.campaign_FY_start,
		cor.event_date,
		cor.ultimate_campaign_parent_name,
		cor.ultimate_campaign_parent_type,
		cor.direct_parent_campaign_name,
		cor.direct_parent_campaign_type,
		cor.direct_child_campaign_name,
		cor.direct_child_campaign_type,*/
		cor.campaign_relationship 
		FROM current_snapshot_set css
LEFT JOIN camp_opp_relationships cor ON cor.pib_opportunity_sfdc_id = css.pib_opportunity_sfdc_id )
, 

campaigns AS (
SELECT  camp.name, 
		camp.TYPE AS campaign_type, 
		camp.start_date AS campaign_start_date, 
		campaign_start_date.fiscal_year AS campaign_FY_start,
		camp.sfdc_campaign_id, 
		camp.event_date,
		/*campaign_hierarchy.ultimate_campaign_parent_name,
		campaign_hierarchy.ultimate_campaign_parent_type,
		campaign_hierarchy.direct_parent_campaign_name,
		campaign_hierarchy.direct_parent_campaign_type,
		campaign_hierarchy.direct_child_campaign_name,
		campaign_hierarchy.direct_child_campaign_type,*/
		'Campaign Influence' AS campaign_relationship

FROM dimension_external_db.pib_campaign_dimension camp
LEFT JOIN date_dim AS campaign_start_date ON date(camp.start_date) = campaign_start_date.dat

)
-- NEED TO LINK THE REMAINING TO CAMPAIGN DIMENSION. CURRENT CAMP_RELATIONSHIPS NOT CAPTURING GLOBAL CAMPAIGNS ADD PART FOR GLOBAL IN CAMP_OPP_RELATIONSHIPS
SELECT distinct 
snapshot_category,
opp_create_FY,
created_date,
win_status_flag,
cssc.pib_opportunity_sfdc_id,
sfdc_product_services_id,
opportunity_number,
company_sfdc_id,
company_name,
opportunity_country,
sales_stage,
sale_type,
opp_close_FY,
opportunity_closed_date,
closed_won_date,
opportunity_name,
forecast_month,
opportunity_territory_name,
opportunity_sales_region,
opportunity_region_code,
opp_owner,
product_service,
product_line,
product_category,
net_one_time_amount_usd,
net_annualized_recurring_usd,
opportunity_amount,
opp_contact_sfdc_id,
opp_pc_contact_name,
opp_pc_lead_source,
opp_pc_content_type,
opp_pc_marketing_tactic_original,
opp_pc_marketing_tactic_most_recent,
opp_pc_buying_center,
opp_itemization,
hier.campaign_name campaign_name,
hier.sfdc_campaign_id sfdc_campaign_id,
cor.campaign_relationship,
COALESCE(hier.campaign_type, camp.campaign_type) campaign_type,
COALESCE(camp.campaign_start_date, cor.campaign_start_date) campaign_start_date,
COALESCE(camp.campaign_FY_start, cor.campaign_FY_start) campaign_FY_start,
COALESCE(camp.event_date, cor.event_date) event_date,
CASE when hier.campaign_name LIKE '%APAC%' THEN 'APAC' when hier.campaign_name LIKE '%EMEA%' THEN 'EMEA' 
	WHEN hier.campaign_name LIKE '%AME%' THEN 'AME'
END AS campaign_region,
coalesce(costs.event_cost, gsc.cost) Cost,
ultimate_campaign_parent_name,
ultimate_campaign_parent_type,
direct_parent_campaign_name,
direct_parent_campaign_type,
direct_child_campaign_name,
direct_child_campaign_type
FROM campaign_hierarchy hier
LEFT JOIN (select sfdc_campaign_id, event_cost from dimension_external_db.pib_campaign_dimension) costs on  costs.sfdc_campaign_id =hier.sfdc_campaign_id 
LEFT JOIN google_sheets_db.event_campaign_children gsc on  gsc.sfdc_campaign_id =hier.sfdc_campaign_id 
LEFT JOIN current_snapshot_set_campaigns cssc ON cssc.sfdc_campaign_id = hier.sfdc_campaign_id
LEFT JOIN camp_opp_relationships cor ON cor.sfdc_campaign_id = hier.sfdc_campaign_id 
LEFT JOIN campaigns camp ON hier.sfdc_campaign_id = camp.sfdc_campaign_id
where hier.campaign_name not like '%OPIS%'                                                                                
