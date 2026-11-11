-- Dashboard   : "small deal analysis"  [B2B / B2B Pricing / ARCHIVE / Sandbox Folder]
-- Data source : "Opp Pricing Dataset CDP" (embedded in the workbook)
-- Relation    : Custom SQL "Opportunity Dataset"
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
	opportunity_country,
	fiscal_year,
	fiscal_quarter,
	pib_opportunity_sfdc_id,
	primary_contact,
	closed_flag,
	win_status_flag,
        trial_flag,
	finance_validated_date,
        opportunity_closed_date,
        in_forecast,
        autorenewal, 
		renewal_term_months, 
term_months,
		max_renewals, 
		clm_term_months_label, 
		clm_renewal_term_months_label, 
		payment_terms_days,
		billing_frequency ,
		billing_frequency_default,
		contract_term_end_date,
		contract_effective_date,
		clm_third_party_contractor,
		clm_third_party_integrator,
		contact_name,
		contact_email,
		owner_full_name,
		owner_email,
		deal_amount,
		deal_amount_usd,
		deal_opportunity,
		other_exceptions
FROM
	dimension_external_db.pib_opportunity_dimension
WHERE
	status_flag <<>> 'DELETE'
	AND (opportunity_effective_date >>= date('2021-01-01'))),
	
comp as (
SELECT DISTINCT
	company_sfdc_id,
	company_name,
	company_industry,
	parent_sfdc_id,
	ntc_prospect,
        ntc_owner,
	sales_campaign_s,
        r_c_proposition,
        third_party_partner_flag,
        relationship_type
FROM
	dimension_external_db.pib_company_dimension
WHERE
	status_flag <<>> 'DELETE'),
	
corp AS (
SELECT DISTINCT corporate_name,
		corporate_sfdc_id
FROM dimension_external_db.pib_corporate_dimension 
),

bad AS (
SELECT DISTINCT salesforce_billing_account_id, cibs_billing_account_id, salesforce_partner_flag
FROM dimension_external_db.pib_billing_account_dimension ),

/*
* Take a simplified version of the Pricing Team Rate Card Table, removing unneeded columns for the tm1_inscope table
*/ 

rate_card_simplified AS (
SELECT DISTINCT product_name, rate_card_valid_from, rate_card_valid_to, min_order_quantity, max_order_quantity
FROM google_sheets_db.master_rate_card_table_cp_datateam ),

rate_card_simplified_current AS (
SELECT DISTINCT product_name, min_order_quantity, max_order_quantity
FROM google_sheets_db.master_rate_card_table_cp_datateam
WHERE rate_card_valid_to >> date('9999-01-01') ),

psd as (
SELECT
	psd.*,
	CASE WHEN rc.min_order_quantity >> coalesce(num_seats_or_copies, 1)  THEN rc.min_order_quantity 
		 WHEN rc.max_order_quantity << coalesce(num_seats_or_copies, 1) THEN rc.max_order_quantity
		 ELSE coalesce(num_seats_or_copies, 1) END AS num_seats_or_copies_minmaxadj
FROM
	dimension_external_db.pib_product_services_dimension psd
LEFT JOIN dimension_external_db.pib_opportunity_dimension opp ON opp.pib_opportunity_sfdc_id = psd.opportunity
LEFT JOIN dimension_external_db.pib_product_service_attributes psa ON psa.product_service = psd.product_service
LEFT JOIN rate_card_simplified rc ON rc.product_name = psa.rate_card_name 
								AND opp.opportunity_effective_date BETWEEN rc.rate_card_valid_from AND rc.rate_card_valid_to
WHERE
	psd.status_flag <<>> 'DELETE'),
	
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
and full_date <<= date_add('day', 1500, current_date)),

date_tbl as (
SELECT  fiscal_week,
		fiscal_month_name_and_yr,
        min(dat_adj) week_start
FROM date_dim
GROUP BY 1, 2),

