-- Published data source : "Sales Velocity Dataset"  [B2B / B2B Sales / Sales Leadership & Operations / Datasources]
-- Relation    : Custom SQL "Sales Analytics Dataset"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH ahf as (
SELECT
	*
FROM
	fact_external_db.pib_account_hierarchy_fact),

opp as (
SELECT
	DISTINCT opportunity_name,
	opportunity_number,
	billing_account,
	sale_type,
	source_type,
	sales_stage,
	pipeline_category,
	probability_percentage,
	opportunity_owner,
	opportunity_territory,
	annualized_opportunity_revenue,
	created_date,
	open_date,
	closed_won_date,
	opportunity_effective_date,
	compelling_reasons_to_buy,
	loss_reason_code,
	primary_campaign_source,
	account_country,
	fiscal_year,
	fiscal_quarter,
	pib_opportunity_sfdc_id,
	primary_contact,
	closed_flag,
	win_status_flag,
    opportunity_closed_date,
	account_state
FROM
	dimension_external_db.pib_opportunity_dimension
WHERE
	status_flag <<>> 'DELETE'
	AND sale_type in ('Upsell - Existing Contract',
	'New Contract/Existing Customer',
	'Rev Increase Existing Contract',
	'Upsell - New Contract',
	'New To Company')
	AND (created_date >>= date('2015-07-01')
             OR CAST(opportunity_closed_date AS date) >>= date('2015-07-01'))),
comp as (
SELECT DISTINCT
	company_sfdc_id,
	company_name,
	company_industry,
	parent_sfdc_id,
	ntc_prospect,
        ntc_owner,
	sales_campaign_s,
        r_c_rating,
        mm_quadrant
FROM
	dimension_external_db.pib_company_dimension
WHERE
	status_flag <<>> 'DELETE'),
	
corp AS (
SELECT DISTINCT corporate_name,
		corporate_sfdc_id
FROM dimension_external_db.pib_corporate_dimension 
),

camp_russian_sanctions AS (
SELECT opportunity_id, camp.name 
FROM dimension_external_db.pib_campaign_influence ci
INNER JOIN dimension_external_db.pib_campaign_dimension camp ON ci.campaign_id = camp.sfdc_campaign_id 
WHERE camp.name = 'Russian Sanctions'
GROUP BY 1, 2),

psd as (
SELECT
	*
FROM
	dimension_external_db.pib_product_services_dimension
WHERE
	status_flag <<>> 'DELETE'),
	
camp AS (
SELECT DISTINCT SUBSTRING(sfdc_campaign_id, 1, 15) sfdc_campaign_id, name
FROM dimension_external_db.pib_campaign_dimension
),

usr as (
SELECT DISTINCT
	user_sfdc_id,
	user_full_name
FROM
	dimension_external_db.pib_user_dimension),
Terr_Dim as (
select
	territory_sfdc_id,
	territory_name,
	territory_owner,
	territory_roll_up,
	regional_sales_director,
	region_code
from
	dimension_external_db.pib_territory_dimension),
fx_Rates as (
SELECT
	*
FROM
	reference_external_db.fx_rates_current),
Terr_RSD as (
select
	user_sfdc_id,
	user_full_name
from
	dimension_external_db.pib_user_dimension),
prod_master as (
SELECT DISTINCT 
  bu,
  sfdc_product,
  master_product,
  product_line
from 
       reference_external_db.pib_product_dimension),
       
new_prod_master AS (
	SELECT
	product_service
	, product_line
	, CASE
	    WHEN product_line IN
	        ('Factiva'
	        , 'Curation Services'
	        , 'DJX')
	        THEN 'K&I'
	    WHEN product_line IN
	        ('Risk & Compliance')
	        THEN 'R&C'
	    WHEN product_line IN
	        ('Newswires')
	        THEN 'NAD'
	    ELSE UPPER(product_line)
	  END AS bu
	, 'SFDC Product Service Attributes' AS lookup_source
	FROM dimension_external_db.pib_product_service_attributes
	
	UNION ALL
	
	SELECT
	sfdc_product AS product_service
	, product_line
	, bu
	, 'Legacy Product Dimension' AS lookup_source
	FROM reference_external_db.pib_product_dimension
	WHERE sfdc_product NOT IN (SELECT product_service FROM dimension_external_db.pib_product_service_attributes)
	AND sfdc_product IS NOT NULL),
       
