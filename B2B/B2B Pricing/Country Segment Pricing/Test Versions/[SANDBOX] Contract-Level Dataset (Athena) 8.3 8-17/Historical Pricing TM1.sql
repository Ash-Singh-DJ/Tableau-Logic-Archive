-- Dashboard   : "[SANDBOX] Contract-Level Dataset (Athena) 8.3 8:17"  [B2B / B2B Pricing / Country Segment Pricing / Test Versions]
-- Data source : "Historical Pricing TM1" (embedded in the workbook)
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
	r_c_proposition,
	third_party_partner_flag,
	relationship_type, goverment_account_flag
FROM
	dimension_external_db.pib_company_dimension
WHERE
	status_flag <<>> 'DELETE'),
	
corp AS (
SELECT DISTINCT corporate_name,
		corporate_sfdc_id,
		corporate_id
FROM dimension_external_db.pib_corporate_dimension 
),

bad AS (
SELECT DISTINCT salesforce_billing_account_id, cibs_billing_account_id, contract_id, salesforce_company_two, salesforce_territory, salesforce_currency_transaction_code, country, salesforce_country, salesforce_account_name, salesforce_contract_renewal_date --, salesforce_partner_flag
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
	   tm.account_name,
	   cibs_id, 
	   cibs_product, 
	   cp.service_product_id,
	   COALESCE(cp.product_id, cibs_id) AS remapped_product_id,
	   COALESCE(cp."desc", cibs_product) AS remapped_cibs_product,
	   --cma.sap_material_no,
	   psa.service_full_name,
	   --cma2.ihs_segment_description,
	   --cma2.ecr_pp,
	   --concat(cma.sap_material_no, cma2.ihs_segment_description) AS concat_join_key,
	   --cma_lead.INDEX AS lp_index,
	   --cma_lead.constant1,
	   --cma_lead.exponent1,
	   --cma.unit_price AS ent_price,
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
--LEFT JOIN google_sheets_db.master_rate_card_cma_parent_products cma ON psa.service_full_name = cma.material_short_desc
--LEFT JOIN google_sheets_db.master_rate_card_cma_account_placement cma2 ON lower(tm.account_name) = lower(cma2.gu_company_name)
--LEFT JOIN google_sheets_db.master_rate_card_cma_leader_product cma_lead ON cma_lead.INDEX = concat(cma.sap_material_no, cma2.ihs_segment_description)
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
group BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24),

tm1_inscope_patched AS (
SELECT tm.billing_account_number, 
        bad.salesforce_currency_transaction_code,
        bad.contract_id,
        comp.company_sfdc_id,
        comp.company_country,
        comp.company_name,
        corp.corporate_id,
	   tm.billing_date, 
       tm.billed_by_label,
       tm.tm1_name,
       tm.account_name,
	   tm.product_category, 
	   tm.currency,
	   tm.tm1_rollup_bu,
	   tm.tm1_rollup_segment,
	   tm.tm1_rollup_category,
	   tm.remapped_product_id AS cibs_id,
	   tm.remapped_cibs_product AS cibs_product,
	   tm.service_full_name,
	   --tm.sap_material_no,
	   --tm.ihs_segment_description,
	   --tm.ecr_pp,
	   --tm.concat_join_key,
	   --tm.lp_index,
	   --NULLIF(tm.constant1, 'Contact PM') AS constant1,
	   --NULLIF(tm.exponent1, 'Contact PM') AS exponent1,
	   --tm.ent_price,
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
LEFT JOIN bad ON bad.cibs_billing_account_id = tm.billing_account_number
LEFT JOIN comp ON bad.salesforce_company_two = comp.company_sfdc_id
left join corp ON corp.corporate_sfdc_id = comp.parent_sfdc_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19),

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
where current_chg <<>> 'Cancelled'
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


/*
* Identifiying the most recent contract renewal date per billing account ID. There can be multiple renewal dates, hence taking the max to avoid duplicates
*/ 

