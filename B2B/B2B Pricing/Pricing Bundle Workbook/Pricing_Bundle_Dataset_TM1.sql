-- Dashboard   : "Pricing Bundle Workbook"  [B2B / B2B Pricing]
-- Data source : "Pricing_Bundle_Dataset_TM1" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH comp as (SELECT DISTINCT
	company_sfdc_id,
	company_name,
	company_industry,
	company_country,
	company_territory,
	parent_sfdc_id,
	ntc_prospect,
        ntc_owner,
	sales_campaign_s,
	r_c_proposition
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
SELECT DISTINCT salesforce_billing_account_id, cibs_billing_account_id, salesforce_company_two, salesforce_territory, salesforce_currency_transaction_code, salesforce_partner_flag 
FROM dimension_external_db.pib_billing_account_dimension ),

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

Terr_Dim_bad as (
select
	territory_sfdc_id,
	territory_name,
	territory_owner,
	territory_roll_up,
	regional_sales_director,
	region_code
from
	dimension_external_db.pib_territory_dimension),
	
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
	   
cpr AS (
	SELECT DISTINCT
	*
	, product_id AS cibs_product_id
	, CASE
		WHEN num_seats = 'Y'
		AND (trans_vol_flag = 'N' OR COALESCE(trans_vol_flag,'') = '')
			THEN 'Seats'
		WHEN trans_vol_flag = 'Y'
		AND (num_seats = 'N' OR COALESCE(num_seats,'') = '')
			THEN 'Volume'
		WHEN num_seats = 'Y'
		AND trans_vol_flag = 'Y'
			THEN 'Seats and Volume'
	   ELSE NULL
	  END AS billed_by_label
	FROM finance_external_db.cibs_products_rules
	WHERE cycle_date = (SELECT MAX(cycle_date) FROM finance_external_db.cibs_products_rules)),

mattg_tm1_inny AS (
SELECT DISTINCT
cgl.cycle_date AS billing_month
, cgl.billing_account_number
, cgl.product_id AS cibs_product_id
, CASE
    WHEN cp_parent.product_id IS NULL
        THEN cgl.product_id
    ELSE cp_parent.product_id
  END AS cibs_parent_product_id
, cpr.billed_by_label
, cpr.num_seats AS cibs_product_rules_num_seats
, cpr.trans_vol_flag AS cibs_product_rules_trans_vol_flag
, CASE
	WHEN cpr.billed_by_label IN ('Seats','Seats and Volume')
	OR cpr.billed_by_label IS NULL
		THEN cgl.number_of_user_seats
  END AS number_of_user_seats
, CASE
	WHEN cpr.billed_by_label IN ('Volume','Seats and Volume')
	OR cpr.billed_by_label IS NULL
		THEN cgl.users_transaction_volume
  END AS users_transaction_volume
FROM finance_external_db.tm1_cibs_gltransrel cgl
LEFT JOIN cpr
	ON cgl.product_id  = cpr.cibs_product_id
LEFT JOIN (SELECT * FROM finance_external_db.cibs_products WHERE cycle_date = (SELECT MAX(cycle_date) FROM finance_external_db.cibs_products)) cp_parent
    ON cgl.product_id = cp_parent.service_product_id
WHERE LOWER(cgl.revenue_type_id) LIKE '%rev%'),

djx_volume_subquery AS (SELECT cycle_date, billing_account_number, product_id,  count(*) row_count, count(*) / 2 seats_count
FROM finance_external_db.tm1_cibs_gltransrel 
WHERE LOWER(revenue_type_id) LIKE '%rev%'
GROUP BY 1, 2, 3),

mattg_tm1_pre AS (
SELECT 
billing_month, billing_account_number, cibs_product_id, billed_by_label, cibs_product_rules_num_seats, cibs_product_rules_trans_vol_flag,
sum(number_of_user_seats) AS number_of_user_seats,
sum(users_transaction_volume) AS users_transaction_volume
FROM mattg_tm1_inny GROUP BY 1, 2, 3, 4, 5, 6),

mattg_tm1 AS (
SELECT billing_month, mg.billing_account_number, cibs_product_id, billed_by_label, cibs_product_rules_num_seats, cibs_product_rules_trans_vol_flag,
coalesce(mg.number_of_user_seats, djx.seats_count) AS number_of_user_seats,
mg.users_transaction_volume
FROM mattg_tm1_pre mg
LEFT JOIN djx_volume_subquery djx ON mg.billing_month = djx.cycle_date AND mg.billing_account_number = djx.billing_account_number AND mg.cibs_product_id = djx.product_id),

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