contact AS (
SELECT distinct buying_center, contact_sfdc_id 
FROM dimension_external_db.pib_contact_dimension 
),

date_dim as (
select date(full_date) AS dat, 
	   DATE_ADD('day', -1, date(full_date)) AS dat_adj,
	   week_number_in_fiscal_year as fiscal_week, 
	   month_number_in_fiscal_year as fiscal_month, 
	   fiscal_quarter_name AS fiscal_quarter,
	   concat(fiscal_month_name, CAST(fiscal_year AS varchar)) fiscal_month_name_and_yr,
	   CAST(fiscal_year AS varchar) AS fiscal_year 
from reference_external_db.date_dimension
where full_date >>= date('2012-07-01')
and full_date <<= date_add('day', 400, current_date)),

date_tbl as (
SELECT  fiscal_week,
		fiscal_month_name_and_yr,
        min(dat_adj) week_start
FROM date_dim
GROUP BY 1, 2),

-- INCLUDED DUE TO 1:N OPPORTUNITY TO LEAD
leads AS (
    SELECT
        converted_opportunity_id,
        lead_sfdc_id,
		lead_source,
        ROW_NUMBER() OVER (
            PARTITION BY converted_opportunity_id 
            ORDER BY last_modified_date ASC
        ) as rn
    FROM 
        dimension_external_db.pib_leads_dimension
),

earliest_lead AS (
SELECT
    converted_opportunity_id,
    lead_sfdc_id,
	lead_source
FROM
    leads
WHERE
    rn = 1),
---- END OF LEAD