renewal_dates AS (SELECT cibs_billing_account_id, 
--salesforce_term_length_months, 
contract_id, 
--contract_start_date, 
max(contract_renewal_date) AS contract_renewal_date
FROM (
SELECT bad.cibs_billing_account_id, bad.contract_id, 
--ctr.salesforce_term_length_months, ctr.contract_start_date, 
ctr.contract_renewal_date 
FROM dimension_external_db.pib_billing_account_dimension bad
inner JOIN dimension_external_db.pib_contract_dimension ctr ON bad.contract_id = CTR.CONTRACT_Id
GROUP BY 1, 2, 3
--, 4, 5
ORDER BY cibs_billing_account_id, contract_renewal_date DESC)
GROUP BY 1, 2
--, 3, 4
),

contract_max_modified_dates as (select con.contract_id, max(con.last_change_date) as most_recent_last_change_date
from dimension_external_db.pib_contract_dimension con
group by 1),

contract_info as (select con.contract_id, con.salesforce_auto_renewal_flag, max(con.salesforce_term_length_months) as salesforce_term_length_months, max(con.contract_renewal_date) as contract_renewal_date, max(contract_start_date) as contract_start_date
from contract_max_modified_dates mod
join dimension_external_db.pib_contract_dimension con on con.contract_id = mod.contract_id and con.last_change_date = mod.most_recent_last_change_date
WHERE salesforce_auto_renewal_flag is not null
group by 1, 2),