/*
 * Identifying Service Fee Codes that need to be manually casted to their associated regular product codes to remove TM1 source data leakage
 * 
 * We need to look in the cibs_products table, at the latest cycle_date in the table, removing product_ids that are free_month_product_ids, and only keeping 1:1 relationships (to avoid duplication downstream)
 */

relevant_service_ids AS (
SELECT service_product_id 
FROM 
(SELECT service_product_id, count(*) rowcount
 FROM finance_external_db.cibs_products cp
 WHERE cycle_date = (SELECT max(cycle_date) FROM finance_external_db.cibs_products) 
	 AND product_id NOT IN (SELECT DISTINCT free_month_product_id FROM finance_external_db.cibs_products 
							 WHERE cycle_date = (SELECT max(cycle_date) FROM finance_external_db.cibs_products))
 GROUP BY 1) 
WHERE rowcount = 1),

service_id_prod_id_mapping AS (
SELECT relevant_service_ids.service_product_id, cp.product_id, cp."desc" 
 FROM finance_external_db.cibs_products cp
 INNER JOIN relevant_service_ids ON relevant_service_ids.service_product_id = cp.service_product_id 
 WHERE cycle_date = (SELECT max(cycle_date) FROM finance_external_db.cibs_products) 
	 AND product_id NOT IN (SELECT DISTINCT free_month_product_id FROM finance_external_db.cibs_products 
							 WHERE cycle_date = (SELECT max(cycle_date) FROM finance_external_db.cibs_products))),

/*
* A slice of TM1 data that serves as the base of the dataset.
* ->> Starts in February 2022 since that is the first month of clean volumes/CIBS codes as far as we understand
* ->> minmaxadj field combines Transaction Volumes & User Seats fields into a consolidated single value, adjusted to be the minimum if below te rate card's minimum, and to be the maximum if above the rate card's maximum
*/ 

tm1_inscope AS (
SELECT customer_name, 
	   tm.billing_account_number, 
	   billing_date, 
            billed_by_label,
           tm.tm1_name,
	   tm.product_category, 
	   tm.currency,
	   tm.tm1_rollup_bu,
	   tm.tm1_rollup_segment,
	   tm.tm1_rollup_category,
	   cibs_id, 
	   cibs_product, 
	   cp.service_product_id,
	   COALESCE(cp.product_id, cibs_id) AS remapped_product_id,
	   COALESCE(cp."desc", cibs_product) AS remapped_cibs_product,
	   user_trans_vol, 
	   num_user_seats, 
	   mattg_tm1.number_of_user_seats AS b2bclose_seats,
	   mattg_tm1.users_transaction_volume AS b2bclose_volumes,
	   CASE WHEN cp.service_product_id IS NOT NULL THEN 0 else coalesce(coalesce(NULLIF(mattg_tm1.users_transaction_volume, 0), NULLIF(mattg_tm1.number_of_user_seats, 0)), 1) end AS num_seats_or_copies_tm1, 
	   CASE WHEN cp.service_product_id IS NOT NULL THEN 0 
	   		WHEN rc.min_order_quantity >> coalesce(coalesce(NULLIF(mattg_tm1.users_transaction_volume, 0), NULLIF(mattg_tm1.number_of_user_seats, 0)), 1) THEN rc.min_order_quantity
	   		WHEN rc.max_order_quantity << coalesce(coalesce(NULLIF(mattg_tm1.users_transaction_volume, 0), NULLIF(mattg_tm1.number_of_user_seats, 0)), 1) THEN rc.max_order_quantity
	   		ELSE coalesce(coalesce(NULLIF(mattg_tm1.users_transaction_volume, 0), NULLIF(mattg_tm1.number_of_user_seats, 0)), 1)  END AS num_seats_or_copies_tm1_minmaxadj,
	   CASE WHEN cp.service_product_id IS NOT NULL THEN 0 
	   		WHEN rcc.min_order_quantity >> coalesce(coalesce(NULLIF(mattg_tm1.users_transaction_volume, 0), NULLIF(mattg_tm1.number_of_user_seats, 0)), 1) THEN rcc.min_order_quantity
	   		WHEN rcc.max_order_quantity << coalesce(coalesce(NULLIF(mattg_tm1.users_transaction_volume, 0), NULLIF(mattg_tm1.number_of_user_seats, 0)), 1) THEN rcc.max_order_quantity
	   		ELSE coalesce(coalesce(NULLIF(mattg_tm1.users_transaction_volume, 0), NULLIF(mattg_tm1.number_of_user_seats, 0)), 1)  END AS num_seats_or_copies_tm1_minmaxadj_current,
	   sum(exit_rate) AS exit_rate, 
	   sum(total_non_recurring_revenue) AS total_non_recurring_revenue
FROM fact_external_db.tm1_fact tm
LEFT JOIN service_id_prod_id_mapping cp ON tm.cibs_id = cp.service_product_id 
LEFT JOIN dimension_external_db.pib_product_service_attributes psa ON psa.billing_code = COALESCE(cp.product_id, tm.cibs_id)
LEFT JOIN rate_card_simplified rc ON rc.product_name = psa.rate_card_name 
								AND tm.billing_date BETWEEN rc.rate_card_valid_from AND rc.rate_card_valid_to
LEFT JOIN rate_card_simplified_current rcc ON rcc.product_name = psa.rate_card_name 
LEFT JOIN mattg_tm1 ON mattg_tm1.billing_month = tm.billing_date 
								AND mattg_tm1.billing_account_number = tm.billing_account_number
								AND mattg_tm1.cibs_product_id = COALESCE(cp.product_id, tm.cibs_id)
WHERE billing_date >>= date('2022-10-01')
AND NOT (tm.billing_account_number = '9FRE006300' AND cibs_id = 'PRDX')
AND NOT (tm.billing_account_number = '9FRE006300' AND cibs_id = 'RDSE')
AND NOT (tm.billing_account_number = '9FRE006200' AND cibs_id = 'RDSE')
group BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22),