case_core AS (
SELECT opportunity, product_service, case_record_id, description_commercial, category, "type" AS case_type, price_discount_premium, number_of_months, created_date 
FROM dimension_external_db.pib_customer_service_case_dimension 
WHERE opportunity IS NOT NULL 
AND product_service IS NOT null
group BY 1, 2, 3, 4, 5, 6, 7, 8, 9),

case_ordered AS (
SELECT opportunity, product_service, case_record_id, description_commercial, created_date,
		 ROW_NUMBER() OVER (PARTITION BY opportunity ORDER BY created_date) rnk
FROM case_core
GROUP BY 1, 2, 3, 4, 5
ORDER BY opportunity),

co1 AS (
SELECT *
FROM case_ordered
WHERE rnk = 1),

co2 AS (
SELECT *
FROM case_ordered
WHERE rnk = 2),

co3 AS (
SELECT *
FROM case_ordered
WHERE rnk = 3),

co4 AS (
SELECT *
FROM case_ordered
WHERE rnk = 4),

case_agg AS (
SELECT case_core.opportunity, case_core.product_service, opp.opportunity_number, opp.opportunity_name, 
		COALESCE(NULL, co1.description_commercial) AS desc1,
	    COALESCE(NULL, co2.description_commercial) AS desc2,
	    COALESCE(NULL, co3.description_commercial) AS desc3,
	    COALESCE(NULL, co4.description_commercial) AS desc4,
		max(CASE WHEN case_type = 'Price Increase' 
				 THEN category ELSE null END) AS price_increase_cat,
	    max(CASE WHEN case_type = 'Price Increase'
				 THEN price_discount_premium
				 ELSE 0 end) AS price_inc_amt,
		max(CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) = 'price discounts' 
				 THEN price_discount_premium
				 ELSE 0 end) AS price_disc_amt,
		max(CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) = 'emerging markets' 
				 THEN price_discount_premium
				 ELSE 0 end) AS emerging_mkt_amt,
	    max(CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) = 'above rate card' 
				 THEN price_discount_premium
				 ELSE 0 end) AS above_rc_amt,
		max(CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) = 'multiple year deal' 
				 THEN price_discount_premium
				 ELSE 0 end) AS multi_yr_amt,
		max(CASE WHEN case_type = 'Pricing/Discounting'
				 THEN category ELSE null END) AS price_decrease_cat,
	    max(CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) NOT IN ('price discounts', 'emerging markets', 'above rate card', 'multiple year deal') 
				 THEN price_discount_premium
				 ELSE 0 end) AS other_disc_amt,
		max(CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) NOT IN ('price discounts', 'emerging markets', 'above rate card', 'multiple year deal') 
				 THEN number_of_months
				 ELSE 0 end) AS num_months,
	    count(DISTINCT CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) = 'price discounts' THEN case_core.case_record_id ELSE NULL END) AS price_disc_cases,
	    count(DISTINCT CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) = 'emerging markets' THEN case_core.case_record_id ELSE NULL END) AS emerging_mkt_cases,
	    count(DISTINCT CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) = 'above rate card' THEN case_core.case_record_id ELSE NULL END) AS above_rc_cases,
	    count(DISTINCT CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) = 'multiple year deal' THEN case_core.case_record_id ELSE NULL END) AS multi_yr_cases,
	    count(DISTINCT CASE WHEN case_type = 'Pricing/Discounting' AND lower(category) NOT IN ('price discounts', 'emerging markets', 'above rate card', 'multiple year deal') THEN case_core.case_record_id ELSE NULL END) AS other_disc_cases
FROM case_core
LEFT JOIN dimension_external_db.pib_opportunity_dimension opp ON opp.pib_opportunity_sfdc_id = case_core.opportunity
LEFT JOIN dimension_external_db.pib_product_services_dimension ps ON ps.opportunity = opp.pib_opportunity_sfdc_id
LEFT JOIN co1 ON co1.opportunity = case_core.opportunity AND co1.product_service = case_core.product_service
LEFT JOIN co2 ON co2.opportunity = case_core.opportunity AND co2.product_service = case_core.product_service
LEFT JOIN co3 ON co3.opportunity = case_core.opportunity AND co3.product_service = case_core.product_service
LEFT JOIN co4 ON co4.opportunity = case_core.opportunity AND co4.product_service = case_core.product_service
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8),