/* Some fiscal date information to include in the dataset
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

primary_submap AS ( -- anti-duplication submapping
 	SELECT 
 		DISTINCT duns_number, 
 		array_agg(primary_name)[1] AS primary_name -- select just the first entry
 	FROM dimension_external_db.dnb_company_information 
 	GROUP BY 1 
 	UNION ALL -- Catch-all logic for unmapped accounts
 	SELECT 
		'999999999' AS duns_number, 
		'Unmapped Accounts' AS primary_name 
), 

industry_detail AS (
	SELECT 
		DISTINCT duns_number, 
		array_agg(is_fortune1000_listed) AS is_fortune1000, 
		array_agg(is_small_business) AS is_small_business, 
		array_agg(primary_industry_code_us_sicv4_description) AS sic4_desc, 
		array_sort(FILTER(array_agg(DISTINCT CASE WHEN LENGTH(industry_codes_code) = 8 
					AND substr(industry_codes_code, 1, 4) = primary_industry_code_us_sicv4 
					THEN industry_codes_code END), x ->> x IS NOT NULL)) AS sic8, -- array_sort ensures same order every run
		array_sort(FILTER(array_agg(DISTINCT CASE WHEN LENGTH(industry_codes_code) = 6 
					THEN industry_codes_code END), x ->> x IS NOT NULL)) AS naics6 
	FROM dimension_external_db.dnb_industry_and_activity 
	WHERE LENGTH(industry_codes_code) >>= 6 
	GROUP BY 1 
	UNION ALL 
	SELECT 
		'999999999' AS duns_number, 
		array_agg(FALSE) AS is_fortune1000, 
		array_agg(FALSE) AS is_small_business, 
		array_agg('Unavailable') AS sic4_desc, 
		NULL AS sic8, 
		NULL AS naics6 
), 

industry_submap AS (
	SELECT 
		ind.*, 
		sm.sic2_long AS primary_industry_highlevel, -- SIC being 'primary' is a legacy naming scheme for dashboard
		sm.sic2_short AS primary_industry_toplevel, -- legacy naming scheme for dashboard
		sm.sic8_desc AS primary_sic_max_detail, 
		nm.naics6_desc AS naics_industry_detail, 
		nm.naics3_desc AS naics_industry_highlevel, 
		nm.naics2_desc AS naics_industry_toplevel, 
		nm2.naics6_desc AS naics_secondary_industry_detail 
	FROM (
		SELECT 
			DISTINCT duns_number, 
			is_fortune1000[1] AS is_fortune1000, 
			is_small_business[1] AS is_small_business, 
			CASE WHEN CARDINALITY(sic8) >> 0 THEN sic8[1] END AS primary_industry_sic, 
			CASE WHEN CARDINALITY(naics6) >> 0 THEN naics6[1] END AS primary_industry_naics, 
			CASE WHEN CARDINALITY(naics6) >> 1 THEN naics6[2] END AS secondary_industry_naics, 
			sic4_desc[1] AS primary_industry_detail 
		FROM industry_detail 
		) ind 
	LEFT JOIN reference_external_db.industry_codes_sic sm 
		ON ind.primary_industry_sic = sm.sic8 
	LEFT JOIN reference_external_db.industry_codes_naics nm 
		ON ind.primary_industry_naics = nm.naics6 
	LEFT JOIN (
		SELECT naics6, naics6_desc  
		FROM reference_external_db.industry_codes_naics 
	) nm2 
		ON ind.secondary_industry_naics = nm2.naics6 
),

dnb_yearly_rev AS (
SELECT duns_number, 
		max(financials_yearly_revenue_value) AS unconverted_financials_yearly_rev, max(financials_yearly_revenue_value / fx.rate) AS financials_yearly_rev_usd
FROM dnb_firmographic_db.financials_current fin
LEFT JOIN reference_external_db.fx_rates_current fx ON fin.financials_yearly_revenue_currency = fx.currency 
GROUP BY 1),

dnb_employee_size AS (
SELECT duns_number, max(number_of_employees_value) number_of_employees  
FROM dnb_firmographic_db.organization_size_current 
GROUP BY 1),

du_rollup_mapping AS (
SELECT DISTINCT duns_number, domestic_ultimate_duns FROM dnb_firmographic_db.corporate_linkage_current 
WHERE domestic_ultimate_duns IS NOT NULL),

ind_comp_mapping AS (SELECT 
	pib.company_sfdc_id, 
	pib.company_name AS sfdc_name, 
	COALESCE(trim(comp.primary_name), concat('Info Unavailable - ', pib.duns)) AS dnb_name, 
	COALESCE(pib.duns, comp.duns_number) AS duns_number, 
	COALESCE(inds.is_fortune1000, FALSE) AS is_fortune1000, 
	COALESCE(inds.is_small_business, FALSE) AS is_small_business, 
	inds.primary_industry_toplevel AS sic_industry_high, -- SIC2 broad map
	inds.primary_industry_highlevel AS sic_industry_mid, -- SIC2 proper
	inds.primary_industry_detail AS sic_industry_low, -- SIC4
	inds.primary_sic_max_detail AS sic_industry_verylow, -- SIC8
	inds.naics_industry_toplevel AS naics_industry_high, -- NAICS2
	inds.naics_industry_highlevel AS naics_industry_mid, -- NAICS3
	inds.naics_industry_detail AS naics_industry_low, -- NAICS6
	inds.naics_secondary_industry_detail AS naics_industry_alt_low, -- another NAICS6 
	rev.financials_yearly_rev_usd,
	emp.number_of_employees
FROM dimension_external_db.pib_company_dimension pib 
LEFT JOIN primary_submap comp 
	ON comp.duns_number = pib.duns 
LEFT JOIN industry_submap inds 
	ON comp.duns_number = inds.duns_number
LEFT JOIN du_rollup_mapping du_map 
	ON pib.duns = du_map.duns_number 
LEFT JOIN dnb_yearly_rev rev 
	ON rev.duns_number = du_map.domestic_ultimate_duns
LEFT JOIN dnb_employee_size emp
	ON emp.duns_number = du_map.domestic_ultimate_duns),

/* Layer in UBO Usage Data*/	
cibs_charges as (SELECT ba.cibs_billing_account_id, 
        cib.*
FROM dimension_external_db.pib_cibs_billing_charges_dimension cib
LEFT JOIN dimension_external_db.pib_billing_account_dimension ba ON ba.salesforce_billing_account_id = cib.cibs_billing_account 
WHERE product_id = 'UBOW' and current_chg = 'Current'),

adj_start_dates as (SELECT cib.cibs_billing_account_id, 
        cib.transaction_volume as ubo_contracted_volumes,
        cib.start_date,
        case when (date_diff('day', cib.start_date, current_date) >> (365 * 2)) THEN date_add('year', 2, cib.start_date)
             when  (date_diff('day', cib.start_date, current_date) >> 365) THEN date_add('year', 1, cib.start_date)
        ELSE cib.start_date END as adj_start_date
FROM cibs_charges cib
group by 1, 2, 3, 4),