tm1_inscope_patched AS (
SELECT tm.customer_name, 
	   tm.billing_account_number, 
	   tm.billing_date, 
       tm.billed_by_label,
       tm.tm1_name,
	   tm.product_category, 
	   tm.currency,
	   tm.tm1_rollup_bu,
	   tm.tm1_rollup_segment,
	   tm.tm1_rollup_category,
	   tm.remapped_product_id AS cibs_id,
	   tm.remapped_cibs_product AS cibs_product,
	   sum(user_trans_vol) AS user_trans_vol, 
	   sum(num_user_seats) AS num_user_seats, 
	   COALESCE(NULLIF(sum(b2bclose_seats), 0), 1) AS b2bclose_seats,
	   COALESCE(NULLIF(sum(b2bclose_volumes), 0), 1) AS b2bclose_volumes,
	   COALESCE(NULLIF(sum(num_seats_or_copies_tm1), 0), 1) AS num_seats_or_copies_tm1, 
	   COALESCE(NULLIF(sum(num_seats_or_copies_tm1_minmaxadj), 0), 1) AS num_seats_or_copies_tm1_minmaxadj,
	   COALESCE(NULLIF(sum(num_seats_or_copies_tm1_minmaxadj_current), 0), 1) AS num_seats_or_copies_tm1_minmaxadj_current,
	   sum(exit_rate) AS exit_rate, 
	   sum(total_non_recurring_revenue) AS total_non_recurring_revenue
FROM tm1_inscope tm
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12),

/*
* Identify first billing charge date (regardless of product code) for each billing account
*/ 

cibs_first_charge_date_account AS (
SELECT bad.cibs_billing_account_id,  min(start_date) first_date
FROM dimension_external_db.pib_cibs_billing_charges_dimension cib
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON bad.salesforce_billing_account_id = cib.cibs_billing_account 
GROUP BY 1
),

/*
* Identify first billing charge date (by product code) for each billing account-product code combo
*/

cibs_first_charge_date_product AS (
SELECT bad.cibs_billing_account_id, cib.product_id, min(start_date) first_date
FROM dimension_external_db.pib_cibs_billing_charges_dimension cib
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON bad.salesforce_billing_account_id = cib.cibs_billing_account 
GROUP BY 1, 2
),

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