/*
* Ordered rate card table with numbered columns 
*/

rate_card AS (SELECT *, ROW_NUMBER() OVER (ORDER BY  rate_card_valid_from, product_name, volume_low ) AS row_number_col
FROM google_sheets_db.master_rate_card_table_cp_datateam), 

rate_card_current AS (SELECT *, ROW_NUMBER() OVER (ORDER BY  rate_card_valid_from, product_name, volume_low ) AS row_number_col
FROM google_sheets_db.master_rate_card_table_cp_datateam
WHERE rate_card_valid_to >> date('9999-01-01')),

/*
* Adds a Led Row column in order to identify rate card information from the actual row.
* ->> This is necessary for pricing that involves the "lagged in-between tier factor" 
*/ 

led_row_tbl AS (SELECT rate_card.*, lead(row_number_col) OVER (ORDER BY row_number_col) AS led_row
FROM rate_card),

led_row_tbl_current AS (SELECT rate_card_current.*, lead(row_number_col) OVER (ORDER BY row_number_col) AS led_row
FROM rate_card_current),

adj_rate_card AS (SELECT rate_card.*, lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor, 
                                        lag.ibt_factor_growing as lagged_ibt_factor_growing,
                                        lag.ibt_factor_mid as lagged_ibt_factor_mid,
                                        lag.ibt_factor_premium as lagged_ibt_factor_premium,
                                        lag.volume_high AS prev_tier_vol_high, 
                                        lag.monthly_price AS prev_tier_price,
                                        lag.monthly_price_premium as prev_tier_price_premium,
                                        lag.monthly_price_mid as prev_tier_price_mid,
                                        lag.monthly_price_growing as prev_tier_price_growing
FROM rate_card
LEFT JOIN led_row_tbl lag ON lag.led_row = rate_card.row_number_col),

adj_rate_card_current AS (SELECT rate_card_current.*, lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor, 
                                        lag.ibt_factor_growing as lagged_ibt_factor_growing,
                                        lag.ibt_factor_mid as lagged_ibt_factor_mid,
                                        lag.ibt_factor_premium as lagged_ibt_factor_premium,
                                        lag.volume_high AS prev_tier_vol_high, 
                                        lag.monthly_price AS prev_tier_price,
                                        lag.monthly_price_premium as prev_tier_price_premium,
                                        lag.monthly_price_mid as prev_tier_price_mid,
                                        lag.monthly_price_growing as prev_tier_price_growing
FROM rate_card_current
LEFT JOIN led_row_tbl_current lag ON lag.led_row = rate_card_current.row_number_col),

/* 
* Continued manipulation in order to get the data in a format that allows all of the necessary pricing calculations to be performed
*/ 

partial_sums AS (
SELECT rate_card.*,
	lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor,
	lag.volume_high AS prev_tier_vol_high,
	lag.monthly_price AS prev_tier_price,
	lag.monthly_price_premium as prev_tier_price_premium,
	lag.monthly_price_mid as prev_tier_price_mid,
	lag.monthly_price_growing as prev_tier_price_growing,
	/*Old logic that was patched 9/14/2023
	 * CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card.volume_high AS bigint) * rate_card.monthly_price
		ELSE CAST(rate_card.volume_high AS bigint) * rate_card.monthly_price
	END AS tier_price_contribution,*/
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card.volume_high AS bigint) * rate_card.monthly_price
		ELSE (CAST(rate_card.volume_high AS bigint) - lag.volume_high) * rate_card.monthly_price
	END AS tier_price_contribution,
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card.volume_high AS bigint) * rate_card.monthly_price_premium
		ELSE (CAST(rate_card.volume_high AS bigint) - lag.volume_high) * rate_card.monthly_price_premium
	END AS tier_price_contribution_premium,
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card.volume_high AS bigint) * rate_card.monthly_price_mid
		ELSE (CAST(rate_card.volume_high AS bigint) - lag.volume_high) * rate_card.monthly_price_mid
	END AS tier_price_contribution_mid,
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card.volume_high AS bigint) * rate_card.monthly_price_growing
		ELSE (CAST(rate_card.volume_high AS bigint) - lag.volume_high) * rate_card.monthly_price_growing
	END AS tier_price_contribution_growing
