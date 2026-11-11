-- Dashboard   : "B2B R&C SEM Dashboard"  [B2B / B2B Marketing]
-- Data source : "Marketing Paid Media Dataset" = published source "B2B Marketing Paid Media Dataset"  [B2B / B2B Marketing / Datasources]
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
	   comp.company_industry,
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
	   comp.company_industry,
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
	   comp.company_industry,
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
		cor.campaign_type,
		cor.campaign_start_date,
		cor.campaign_FY_start,
		/*cor.ultimate_campaign_parent_name,
		cor.ultimate_campaign_parent_type,
		cor.direct_parent_campaign_name,
		cor.direct_parent_campaign_type,
		cor.direct_child_campaign_name,
		cor.direct_child_campaign_type,*/
		cor.campaign_relationship FROM current_snapshot_set css
LEFT JOIN camp_opp_relationships cor ON cor.pib_opportunity_sfdc_id = css.pib_opportunity_sfdc_id ),

/* Campaign List & Info Relevant to Paid Media*/
paid_media_campaigns AS (
SELECT *,
		CASE WHEN bing_campaign = TRUE THEN 'Bing' WHEN baidu_campaign = TRUE THEN 'Baidu'  WHEN google_campaign = TRUE THEN 'Google'
			ELSE NULL END AS campaign_category
FROM sandbox_spb.paid_media_campaigns),

main AS (
SELECT cssc.*, 
(case when substring(opportunity_territory_name,1,3) = 'AME' 
or opportunity_territory_name = 'GAT AMEX'
or opportunity_territory_name = 'GAT BCG'
or opportunity_territory_name = 'GAT BOA'
or opportunity_territory_name = 'GAT BOOZ ALLEN'
or opportunity_territory_name = 'GAT CITIGROUP'
or opportunity_territory_name = 'GAT D & T'
or opportunity_territory_name = 'GAT Goldman'
or opportunity_territory_name = 'GAT JP Morgan'
or opportunity_territory_name = 'GAT KPMG'
or opportunity_territory_name = 'GAT McKinsey'
or opportunity_territory_name = 'GAT MITSUBISHI'
or opportunity_territory_name = 'GAT MMC'
or opportunity_territory_name = 'GAT Morgan Stanley'
or opportunity_territory_name = 'GAT NEWS CORP'
or opportunity_territory_name = 'GAT PWC'
or opportunity_territory_name = 'GAT WPP'
or opportunity_territory_name = 'GAT BARCLAYS'
or opportunity_territory_name = 'GAT X'
then 'AME'
when substring(opportunity_territory_name,1,4) = 'EMEA' 
or opportunity_territory_name = 'GAT ACCENTURE'
or opportunity_territory_name = 'GAT Bain'
or opportunity_territory_name = 'GAT BP AMOCO'
or opportunity_territory_name = 'GAT Credit Suisse'
or opportunity_territory_name = 'GAT Deutsche'
or opportunity_territory_name = 'GAT EY'
or opportunity_territory_name = 'GAT HSBC'
or opportunity_territory_name = 'GAT NOMURA'
or opportunity_territory_name = 'GAT SUMITOMO'
or opportunity_territory_name = 'GAT UBS'
or opportunity_territory_name = 'R&C Partners - EMEA'
or opportunity_territory_name = 'SAT UBS'
or opportunity_territory_name = 'UKIA UK'
then 'EMEA'
when substring(opportunity_territory_name,1,2) = 'AP' then 'APAC'
when opportunity_territory_name like 'Pro%'
or opportunity_territory_name like 'WSJ Pro%'
or opportunity_territory_name like 'CTSE%'
or opportunity_territory_name like 'C-Suite%'
or opportunity_territory_name like 'Corporate%'
then 'WSJ'
when opportunity_territory_name like 'OPIS%'
then 'OPIS'
when opportunity_territory_name like 'WSJ Corporate%'
or opportunity_territory_name like 'WSJ BD%'
or opportunity_territory_name like 'BD%'
or opportunity_territory_name like 'CP%'
or opportunity_territory_name = 'Proquest'
then 'PAL'
else 'Other'
end) as geo_region,
		pmc.campaign_name AS campaign_name_main, 
		pmc.sfdc_campaign_id AS sfdc_campaign_id_main, 
		pmc.campaign_type AS campaign_type_main, 
		pmc.campaign_category AS campaign_category_main,
		campaign_hierarchy.ultimate_campaign_parent_name,
		campaign_hierarchy.ultimate_campaign_parent_type,
		campaign_hierarchy.direct_parent_campaign_name,
		campaign_hierarchy.direct_parent_campaign_type,
		campaign_hierarchy.direct_child_campaign_name,
		campaign_hierarchy.direct_child_campaign_type
FROM paid_media_campaigns pmc
LEFT JOIN current_snapshot_set_campaigns cssc ON cssc.sfdc_campaign_id = pmc.sfdc_campaign_id
LEFT JOIN campaign_hierarchy ON campaign_hierarchy.sfdc_campaign_id = pmc.sfdc_campaign_id),