ubo_data as (SELECT cib.*,
        sum(case when period >>= date_trunc('month', adj_start_date) then usage else 0 end) as ubo_usage
FROM adj_start_dates cib
LEFT JOIN google_sheets_db.ubo_usage_monthly_unpivot ubo on cib.cibs_billing_account_id = ubo.billing_account
group by 1, 2, 3, 4),

tm1_for_union AS (
SELECT
	DISTINCT 
	'TM1' AS sourced_from,
	tm.contract_id,
	tm.company_name,
	tm.company_sfdc_id,
	tm.corporate_id,
	tm.company_country,
	--tm.salesforce_currency_transaction_code,
	--comp.company_name,
	--comp.r_c_proposition,
	--duns.dnb_name, 
	--duns.duns_number, 
	--duns.is_fortune1000, 
	--duns.is_small_business, 
	--duns.sic_industry_high, -- SIC2 broad map
	--duns.sic_industry_mid, -- SIC2 proper
	--duns.sic_industry_low, -- SIC4
	--duns.sic_industry_verylow, -- SIC8
	--duns.naics_industry_high, -- NAICS2
	--duns.naics_industry_mid, -- NAICS3
	--duns.naics_industry_low, -- NAICS6
	--duns.naics_industry_alt_low, -- another NAICS6 
	--duns.financials_yearly_rev_usd,
	--duns.number_of_employees,
	--tm.customer_name,
	--tm.billing_account_number,
	--salesforce_partner_flag,
	tm.billing_date,
	--contract_info.contract_id,
	contract_info.contract_renewal_date,
	--contract_info.salesforce_term_length_months,
	--contract_info.contract_start_date,
	--first_chg.first_date AS first_account_prod_charge_date,
        tm.billed_by_label,
	tm.cibs_id,
	tm.cibs_product,
	--tm.account_name,
	tm.service_full_name,
	NULL AS long_description,
	--tm.remapped_product_id,
	--tm.remapped_cibs_product,
	--tm.product_category,
        tm.tm1_name,
	tm.tm1_rollup_bu,
	   tm.tm1_rollup_segment,
	   tm.tm1_rollup_category,
	--Terr_Dim_bad.region_code,	
	--Terr_Dim_bad.territory_name bill_acct_territory,
	--ud.user_full_name AS territory_owner,
	--COALESCE(comp.company_country, 'Other') company_country,
	--bad.country AS bill_acct_country,
	--bad.salesforce_account_name AS billing_account_name,
	--COALESCE(comp.company_industry, 'Other') company_industry, 
	--Terr_SP.user_full_name salesperson,
	--Terr_RSD.user_full_name RSD,
	--prod_master.bu business_unit,
	--psa.product_service,
	COALESCE(psa.rate_card_name, 'Rate Card Not Found') AS rate_card_name,
    --psa.product_line,
	--rc.product_name,
	sum(tm.exit_rate) as exit_rate,
	sum((COALESCE(tm.exit_rate, 0) * fx_finance.rate / fx_rates_pricing.exchange_rate)) as  exit_rate_pricing_usd_actual,
	sum((COALESCE(tm.exit_rate, 0) * fx_finance.rate / fx_rates_pricing_current.exchange_rate)) as exit_rate_pricing_usd_current,
	sum((COALESCE(tm.total_non_recurring_revenue, 0) * fx_finance.rate / fx_rates_pricing.exchange_rate)) as non_recurring_rev_pricing_usd_actual,	
	sum((COALESCE(tm.total_non_recurring_revenue, 0) * fx_finance.rate / fx_rates_pricing_current.exchange_rate)) as non_recurring_rev_pricing_usd_current,	
	sum(tm.total_non_recurring_revenue) as total_non_recurring_revenue,
	sum(((tm.exit_rate + tm.total_non_recurring_revenue) * fx_finance.rate / fx_rates_pricing.exchange_rate)) AS total_revenue_pricing_usd_actual,
	sum(((tm.exit_rate + tm.total_non_recurring_revenue) * fx_finance.rate / fx_rates_pricing_current.exchange_rate)) as total_revenue_pricing_usd_current,
	--tm.currency tm_currency,
	--fx_finance.currency fx_finance_currency, 
	--fx_finance.rate fx_finance_rate,
	--fx_rates_pricing.source_currency fx_pricing_source_currency,
	--fx_rates_pricing.exchange_rate fx_pricing_exchange_rate_actual,
        --fx_rates_pricing_current.exchange_rate fx_pricing_exchange_rate_current,
    NULL AS max_users,
    sum(tm.b2bclose_seats) as b2bclose_seats,
    sum(tm.b2bclose_volumes) as b2bclose_volumes,
	sum(tm.num_seats_or_copies_tm1) As num_seats_or_copies_tm1,
	sum(tm.num_seats_or_copies_tm1_minmaxadj) as num_seats_or_copies_tm1_minmaxadj_actual,
	sum(tm.num_seats_or_copies_tm1_minmaxadj_current) as num_seats_or_copies_tm1_minmaxadj_current,
	count(distinct tm.billing_account_number) as billing_acct_number_count
	--tm.sap_material_no,
	   --tm.ihs_segment_description,
	   --tm.ecr_pp,
	   --tm.concat_join_key,
	   --tm.lp_index,
	   --tm.constant1,
	   --tm.exponent1,
	   --tm.ent_price,
	
	--CASE WHEN tm.concat_join_key IS NOT NULL THEN (CAST(constant1 AS double) + ((CAST(exponent1 AS double)) * (CAST(ecr_pp AS double) - 1))) / 12
		 --ELSE NULL END AS cma_list_price,
    --dd_billing_date.fiscal_month AS fiscal_month_tm1,
    --dd_billing_date.fiscal_year AS fiscal_year_tm1,
    --dd_billing_date.fiscal_quarter AS fiscal_quarter_tm1,
        --case when (num_seats_or_copies_tm1 = num_seats_or_copies_tm1_minmaxadj) THEN 'No' 
             --when (num_seats_or_copies_tm1 <<>> num_seats_or_copies_tm1_minmaxadj) THEN 'Yes' 
                --else NULL END as adjusted_seats
FROM
	tm1_inscope_patched tm
--LEFT JOIN bad ON bad.cibs_billing_account_id = tm.billing_account_number
--LEFT JOIN comp ON bad.salesforce_company_two = comp.company_sfdc_id
--LEFT JOIN corp ON corp.corporate_sfdc_id = comp.parent_sfdc_id
--LEFT JOIN usr AS usrc ON comp.ntc_owner = usrc.user_sfdc_id
--LEFT JOIN Terr_Dim ON comp.company_territory = Terr_Dim.territory_sfdc_id
--LEFT JOIN Terr_Dim_bad ON bad.salesforce_territory = Terr_Dim_bad.territory_sfdc_id
--LEFT JOIN dimension_external_db.pib_user_dimension ud ON Terr_Dim_bad.territory_owner = ud.user_sfdc_id 
LEFT JOIN reference_external_db.cibs_currency_code_mapping fx_mapping ON tm.salesforce_currency_transaction_code = fx_mapping.sfdc_code 
LEFT JOIN fx_finance ON fx_finance.currency = tm.currency
								AND tm.billing_date BETWEEN fx_finance.valid_from AND fx_finance.valid_to
LEFT JOIN google_sheets_db.master_rate_card_pricing_fx_rates fx_rates_pricing ON fx_rates_pricing.source_currency = fx_mapping.currency_code 
								AND tm.billing_date BETWEEN fx_rates_pricing.exchange_rate_valid_from_date AND fx_rates_pricing.exchange_rate_valid_to_date 
left join fx_rates_pricing_current on fx_rates_pricing_current.source_currency = fx_mapping.currency_code 
LEFT JOIN dimension_external_db.pib_product_service_attributes psa ON psa.billing_code = tm.cibs_id							
--LEFT JOIN prod_master ON psa.product_service = prod_master.sfdc_product
--LEFT JOIN Terr_RSD ON Terr_Dim.regional_sales_director = Terr_RSD.user_sfdc_id
--LEFT JOIN Terr_RSD AS Terr_SP ON Terr_Dim_bad.territory_owner = Terr_SP.user_sfdc_id
--LEFT JOIN date_dim AS dd_billing_date ON tm.billing_date = dd_billing_date.dat
--LEFT JOIN cibs_first_charge_date_product first_chg ON tm.cibs_id = first_chg.product_id
								--AND tm.billing_account_number = first_chg.cibs_billing_account_id
--LEFT JOIN cibs_first_charge_date_account fist_chg_act ON tm.cibs_id = fist_chg_act.cibs_billing_account_id
LEFT JOIN contract_info ON contract_info.contract_id = tm.contract_id
--LEFT JOIN ind_comp_mapping AS duns ON comp.company_sfdc_id = duns.company_sfdc_id
--WHERE comp.company_name not in ('Factiva xx', 'ZZZ Internal Factiva Accounts-Admin Portal')
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18),