adj_rate_card AS (SELECT rate_card.*, lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor, lag.volume_high AS prev_tier_vol_high, lag.monthly_price AS prev_tier_price
FROM rate_card
LEFT JOIN led_row_tbl lag ON lag.led_row = rate_card.row_number_col),

adj_rate_card_current AS (SELECT rate_card_current.*, lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor, lag.volume_high AS prev_tier_vol_high, lag.monthly_price AS prev_tier_price
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
	/*Old logic that was patched 9/14/2023
	 * CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card.volume_high AS bigint) * rate_card.monthly_price
		ELSE CAST(rate_card.volume_high AS bigint) * rate_card.monthly_price
	END AS tier_price_contribution,*/
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card.volume_high AS bigint) * rate_card.monthly_price
		ELSE (CAST(rate_card.volume_high AS bigint) - lag.volume_high) * rate_card.monthly_price
	END AS tier_price_contribution
FROM rate_card
	LEFT JOIN led_row_tbl lag ON lag.led_row = rate_card.row_number_col
WHERE rate_card.rate_card_type = 'D'),

partial_sums_current AS (
SELECT rate_card_current.*,
	lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor,
	lag.volume_high AS prev_tier_vol_high,
	lag.monthly_price AS prev_tier_price,
	/*Old logic that was patched 9/14/2023
	 * CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price
		ELSE CAST(rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price
	END AS tier_price_contribution,*/
	CASE
		WHEN lag.volume_high = -1 THEN CAST (rate_card_current.volume_high AS bigint) * rate_card_current.monthly_price
		ELSE (CAST(rate_card_current.volume_high AS bigint) - lag.volume_high) * rate_card_current.monthly_price
	END AS tier_price_contribution
FROM rate_card_current
	LEFT JOIN led_row_tbl_current lag ON lag.led_row = rate_card_current.row_number_col
WHERE rate_card_current.rate_card_type = 'D'),

cumulative_sums AS (
SELECT partial_sums.*, sum(tier_price_contribution) OVER (PARTITION BY rate_card_valid_from, product_name
															 ORDER BY row_number_col) AS cumulative_tier_price_contribution
FROM partial_sums
ORDER BY row_number_col),

cumulative_sums_current AS (
SELECT partial_sums_current.*, sum(tier_price_contribution) OVER (PARTITION BY rate_card_valid_from, product_name
															 ORDER BY row_number_col) AS cumulative_tier_price_contribution
FROM partial_sums_current
ORDER BY row_number_col),

final_cumulative_sums AS (
SELECT cumulative_sums.*, 
	   lag(cumulative_tier_price_contribution) OVER (ORDER BY row_number_col) AS prev_row_contribution
FROM cumulative_sums),

final_cumulative_sums_current AS (
SELECT cumulative_sums_current.*, 
	   lag(cumulative_tier_price_contribution) OVER (ORDER BY row_number_col) AS prev_row_contribution_current
FROM cumulative_sums_current),

/*
* Identifiying the most recent contract renewal date per billing account ID. There can be multiple renewal dates, hence taking the max to avoid duplicates
*/ 

renewal_dates AS (SELECT cibs_billing_account_id, max(contract_renewal_date) AS contract_renewal_date
FROM (
SELECT bad.cibs_billing_account_id, ctr.contract_renewal_date 
FROM dimension_external_db.pib_billing_account_dimension bad
inner JOIN dimension_external_db.pib_contract_dimension ctr ON bad.contract_id = CTR.CONTRACT_Id
GROUP BY 1, 2
ORDER BY cibs_billing_account_id, contract_renewal_date DESC)
GROUP BY 1),

/*
* Some fiscal date information to include in the dataset
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
where full_date >>= date('2012-07-01')
and full_date <<= date_add('day', 1500, current_date)),

/*
* Combines historical Finance FX rates with the current rates in order to have a complete history table including the current fiscal year. 
* ->> This is not future-proof and will break in FY24.
*/

fx_finance AS (
 SELECT *,
		 CAST(concat(CAST((CAST(YEAR AS int) - 1) AS varchar), '-07-01') AS date) AS valid_from,
		 CAST(concat(YEAR, '-06-30') AS date) AS valid_to
		FROM (
		/*SELECT *, '2023' AS YEAR
		FROM reference_external_db.fx_rates_current
		UNION ALL */
		SELECT * FROM reference_external_db.fx_rates_history)),