marketing_qualified_leads as (
  SELECT lead_sfdc_id, MIN(last_modified_date) as marketing_qualified_date, min(cycle_date) as marketing_qualified_cycle_date
  FROM (
    SELECT DISTINCT web_form_name, region, product_of_interest, marketing_tactic_original, marketing_tactic_most_recent, marketing_qualified_flag, lead_status, lead_source, lead_sfdc_id, lead_score, lead_name, lead_owner,
           lead_created_date, lead_country, lead_converted_flag, lead_company, last_modified_date, content_type, buying_center, cycle_date
    FROM dimension_external_db.pib_leads_dimension_history
    WHERE (lead_status IN ('Untouched','Working','Qualified','Future Follow-up','Converted to Opportunity','Converted to Contact Only',
                           'Disqualified','Return to Marketing','Unqualified')
       OR converted_contact_id IS NOT NULL OR converted_contact_id != ''
       OR converted_opportunity_id IS NOT NULL OR converted_opportunity_id != ''))
  GROUP BY lead_sfdc_id)


	SELECT
		DISTINCT opp.opportunity_name,
		opp.closed_flag,
		opp.opportunity_number,
		opp.pib_opportunity_sfdc_id,
		opp.win_status_flag,
		comp.company_name,
		comp.ntc_prospect,
                comp.r_c_rating,
                comp.mm_quadrant,
                usrc.user_full_name AS ntc_owner,
		comp.sales_campaign_s,
		corp.corporate_name,
		usr.user_full_name as opp_owner,
		Terr_Dim.territory_name,
		opp.sale_type,
		opp.source_type,
		opp.sales_stage,
		opp.pipeline_category,
		opp.probability_percentage,
		opp.created_date,
		opp.open_date,
		opp.closed_won_date,
		opp.opportunity_effective_date,
		opp.compelling_reasons_to_buy,
		opp.loss_reason_code,
		camp.name campaign_name,
		CASE WHEN crs.name = 'Russian Sanctions' THEN TRUE ELSE FALSE END AS Russian_Sanctions_Assn,
		opp.account_country as opportunity_country,
		COALESCE(comp.company_industry, 'Other') company_industry, 
		opp.fiscal_year,
		opp.fiscal_quarter,
		opp.account_state,
		psd.sfdc_product_services_id, -- Added to make distinction
		psd.forecast_month,
		psd.product_line,
		psd.one_time_charge,
		psd.delivery_product,
		psd.delivery_channel_s,
		psd.delivery_channel,
		COALESCE(psd.product_service, 'No Product Service') product_service,
		new_prod_master.bu business_unit,
		new_prod_master.product_line master_product_line,
		/*prod_master.bu business_unit,
		prod_master.master_product,
		prod_master.product_line master_product_line,*/
		psd.product_category,
		-- NEW CHANGE
		IF(psd.one_time_charge, 0, COALESCE(NULLIF(psd.net_recurring_amount, 0), psd.price_anual, 0)) AS net_recurring_amount,

		-- This will become the source for Tableau's 'opportunity_annualized_net_oneTime_amount'
		IF(psd.one_time_charge, COALESCE(NULLIF(psd.price_anual, 0), psd.net_one_time_amount, 0), 0) AS net_one_time_amount,
		-- END OF NEW CHANGE
		psd.currency_iso_code,
		contact.buying_center,
		COALESCE(rate, 1) rate,
		Terr_RSD.user_full_name RSD,
		terr_dim.region_code, 
		ld.lead_source,
		mqls.marketing_qualified_date,
                opp.opportunity_closed_date,
                ddclose.fiscal_week AS fiscal_week_close,
                ddclose.fiscal_month AS fiscal_month_close,
                ddclose.fiscal_year AS fiscal_year_close,
                ddclose.fiscal_quarter AS fiscal_quarter_close,
                ddcreate.fiscal_week AS fiscal_week_create,
                ddcreate.fiscal_month AS fiscal_month_create,
                ddcreate.fiscal_year AS fiscal_year_create,
                ddcreate.fiscal_quarter AS fiscal_quarter_create
	FROM
		opp
	INNER JOIN ahf ON opp.pib_opportunity_sfdc_id = ahf.pib_opportunity_sfdc_id
	LEFT JOIN comp ON ahf.company_sfdc_id = comp.company_sfdc_id
	LEFT JOIN psd ON opp.pib_opportunity_sfdc_id = psd.opportunity
	INNER JOIN usr ON opp.opportunity_owner = usr.user_sfdc_id
	LEFT JOIN usr AS usrc ON comp.ntc_owner = usrc.user_sfdc_id
        INNER JOIN Terr_Dim ON opp.opportunity_territory = Terr_Dim.territory_sfdc_id
	LEFT JOIN camp ON opp.primary_campaign_source = camp.sfdc_campaign_id
	LEFT JOIN fx_Rates ON psd.currency_iso_code = fx_Rates.currency
	/*LEFT JOIN prod_master ON psd.product_service = prod_master.sfdc_product*/
    LEFT JOIN new_prod_master ON psd.product_service = new_prod_master.product_service
	LEFT JOIN Terr_RSD ON Terr_Dim.regional_sales_director = Terr_RSD.user_sfdc_id
	LEFT JOIN contact ON contact.contact_sfdc_id = opp.primary_contact
	LEFT JOIN date_dim AS ddclose ON date(opp.opportunity_closed_date) = ddclose.dat
	LEFT JOIN date_dim AS ddcreate ON date(opp.created_date) = ddcreate.dat
	LEFT JOIN corp ON corp.corporate_sfdc_id = comp.parent_sfdc_id
	LEFT JOIN camp_russian_sanctions crs ON crs.opportunity_id = opp.pib_opportunity_sfdc_id
	--LEFT JOIN dimension_external_db.pib_leads_dimension ld ON ld.converted_opportunity_id = opp.pib_opportunity_sfdc_id
	LEFT JOIN earliest_lead ld ON ld.converted_opportunity_id = opp.pib_opportunity_sfdc_id
	LEFT JOIN marketing_qualified_leads mqls ON ld.lead_sfdc_id = mqls.lead_sfdc_id
	WHERE company_name not in ('Factiva xx', 'ZZZ Internal Factiva Accounts-Admin Portal')
		and lower(territory_name) not like '%fnpen%'
		and lower(territory_name) not like '%proquest%'
	        and lower(territory_name) not like '%bd%'
	        and lower(territory_name) not like '%media sales%'
		and lower(opportunity_name) not like '%dummy%'
		and lower(opportunity_name) not like '%test%'