dataset (region, search_engine) AS (SELECT * FROM UNNEST(ARRAY['AME', 'EMEA', 'APAC']) AS region
CROSS JOIN (SELECT * FROM UNNEST(ARRAY['Google', 'Baidu', 'Bing']) AS search_engine)),

remove_irrelevant AS (
SELECT *,
CASE WHEN region = 'AME' AND search_engine = 'Baidu' THEN FALSE 
	 WHEN region = 'EMEA' AND search_engine = 'Baidu' THEN FALSE 
		ELSE TRUE END AS keep_row
FROM dataset),

faux_rows AS ( 
SELECT  DISTINCT NULL AS snapshot_category,
		NULL AS opp_create_FY,
        NULL AS created_date,
        NULL AS win_status_flag,
	   NULL AS pib_opportunity_sfdc_id,
	   NULL AS sfdc_product_services_id,
	   NULL AS opportunity_number,
	   NULL AS company_sfdc_id,
	   NULL AS company_name,
	   NULL AS company_industry,
	   NULL AS opportunity_country,
	   NULL AS sales_stage,
       NULL AS sale_type,
       NULL AS  opp_close_FY,
       NULL AS opportunity_closed_date,
       NULL AS closed_won_date,
       NULL AS opportunity_name,
       NULL AS forecast_month,
	   NULL AS opportunity_territory_name,
       NULL AS opportunity_sales_region,
       NULL AS opportunity_region_code,
       NULL AS  opp_owner,
       NULL AS product_service,
       NULL AS product_line,
       NULL AS product_category,
       NULL AS net_one_time_amount_usd,
       NULL AS net_annualized_recurring_usd,
       NULL AS opportunity_amount,
       NULL AS opp_contact_sfdc_id,
       NULL AS pp_pc_contact_name,
       NULL AS opp_pc_lead_source,
       NULL AS opp_pc_content_type,
       NULL AS opp_pc_marketing_tactic_original,
       NULL AS opp_pc_marketing_tactic_most_recent,
       NULL AS  opp_pc_buying_center,
       NULL as opp_itemization,
       NULL AS campaign_name, 
		NULL AS sfdc_campaign_id,
		NULL AS campaign_type,
		NULL AS campaign_start_date,
		NULL AS campaign_FY_start,
		NULL AS campaign_relationship,
       region AS geo_region,
       NULL AS campaign_name_main, 
       NULL AS sfdc_campaign_id_main, 
       NULL AS campaign_type_main,
       search_engine AS campaign_category_main,
		NULL AS ultimate_campaign_parent_name,
		NULL AS ultimate_campaign_parent_type,
		NULL AS direct_parent_campaign_name,
		NULL AS direct_parent_campaign_type,
		NULL AS direct_child_campaign_name,
		NULL AS direct_child_campaign_type
FROM remove_irrelevant WHERE keep_row = TRUE)

SELECT * FROM main
UNION ALL
SELECT * FROM faux_rows                            