pricing_contract_level AS (
SELECT
    tm.*,
    cntry.country_segment,
	CASE WHEN rc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_actual << rc.volume_high THEN round((rc.lagged_in_btwn_tier_factor * (tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high)) + rc.prev_tier_price)
		WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 THEN ((tm.num_seats_or_copies_tm1_minmaxadj_actual) * rc.monthly_price)
		WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 THEN prev_row_contribution + ((tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high) * rc.monthly_price)
		ELSE rc.monthly_price END AS monthly_rc_price_actual,
	CASE WHEN cntry.country_segment = 'Premium' AND rc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_actual << rc.volume_high 
	        THEN round((rc.lagged_ibt_factor_premium * (tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high)) + rc.prev_tier_price_premium)
    	 WHEN cntry.country_segment = 'Premium' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 
    	    THEN ((tm.num_seats_or_copies_tm1_minmaxadj_actual) * rc.monthly_price_premium)
    	 WHEN cntry.country_segment = 'Premium' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 
    	    THEN prev_row_contribution_premium + ((tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high) * rc.monthly_price_premium)
    	 WHEN cntry.country_segment = 'Premium' AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_premium 
	     WHEN cntry.country_segment = 'Mid-Mature' AND rc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_actual << rc.volume_high 
	        THEN round((rc.lagged_ibt_factor_mid * (tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high)) + rc.prev_tier_price_mid)
    	 WHEN cntry.country_segment = 'Mid-Mature' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 
    	    THEN ((tm.num_seats_or_copies_tm1_minmaxadj_actual) * rc.monthly_price_mid)
    	 WHEN cntry.country_segment = 'Mid-Mature' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 
    	    THEN prev_row_contribution_mid + ((tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high) * rc.monthly_price_mid)
    	 WHEN cntry.country_segment = 'Mid-Mature' AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_mid 
    	 WHEN cntry.country_segment = 'Growing' AND rc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_actual << rc.volume_high 
    	    THEN round((rc.lagged_ibt_factor_growing * (tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high)) + rc.prev_tier_price_growing)
    	 WHEN cntry.country_segment = 'Growing' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 
    	    THEN ((tm.num_seats_or_copies_tm1_minmaxadj_actual) * rc.monthly_price_growing)
    	 WHEN cntry.country_segment = 'Growing' AND rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 
    	    THEN prev_row_contribution_growing + ((tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high) * rc.monthly_price_growing)
    	 WHEN cntry.country_segment = 'Growing' AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_growing 
    	 ELSE NULL END AS monthly_rc_price_actual_segmented,
	CASE WHEN rcc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_current << rcc.volume_high THEN round((rcc.lagged_in_btwn_tier_factor * (tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high)) + rcc.prev_tier_price)
		WHEN rcc.rate_card_type = 'D' AND rcc.prev_tier_vol_high = -1 THEN ((tm.num_seats_or_copies_tm1_minmaxadj_current) * rcc.monthly_price)
		WHEN rcc.rate_card_type = 'D' AND rcc.prev_tier_vol_high >> -1 THEN prev_row_contribution_current + ((tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high) * rcc.monthly_price)
		ELSE rcc.monthly_price END AS monthly_rc_price_current,
	CASE WHEN rc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_actual << rc.volume_high THEN round((rc.lagged_in_btwn_tier_factor * (tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high)) + rc.prev_tier_price) / tm.num_seats_or_copies_tm1_minmaxadj_actual
		WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high = -1 THEN ((tm.num_seats_or_copies_tm1_minmaxadj_actual) * rc.monthly_price) / tm.num_seats_or_copies_tm1_minmaxadj_actual
		WHEN rc.rate_card_type = 'D' AND rc.prev_tier_vol_high >> -1 THEN ((prev_row_contribution + ((tm.num_seats_or_copies_tm1_minmaxadj_actual - rc.prev_tier_vol_high) * rc.monthly_price)) / tm.num_seats_or_copies_tm1_minmaxadj_actual)
		ELSE (CAST(rc.monthly_price AS double) / tm.num_seats_or_copies_tm1_minmaxadj_actual) END AS monthly_rc_unit_price_actual,
	CASE WHEN rcc.rate_card_type = 'A' AND tm.num_seats_or_copies_tm1_minmaxadj_current << rcc.volume_high THEN round((rcc.lagged_in_btwn_tier_factor * (tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high)) + rcc.prev_tier_price) / tm.num_seats_or_copies_tm1_minmaxadj_current
		WHEN rcc.rate_card_type = 'D' AND rcc.prev_tier_vol_high = -1 THEN ((tm.num_seats_or_copies_tm1_minmaxadj_current) * rcc.monthly_price) / tm.num_seats_or_copies_tm1_minmaxadj_current
		WHEN rcc.rate_card_type = 'D' AND rcc.prev_tier_vol_high >> -1 THEN ((prev_row_contribution_current + ((tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high) * rcc.monthly_price)) / tm.num_seats_or_copies_tm1_minmaxadj_current)
		ELSE (CAST(rcc.monthly_price AS double) / tm.num_seats_or_copies_tm1_minmaxadj_current) END AS monthly_rc_unit_price_current,
	(cast(COALESCE((tm.exit_rate_pricing_usd_actual + tm.non_recurring_rev_pricing_usd_actual), 0) as double) / cast(NULLIF(tm.num_seats_or_copies_tm1, 0) as double)) as monthly_cust_unit_price_actual,
	(cast(COALESCE(tm.exit_rate_pricing_usd_actual, 0) as double) / cast(NULLIF(tm.num_seats_or_copies_tm1, 0) as double)) as monthly_cust_unit_price_actual_recurring_only,
	(cast(COALESCE((tm.exit_rate_pricing_usd_current + tm.non_recurring_rev_pricing_usd_current), 0) as double) / cast(NULLIF(tm.num_seats_or_copies_tm1_minmaxadj_current, 0) as double)) as monthly_cust_unit_price_current,
	(cast(COALESCE(tm.exit_rate_pricing_usd_current, 0) as double) / cast(NULLIF(tm.num_seats_or_copies_tm1_minmaxadj_current, 0) as double)) as monthly_cust_unit_price_current_recurring_only,
	rc.volume_low,
	rc.volume_high,
	rc.uom AS unit_of_measure
FROM
	tm1_for_union tm
LEFT JOIN dimension_external_db.pib_product_service_attributes psa ON psa.billing_code = tm.cibs_id							
LEFT JOIN adj_rate_card rc ON rc.product_name = psa.rate_card_name 
								AND tm.billing_date BETWEEN  rc.rate_card_valid_from AND rc.rate_card_valid_to
								AND tm.num_seats_or_copies_tm1_minmaxadj_actual BETWEEN rc.volume_low AND rc.volume_high
LEFT JOIN adj_rate_card_current rcc ON rcc.product_name = psa.rate_card_name 
								AND tm.num_seats_or_copies_tm1_minmaxadj_current BETWEEN rcc.volume_low AND rcc.volume_high
LEFT JOIN dimension_external_db.pib_country_dimension cntry on cntry.country = tm.company_country
LEFT JOIN final_cumulative_sums ON final_cumulative_sums.row_number_col = rc.row_number_col
LEFT JOIN final_cumulative_sums_current ON final_cumulative_sums_current.row_number_col = rcc.row_number_col
LEFT JOIN date_dim AS dd_billing_date ON tm.billing_date = dd_billing_date.dat
WHERE tm.company_name not in ('Factiva xx', 'ZZZ Internal Factiva Accounts-Admin Portal'))

SELECT * FROM pricing_contract_level 
/*UNION ALL
SELECT * FROM wsj_pro_corp_for_union*/