FROM rate_card
	LEFT JOIN led_row_tbl lag ON lag.led_row = rate_card.row_number_col
WHERE rate_card.rate_card_type = 'D'),

partial_sums_current AS (
SELECT rate_card_current.*,
	lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor,
	lag.volume_high AS prev_tier_vol_high,
	lag.monthly_price AS prev_tier_price,
	lag.monthly_price_premium as prev_tier_price_premium,
	lag.monthly_price_mid as prev_tier_price_mid,
	lag.monthly_price_growing as prev_tier_price_growing,
	/*Old logic that was patched 9/14/2023
	 * CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price
		ELSE CAST(rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price
	END AS tier_price_contribution,*/
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price
		ELSE (CAST(rate_card_current.volume_high AS bigint) - lag.volume_high) * rate_card_current.monthly_price
	END AS tier_price_contribution,
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price_premium
		ELSE (CAST(rate_card_current.volume_high AS bigint) - lag.volume_high) * rate_card_current.monthly_price_premium
	END AS tier_price_contribution_premium,
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price_mid
		ELSE (CAST(rate_card_current.volume_high AS bigint) - lag.volume_high) * rate_card_current.monthly_price_mid
	END AS tier_price_contribution_mid,
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price_growing
		ELSE (CAST(rate_card_current.volume_high AS bigint) - lag.volume_high) * rate_card_current.monthly_price_growing
	END AS tier_price_contribution_growing
FROM rate_card_current
	LEFT JOIN led_row_tbl_current lag ON lag.led_row = rate_card_current.row_number_col
WHERE rate_card_current.rate_card_type = 'D'),

cumulative_sums AS (
SELECT partial_sums.*, sum(tier_price_contribution) OVER (PARTITION BY rate_card_valid_from, product_name
															 ORDER BY row_number_col) AS cumulative_tier_price_contribution,
					   sum(tier_price_contribution_premium) OVER (PARTITION BY rate_card_valid_from, product_name
															 ORDER BY row_number_col) AS cumulative_tier_price_contribution_premium,
					   sum(tier_price_contribution_mid) OVER (PARTITION BY rate_card_valid_from, product_name
															 ORDER BY row_number_col) AS cumulative_tier_price_contribution_mid,
					   sum(tier_price_contribution_growing) OVER (PARTITION BY rate_card_valid_from, product_name
															 ORDER BY row_number_col) AS cumulative_tier_price_contribution_growing
FROM partial_sums
ORDER BY row_number_col),

cumulative_sums_current AS (
SELECT partial_sums_current.*, sum(tier_price_contribution) OVER (PARTITION BY rate_card_valid_from, product_name
															 ORDER BY row_number_col) AS cumulative_tier_price_contribution,
							   sum(tier_price_contribution_premium) OVER (PARTITION BY rate_card_valid_from, product_name
															 ORDER BY row_number_col) AS cumulative_tier_price_contribution_premium,
        					   sum(tier_price_contribution_mid) OVER (PARTITION BY rate_card_valid_from, product_name
        															 ORDER BY row_number_col) AS cumulative_tier_price_contribution_mid,
        					   sum(tier_price_contribution_growing) OVER (PARTITION BY rate_card_valid_from, product_name
        															 ORDER BY row_number_col) AS cumulative_tier_price_contribution_growing
FROM partial_sums_current
ORDER BY row_number_col),