fx_rates_pricing_current as (
SELECT * FROM google_sheets_db.master_rate_card_pricing_fx_rates WHERE exchange_rate_valid_to_date  >> date('9999-01-01')),

contracts AS (
SELECT bad.cibs_billing_account_id,ctr.salesforce_contract_number 
FROM dimension_external_db.pib_billing_account_dimension bad
inner JOIN dimension_external_db.pib_contract_dimension ctr ON bad.contract_id = CTR.CONTRACT_Id
GROUP BY 1, 2),

base_tm1 as (
SELECT
	DISTINCT 
	corp.corporate_name,
	comp.company_name,
	comp.r_c_proposition,
	tm.customer_name,
	tm.billing_account_number,
	contracts.salesforce_contract_number,
	salesforce_partner_flag,
	tm.billing_date,
	renewal_dates.contract_renewal_date,
	first_chg.first_date AS first_account_prod_charge_date,
    --tm.billed_by_label,
	tm.cibs_id,
	tm.cibs_product,
	--tm.remapped_product_id,
	--tm.remapped_cibs_product,
	tm.product_category,
        tm.tm1_name,
	tm.tm1_rollup_bu,
	   tm.tm1_rollup_segment,
	   tm.tm1_rollup_category,
	Terr_Dim_bad.region_code,	
	Terr_Dim_bad.territory_name,
	--ud.user_full_name AS territory_owner,
	COALESCE(comp.company_country, 'Other') company_country,
	COALESCE(comp.company_industry, 'Other') company_industry, 
	Terr_RSD.user_full_name RSD,
	usrc.user_full_name AS sales_person,
	--prod_master.bu business_unit,
	--psa.product_service,
	psa.rate_card_name,
    --psa.product_line,
	--rc.product_name,
	tm.exit_rate,
	(COALESCE(tm.exit_rate, 0) * fx_finance.rate / fx_rates_pricing.exchange_rate) exit_rate_pricing_usd_actual,
	(COALESCE(tm.exit_rate, 0) * fx_finance.rate / fx_rates_pricing_current.exchange_rate) exit_rate_pricing_usd_current,
	(COALESCE(tm.total_non_recurring_revenue, 0) * fx_finance.rate / fx_rates_pricing.exchange_rate) non_recurring_rev_pricing_usd_actual,	
	(COALESCE(tm.total_non_recurring_revenue, 0) * fx_finance.rate / fx_rates_pricing_current.exchange_rate) non_recurring_rev_pricing_usd_current,	
	tm.total_non_recurring_revenue,
	((tm.exit_rate + tm.total_non_recurring_revenue) * fx_finance.rate / fx_rates_pricing.exchange_rate) AS total_revenue_pricing_usd_actual,
	((tm.exit_rate + tm.total_non_recurring_revenue) * fx_finance.rate / fx_rates_pricing_current.exchange_rate) AS total_revenue_pricing_usd_current,
	tm.currency tm_currency,
	fx_finance.currency fx_finance_currency, 
	fx_finance.rate fx_finance_rate,
	fx_rates_pricing.source_currency fx_pricing_source_currency,
	fx_rates_pricing.exchange_rate fx_pricing_exchange_rate_actual,
        fx_rates_pricing_current.exchange_rate fx_pricing_exchange_rate_current,
	tm.num_seats_or_copies_tm1,
	tm.num_seats_or_copies_tm1_minmaxadj as num_seats_or_copies_tm1_minmaxadj_actual,
	tm.num_seats_or_copies_tm1_minmaxadj_current,
	CASE WHEN rc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj << rc.volume_high THEN round((rc.lagged_in_btwn_tier_factor * (tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high)) + rc.prev_tier_price)
		WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 THEN ((tm.num_seats_or_copies_tm1_minmaxadj) * rc.monthly_price)
		WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 THEN prev_row_contribution + ((tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high) * rc.monthly_price)
		ELSE rc.monthly_price END AS monthly_rc_price_actual,
	CASE WHEN rcc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_current << rcc.volume_high THEN round((rcc.lagged_in_btwn_tier_factor * (tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high)) + rcc.prev_tier_price)
		WHEN rcc.rate_card_type = 'D' AND rcc.prev_tier_vol_high = -1 THEN ((tm.num_seats_or_copies_tm1_minmaxadj_current) * rcc.monthly_price)
		WHEN rcc.rate_card_type = 'D' AND rcc.prev_tier_vol_high >> -1 THEN prev_row_contribution_current + ((tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high) * rcc.monthly_price)
		ELSE rcc.monthly_price END AS monthly_rc_price_current,
	--CASE WHEN rc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj << rc.volume_high THEN round((rc.lagged_in_btwn_tier_factor * (tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high)) + rc.prev_tier_price) / tm.num_seats_or_copies_tm1_minmaxadj
		--WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 THEN ((tm.num_seats_or_copies_tm1_minmaxadj) * rc.monthly_price) / tm.num_seats_or_copies_tm1_minmaxadj
		--WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 THEN ((prev_row_contribution + ((tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high) * rc.monthly_price)) / tm.num_seats_or_copies_tm1_minmaxadj)
		--ELSE (CAST(rc.monthly_price AS double) / tm.num_seats_or_copies_tm1_minmaxadj) END AS monthly_rc_unit_price_actual,
	--CASE WHEN rcc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_current << rcc.volume_high THEN round((rcc.lagged_in_btwn_tier_factor * (tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high)) + rcc.prev_tier_price) / tm.num_seats_or_copies_tm1_minmaxadj_current
		--WHEN rcc.rate_card_type = 'D' AND rcc.prev_tier_vol_high = -1 THEN ((tm.num_seats_or_copies_tm1_minmaxadj_current) * rcc.monthly_price) / tm.num_seats_or_copies_tm1_minmaxadj_current
		--WHEN rcc.rate_card_type = 'D' AND rcc.prev_tier_vol_high >> -1 THEN ((prev_row_contribution_current + ((tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high) * rcc.monthly_price)) / tm.num_seats_or_copies_tm1_minmaxadj_current)
		--ELSE (CAST(rcc.monthly_price AS double) / tm.num_seats_or_copies_tm1_minmaxadj_current) END AS monthly_rc_unit_price_current,
	--((COALESCE((tm.exit_rate + tm.total_non_recurring_revenue), 0) * fx_finance.rate / fx_rates_pricing.exchange_rate) / NULLIF(tm.num_seats_or_copies_tm1_minmaxadj, 0)) monthly_cust_unit_price_actual,
	--((COALESCE((tm.exit_rate + tm.total_non_recurring_revenue), 0) * fx_finance.rate / fx_rates_pricing_current.exchange_rate) / NULLIF(tm.num_seats_or_copies_tm1_minmaxadj_current, 0)) monthly_cust_unit_price_current,
	rc.volume_low,
	rc.volume_high,
	rc.uom AS unit_of_measure
    --dd_billing_date.fiscal_month AS fiscal_month_tm1,
    --dd_billing_date.fiscal_year AS fiscal_year_tm1,
    --dd_billing_date.fiscal_quarter AS fiscal_quarter_tm1,
        --case when (num_seats_or_copies_tm1 = num_seats_or_copies_tm1_minmaxadj) THEN 'No' 
             --when (num_seats_or_copies_tm1 <<>> num_seats_or_copies_tm1_minmaxadj) THEN 'Yes' 
                --else NULL END as adjusted_seats
FROM
	tm1_inscope_patched tm
LEFT JOIN bad ON bad.cibs_billing_account_id = tm.billing_account_number
LEFT JOIN comp ON bad.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN corp ON corp.corporate_sfdc_id = comp.parent_sfdc_id
LEFT JOIN usr AS usrc ON comp.ntc_owner = usrc.user_sfdc_id
LEFT JOIN Terr_Dim ON comp.company_territory = Terr_Dim.territory_sfdc_id
LEFT JOIN Terr_Dim_bad ON bad.salesforce_territory = Terr_Dim_bad.territory_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension ud ON Terr_Dim_bad.territory_owner = ud.user_sfdc_id 
LEFT JOIN reference_external_db.cibs_currency_code_mapping fx_mapping ON bad.salesforce_currency_transaction_code = fx_mapping.sfdc_code 
LEFT JOIN fx_finance ON fx_finance.currency = tm.currency
								AND tm.billing_date BETWEEN fx_finance.valid_from AND fx_finance.valid_to
LEFT JOIN google_sheets_db.master_rate_card_pricing_fx_rates fx_rates_pricing ON fx_rates_pricing.source_currency = fx_mapping.currency_code 
								AND tm.billing_date BETWEEN fx_rates_pricing.exchange_rate_valid_from_date AND fx_rates_pricing.exchange_rate_valid_to_date 
left join fx_rates_pricing_current on fx_rates_pricing_current.source_currency = fx_mapping.currency_code 
LEFT JOIN dimension_external_db.pib_product_service_attributes psa ON psa.billing_code = tm.cibs_id							
LEFT JOIN adj_rate_card rc ON rc.product_name = psa.rate_card_name 
								AND tm.billing_date BETWEEN  rc.rate_card_valid_from AND rc.rate_card_valid_to
								AND tm.num_seats_or_copies_tm1_minmaxadj BETWEEN rc.volume_low AND rc.volume_high
LEFT JOIN adj_rate_card_current rcc ON rcc.product_name = psa.rate_card_name 
								AND tm.num_seats_or_copies_tm1_minmaxadj_current BETWEEN rcc.volume_low AND rcc.volume_high
LEFT JOIN final_cumulative_sums ON final_cumulative_sums.row_number_col = rc.row_number_col
LEFT JOIN final_cumulative_sums_current ON final_cumulative_sums_current.row_number_col = rcc.row_number_col
LEFT JOIN prod_master ON psa.product_service = prod_master.sfdc_product
LEFT JOIN Terr_RSD ON Terr_Dim.regional_sales_director = Terr_RSD.user_sfdc_id
LEFT JOIN date_dim AS dd_billing_date ON tm.billing_date = dd_billing_date.dat
LEFT JOIN cibs_first_charge_date_product first_chg ON tm.cibs_id = first_chg.product_id
								AND tm.billing_account_number = first_chg.cibs_billing_account_id
LEFT JOIN cibs_first_charge_date_account fist_chg_act ON tm.cibs_id = fist_chg_act.cibs_billing_account_id
LEFT JOIN renewal_dates ON renewal_dates.cibs_billing_account_id = tm.billing_account_number
LEFT JOIN contracts ON contracts.cibs_billing_account_id = tm.billing_account_number
WHERE comp.company_name not in ('Factiva xx', 'ZZZ Internal Factiva Accounts-Admin Portal'))
        

SELECT tbl_1.corporate_name,
	tbl_1.company_name,
	tbl_1.customer_name,
        tbl_1.r_c_proposition,
	tbl_1.billing_account_number,
	tbl_1.salesforce_contract_number,
	tbl_1.billing_date,
	tbl_1.cibs_id,
	tbl_1.cibs_product,
	tbl_1.rate_card_name,
	tbl_1.territory_name,
	tbl_1.region_code,	
	tbl_1.company_country,
	tbl_1.company_industry, 
	tbl_1.RSD,
	tbl_1.sales_person,
	tbl_1.exit_rate_pricing_usd_current as exit_rate_current_1,
	tbl_1.exit_rate_pricing_usd_actual as exit_rate_actual_1,
	tbl_2.cibs_product as product_2, 
    tbl_2.cibs_id as cibs_id_2, 
	tbl_2.product_category as product_category_2,
        tbl_2.tm1_rollup_bu,
        tbl_2.tm1_rollup_segment,
        tbl_2.tm1_rollup_category,
    tbl_2.rate_card_name as rate_card_name_2,
	tbl_2.exit_rate_pricing_usd_current as exit_rate_current_2,
	tbl_2.exit_rate_pricing_usd_actual as exit_rate_actual_2,
	tbl_2.tm_currency as tm_currency_2,
	tbl_2.monthly_rc_price_current as monthly_rc_price_current_2,
	tbl_2.monthly_rc_price_actual as monthly_rc_price_actual_2,
	tbl_2.num_seats_or_copies_tm1 as num_seats_or_copies_tm1_2,
	tbl_2.num_seats_or_copies_tm1_minmaxadj_current as num_seats_or_copies_tm1_minmaxadj_current_2,
	tbl_2.num_seats_or_copies_tm1_minmaxadj_actual as num_seats_or_copies_tm1_minmaxadj_actual_2,
	tbl_2.volume_low as volume_low_2,
	tbl_2.volume_high as volume_high_2
	
FROM base_tm1 tbl_1
INNER JOIN base_tm1 tbl_2 on tbl_1.billing_account_number = tbl_2.billing_account_number
				AND tbl_1.billing_date = tbl_2.billing_date