final_cumulative_sums AS (
SELECT cumulative_sums.*, 
	   lag(cumulative_tier_price_contribution) OVER (ORDER BY row_number_col) AS prev_row_contribution,
	   lag(cumulative_tier_price_contribution_premium) OVER (ORDER BY row_number_col) AS prev_row_contribution_premium,
	   lag(cumulative_tier_price_contribution_mid) OVER (ORDER BY row_number_col) AS prev_row_contribution_mid,
	   lag(cumulative_tier_price_contribution_growing) OVER (ORDER BY row_number_col) AS prev_row_contribution_growing
FROM cumulative_sums),

final_cumulative_sums_current AS (
SELECT cumulative_sums_current.*, 
	   lag(cumulative_tier_price_contribution) OVER (ORDER BY row_number_col) AS prev_row_contribution_current,
	   lag(cumulative_tier_price_contribution_premium) OVER (ORDER BY row_number_col) AS prev_row_contribution_current_premium,
	   lag(cumulative_tier_price_contribution_mid) OVER (ORDER BY row_number_col) AS prev_row_contribution_current_mid,
	   lag(cumulative_tier_price_contribution_growing) OVER (ORDER BY row_number_col) AS prev_row_contribution_current_growing
FROM cumulative_sums_current),


core AS (SELECT
	DISTINCT opp.opportunity_name,
	opp.closed_flag,
        opp.trial_flag,
	opp.opportunity_number,
	opp.pib_opportunity_sfdc_id,
	psd.sfdc_product_services_id,
	opp.win_status_flag,
	bad.cibs_billing_account_id,
        comp.third_party_partner_flag,
        comp.relationship_type,
	comp.company_name,
        comp.r_c_proposition,
	comp.company_sfdc_id,
	comp.ntc_prospect,
            usrc.user_full_name AS ntc_owner,
	comp.sales_campaign_s,
	corp.corporate_name,
	corp.corporate_sfdc_id,
	usr.user_full_name as opp_owner,
	Terr_Dim.territory_name,
	Terr_Dim.territory_roll_up,
	opp.sale_type,
	opp.source_type,
	opp.sales_stage,
	opp.pipeline_category,
	opp.probability_percentage,
	opp.created_date,
	opp.open_date,
	opp.closed_won_date,
        opp.opportunity_closed_date,
	opp.opportunity_effective_date,
	opp.finance_validated_date,
	opp.compelling_reasons_to_buy,
	opp.loss_reason_code,
	camp.name campaign_name,
	opp.opportunity_country,
	cntry.country_segment,
	COALESCE(comp.company_industry, 'Other') company_industry, 
	opp.fiscal_year,
	opp.fiscal_quarter,
	opp.in_forecast,
	psd.forecast_month,
	psd.product_line,
	psd.one_time_charge,
	psd.delivery_product,
	psd.delivery_channel_s,
	psd.delivery_channel,
	psd.num_seats_or_copies,
	psd.num_seats_or_copies_minmaxadj,
	COALESCE(psd.product_service, 'No Product Service') product_service,
	psa.billing_code,
	prod_master.bu business_unit,
	prod_master.master_product,
        psa.complex_product_service,
	psa.rate_card_name,
	prod_master.product_line master_product_line,
	psd.product_category,
	(COALESCE(opp.annualized_opportunity_revenue, 0) /  COALESCE(rate, 1)) annualized_opportunity_revenue,
	COALESCE(psd.net_recurring_amount, 0) net_recurring_amount,
	(12*COALESCE(psd.net_recurring_amount, 0) / COALESCE(rate, 1)) net_recurring_amount_converted_usd_finance, 
	(12*COALESCE(psd.net_recurring_amount, 0) / COALESCE(fx_rates_pricing.exchange_rate, 1)) net_recurring_amount_converted_usd, 
	COALESCE(psd.net_one_time_amount, 0) net_one_time_amount,
	(COALESCE(psd.net_one_time_amount, 0) / COALESCE(rate, 1)) net_one_time_amount_converted_usd_finance,
	(COALESCE(psd.net_one_time_amount, 0) / COALESCE(fx_rates_pricing.exchange_rate, 1)) net_one_time_amount_converted_usd,
	(12*COALESCE(psd.net_recurring_amount, 0) / COALESCE(rate, 1)) + (COALESCE(psd.net_one_time_amount, 0) / COALESCE(rate, 1)) annualized_rev_converted_usd_finance, 
	(12*COALESCE(psd.net_recurring_amount, 0) / COALESCE(fx_rates_pricing.exchange_rate, 1)) + (COALESCE(psd.net_one_time_amount, 0) / COALESCE(fx_rates_pricing.exchange_rate, 1)) annualized_rev_converted_usd, 
	(((12*COALESCE(psd.net_recurring_amount, 0) / COALESCE(rate, 1)) + (COALESCE(psd.net_one_time_amount, 0) / COALESCE(rate, 1))) / NULLIF(psd.num_seats_or_copies_minmaxadj, 0)) monthly_cust_unit_price_finance,
	(((12*COALESCE(psd.net_recurring_amount, 0) / COALESCE(fx_rates_pricing.exchange_rate, 1)) + (COALESCE(psd.net_one_time_amount, 0) / COALESCE(fx_rates_pricing.exchange_rate, 1))) / NULLIF(psd.num_seats_or_copies_minmaxadj, 0)) monthly_cust_unit_price,
	CASE WHEN rc.rate_card_type = 'A' AND psd.num_seats_or_copies_minmaxadj << rc.volume_high THEN round((rc.lagged_in_btwn_tier_factor * (psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high)) + rc.prev_tier_price)
	     WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 THEN ((psd.num_seats_or_copies_minmaxadj) * rc.monthly_price)
         WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 THEN prev_row_contribution + ((psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high) * rc.monthly_price)
	ELSE rc.monthly_price END AS monthly_rc_price,
	CASE WHEN cntry.country_segment = 'Premium' AND rc.rate_card_type = 'A' AND psd.num_seats_or_copies_minmaxadj << rc.volume_high 
	        THEN round((rc.lagged_ibt_factor_premium * (psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high)) + rc.prev_tier_price_premium)
    	 WHEN cntry.country_segment = 'Premium' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 
    	    THEN ((psd.num_seats_or_copies_minmaxadj) * rc.monthly_price_premium)
    	 WHEN cntry.country_segment = 'Premium' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 
    	    THEN prev_row_contribution_premium + ((psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high) * rc.monthly_price_premium)
    	 WHEN cntry.country_segment = 'Premium' AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_premium 
	     WHEN cntry.country_segment = 'Mid-Mature' AND rc.rate_card_type = 'A' AND psd.num_seats_or_copies_minmaxadj << rc.volume_high 
	        THEN round((rc.lagged_ibt_factor_mid * (psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high)) + rc.prev_tier_price_mid)
    	 WHEN cntry.country_segment = 'Mid-Mature' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 
    	    THEN ((psd.num_seats_or_copies_minmaxadj) * rc.monthly_price_mid)
    	 WHEN cntry.country_segment = 'Mid-Mature' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 
    	    THEN prev_row_contribution_mid + ((psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high) * rc.monthly_price_mid)
    	 WHEN cntry.country_segment = 'Mid-Mature' AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_mid 
    	 WHEN cntry.country_segment = 'Growing' AND rc.rate_card_type = 'A' AND psd.num_seats_or_copies_minmaxadj << rc.volume_high 
    	    THEN round((rc.lagged_ibt_factor_growing * (psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high)) + rc.prev_tier_price_growing)
    	 WHEN cntry.country_segment = 'Growing' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 
    	    THEN ((psd.num_seats_or_copies_minmaxadj) * rc.monthly_price_growing)
    	 WHEN cntry.country_segment = 'Growing' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 
    	    THEN prev_row_contribution_growing + ((psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high) * rc.monthly_price_growing)
    	 WHEN cntry.country_segment = 'Growing' AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_growing 
    	 ELSE NULL END AS monthly_rc_price_actual_segmented,
	CASE WHEN rc.rate_card_type = 'A' AND psd.num_seats_or_copies_minmaxadj << rc.volume_high THEN (round((rc.lagged_in_btwn_tier_factor * (psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high)) + rc.prev_tier_price) / NULLIF(CAST(psd.num_seats_or_copies_minmaxadj AS double), 0))
	     WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 THEN (((psd.num_seats_or_copies_minmaxadj) * rc.monthly_price) / NULLIF(CAST(psd.num_seats_or_copies_minmaxadj AS double), 0))
	     WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 THEN ((prev_row_contribution + ((psd.num_seats_or_copies_minmaxadj - rc.prev_tier_vol_high) * rc.monthly_price)) / NULLIF(CAST(psd.num_seats_or_copies_minmaxadj AS double), 0))
	     ELSE (rc.monthly_price / NULLIF(CAST(psd.num_seats_or_copies_minmaxadj AS double), 0)) END AS monthly_rc_unit_price,
	rc.rate_card_type,
	rc.product_name AS rate_card_product_name,
	psd.currency_iso_code,
	contact.buying_center,
	COALESCE(rate, 1) exchange_rate_finance,
	COALESCE(fx_rates_pricing.exchange_rate, 1) exchange_rate,
	Terr_RSD.user_full_name RSD,
	Terr_SP.user_full_name salesperson,
	terr_dim.region_code, 
	rc.volume_low,
	rc.volume_high,
	rc.min_order_quantity,
	rc.max_order_quantity,
	rc.uom AS unit_of_measure,
	case when (psd.num_seats_or_copies_minmaxadj<<=.5*rc.min_order_quantity or psd.num_seats_or_copies_minmaxadj>>1.5*rc.max_order_quantity) then 1 else 0 end as Vol_outlier,
    case_agg.price_increase_cat, 
    case_agg.price_inc_amt,
    case_agg.price_disc_amt,
    case_agg.emerging_mkt_amt,
    case_agg.above_rc_amt,
    case_agg.multi_yr_amt,
    case_agg.price_decrease_cat,
    case_agg.other_disc_amt,
    case_agg.num_months,
    case_agg.price_disc_cases,
    case_agg.emerging_mkt_cases,
    case_agg.above_rc_cases,
    case_agg.multi_yr_cases,
    case_agg.other_disc_cases,
    case_agg.desc1,
    case_agg.desc2,
    case_agg.desc3,
    case_agg.desc4,
    ddcreate.fiscal_week AS fiscal_week_create,
    ddcreate.fiscal_month AS fiscal_month_create,
    ddcreate.fiscal_year AS fiscal_year_create,
    ddcreate.fiscal_quarter AS fiscal_quarter_create,
    ddeff.fiscal_week AS fiscal_week_eff,
    ddeff.fiscal_month AS fiscal_month_eff,
    ddeff.fiscal_year AS fiscal_year_eff,
    ddeff.fiscal_quarter AS fiscal_quarter_eff,
    opp.autorenewal, 
		opp.renewal_term_months, 
opp.term_months,
		opp.max_renewals, 
		opp.clm_term_months_label, 
		opp.clm_renewal_term_months_label, 
		opp.payment_terms_days,
		opp.billing_frequency ,
		opp.billing_frequency_default,
		opp.contract_term_end_date,
		opp.contract_effective_date,
		opp.clm_third_party_contractor,
		opp.clm_third_party_integrator,
		opp.contact_name,
		opp.contact_email,
		opp.owner_full_name,
		opp.owner_email,
		opp.deal_amount,
		opp.deal_amount_usd,
		opp.deal_opportunity,
		opp.other_exceptions,
		psd.content_description,
		psd.content_description_revised ,
		psd.complimentary_service_full_name ,
		psd.complimentary_seats,
		psd.complimentary_seats_readonly ,
		psd.complimentary_seats_revised,
		psd.sow_line_item ,
		psd.seat_volume_type,
		psd.of_seats_or_copies_or_volume_2nd ,
		psd.seat_volume_type_2,
		psd.of_seats_or_copies_or_volume_3rd,
		psd.seat_volume_type_3,
		psd.of_seats_or_copies_or_volume_4th,
		psd.seat_volume_type_4,
		psd.delivery_frequency,
		psd.server_location,
		psd.additional_scope_terms,
		psd.additional_scope_terms_readonly ,
		psd.additional_scope_terms_revised ,
		psd.average_price,
		psd.no_average_price,
		psd.override_forecast_date
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
LEFT JOIN google_sheets_db.master_rate_card_pricing_fx_rates fx_rates_pricing ON psd.currency_iso_code = fx_rates_pricing.source_currency
								AND opp.opportunity_effective_date BETWEEN fx_rates_pricing.exchange_rate_valid_from_date AND fx_rates_pricing.exchange_rate_valid_to_date
LEFT JOIN prod_master ON psd.product_service = prod_master.sfdc_product
LEFT JOIN Terr_RSD ON Terr_Dim.regional_sales_director = Terr_RSD.user_sfdc_id
LEFT JOIN Terr_RSD AS Terr_SP ON Terr_Dim.territory_owner = Terr_SP.user_sfdc_id
LEFT JOIN contact ON contact.contact_sfdc_id = opp.primary_contact
LEFT JOIN corp ON corp.corporate_sfdc_id = comp.parent_sfdc_id
LEFT JOIN bad ON bad.salesforce_billing_account_id = opp.billing_account
LEFT JOIN case_agg ON case_agg.opportunity = opp.pib_opportunity_sfdc_id AND case_agg.product_service = psd.product_service
LEFT JOIN dimension_external_db.pib_product_service_attributes psa ON psa.product_service = psd.product_service
LEFT JOIN adj_rate_card rc ON lower(rc.product_name) = lower(psa.rate_card_name) 
								AND psd.num_seats_or_copies_minmaxadj BETWEEN rc.volume_low AND rc.volume_high
								AND opp.opportunity_effective_date BETWEEN rc.rate_card_valid_from AND rc.rate_card_valid_to
LEFT JOIN adj_rate_card_current rcc ON lower(rcc.product_name) = lower(psa.rate_card_name) 
								AND psd.num_seats_or_copies_minmaxadj BETWEEN rcc.volume_low AND rcc.volume_high
								AND opp.opportunity_effective_date BETWEEN rcc.rate_card_valid_from AND rcc.rate_card_valid_to
LEFT JOIN dimension_external_db.pib_country_dimension cntry on cntry.country = opp.opportunity_country
LEFT JOIN final_cumulative_sums ON final_cumulative_sums.row_number_col = rc.row_number_col
LEFT JOIN final_cumulative_sums_current ON final_cumulative_sums_current.row_number_col = rcc.row_number_col
LEFT JOIN date_dim AS ddcreate ON date(opp.created_date) = ddcreate.dat
LEFT JOIN date_dim AS ddeff ON date(opp.opportunity_effective_date) = ddeff.dat
WHERE comp.company_name not in ('Factiva xx', 'ZZZ Internal Factiva Accounts-Admin Portal')
	and lower(opp.opportunity_name) not like '%dummy%'
	and lower(opp.opportunity_name) not like '%test%'),

neg_opps AS (
SELECT opportunity_number, pib_opportunity_sfdc_id, sum(CASE WHEN annualized_rev_converted_usd << 0 THEN 1 ELSE 0 END) neg_rev_prod_svcs 
FROM core
GROUP BY 1, 2)	

SELECT core.*, neg_opps.neg_rev_prod_svcs
FROM core 
LEFT JOIN neg_opps ON core.pib_opportunity_sfdc_id = neg_opps.pib_opportunity_sfdc_id                                                                
