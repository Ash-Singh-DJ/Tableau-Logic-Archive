-- Dashboard   : "[SANDBOX] BA TM1 (Athena)"  [B2B / B2B Pricing / ARCHIVE / Sandbox Folder]
-- Data source : "Historical Pricing TM1" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH comp AS (
	SELECT DISTINCT company_sfdc_id,
		company_name,
		company_industry,
		company_country,
		company_territory,
		parent_sfdc_id,
		r_c_proposition,
		third_party_partner_flag,
		relationship_type,
		goverment_account_flag
	FROM dimension_external_db.pib_company_dimension
	WHERE status_flag <<>> 'DELETE'
),
corp AS (
	SELECT DISTINCT corporate_name,
		corporate_sfdc_id,
		corporate_id
	FROM dimension_external_db.pib_corporate_dimension
),
bad AS (
	SELECT DISTINCT salesforce_billing_account_id,
		cibs_billing_account_id,
		salesforce_company_two,
		salesforce_territory,
		salesforce_currency_transaction_code,
		country,
		salesforce_country,
		salesforce_account_name,
		salesforce_contract_renewal_date
	FROM dimension_external_db.pib_billing_account_dimension
),
Terr_Dim AS (
	SELECT territory_sfdc_id,
		regional_sales_director
	FROM dimension_external_db.pib_territory_dimension
),
Terr_Dim_bad AS (
	SELECT territory_sfdc_id,
		territory_name,
		territory_owner,
		region_code
	FROM dimension_external_db.pib_territory_dimension
),
Terr_RSD AS (
	SELECT user_sfdc_id,
		user_full_name
	FROM dimension_external_db.pib_user_dimension
),
cpr AS (
	SELECT DISTINCT num_seats,
		trans_vol_flag,
		product_id AS cibs_product_id,
		CASE
			WHEN num_seats = 'Y'
			AND (
				trans_vol_flag = 'N'
				OR COALESCE(trans_vol_flag, '') = ''
			) THEN 'Seats'
			WHEN trans_vol_flag = 'Y'
			AND (
				num_seats = 'N'
				OR COALESCE(num_seats, '') = ''
			) THEN 'Volume'
			WHEN num_seats = 'Y'
			AND trans_vol_flag = 'Y' THEN 'Seats and Volume' ELSE NULL
		END AS billed_by_label
	FROM finance_external_db.cibs_products_rules
	WHERE cycle_date = (
			SELECT MAX(cycle_date)
			FROM finance_external_db.cibs_products_rules
		)
),
GENERATED_CTE_1 AS (
	SELECT product_id,
		service_product_id
	FROM finance_external_db.cibs_products
	WHERE cycle_date = (
			SELECT MAX(cycle_date)
			FROM finance_external_db.cibs_products
		)
),
mattg_tm1_inny AS (
	SELECT DISTINCT cgl.cycle_date AS billing_month,
		cgl.billing_account_number,
		cgl.product_id AS cibs_product_id,
		cpr.billed_by_label,
		cpr.num_seats AS cibs_product_rules_num_seats,
		cpr.trans_vol_flag AS cibs_product_rules_trans_vol_flag,
		CASE
			WHEN cpr.billed_by_label IN ('Seats', 'Seats and Volume')
			OR cpr.billed_by_label IS NULL THEN cgl.number_of_user_seats
		END AS number_of_user_seats,
		CASE
			WHEN cpr.billed_by_label IN ('Volume', 'Seats and Volume')
			OR cpr.billed_by_label IS NULL THEN cgl.users_transaction_volume
		END AS users_transaction_volume
	FROM finance_external_db.tm1_cibs_gltransrel AS cgl
		LEFT JOIN cpr ON cgl.product_id = cpr.cibs_product_id
		LEFT JOIN GENERATED_CTE_1 AS cp_parent ON cgl.product_id = cp_parent.service_product_id
	WHERE LOWER(cgl.revenue_type_id) LIKE '%rev%'
),
djx_volume_subquery AS (
	SELECT cycle_date,
		billing_account_number,
		product_id,
		COUNT(*) / 2 AS seats_count
	FROM finance_external_db.tm1_cibs_gltransrel
	WHERE LOWER(revenue_type_id) LIKE '%rev%'
	GROUP BY cycle_date,
		billing_account_number,
		product_id
),
mattg_tm1_pre AS (
	SELECT billing_month,
		billing_account_number,
		cibs_product_id,
		billed_by_label,
		cibs_product_rules_num_seats,
		cibs_product_rules_trans_vol_flag,
		SUM(number_of_user_seats) AS number_of_user_seats,
		SUM(users_transaction_volume) AS users_transaction_volume
	FROM mattg_tm1_inny
	GROUP BY billing_month,
		billing_account_number,
		cibs_product_id,
		billed_by_label,
		cibs_product_rules_num_seats,
		cibs_product_rules_trans_vol_flag
),
mattg_tm1 AS (
	SELECT billing_month,
		mg.billing_account_number,
		cibs_product_id,
		billed_by_label,
		cibs_product_rules_num_seats,
		cibs_product_rules_trans_vol_flag,
		COALESCE(mg.number_of_user_seats, djx.seats_count) AS number_of_user_seats,
		mg.users_transaction_volume
	FROM mattg_tm1_pre AS mg
		LEFT JOIN djx_volume_subquery AS djx ON mg.billing_month = djx.cycle_date
		AND mg.billing_account_number = djx.billing_account_number
		AND mg.cibs_product_id = djx.product_id
),
rate_card_simplified AS (
	SELECT DISTINCT product_name,
		rate_card_valid_from,
		rate_card_valid_to,
		min_order_quantity,
		max_order_quantity
	FROM google_sheets_db.master_rate_card_table_cp_datateam
),
rate_card_simplified_current AS (
	SELECT DISTINCT product_name,
		min_order_quantity,
		max_order_quantity
	FROM google_sheets_db.master_rate_card_table_cp_datateam
	WHERE rate_card_valid_to >> DATE('9999-01-01')
),
GENERATED_CTE_2 AS (
	SELECT service_product_id,
		COUNT(*) AS rowcount
	FROM finance_external_db.cibs_products AS cp
	WHERE cycle_date = (
			SELECT MAX(cycle_date)
			FROM finance_external_db.cibs_products
		)
		AND product_id NOT IN (
			SELECT DISTINCT free_month_product_id
			FROM finance_external_db.cibs_products
			WHERE cycle_date = (
					SELECT MAX(cycle_date)
					FROM finance_external_db.cibs_products
				)
		)
	GROUP BY service_product_id
),
relevant_service_ids AS (
	SELECT service_product_id
	FROM GENERATED_CTE_2
	WHERE rowcount = 1
),
service_id_prod_id_mapping AS (
	SELECT relevant_service_ids.service_product_id,
		cp.product_id,
		cp."desc"
	FROM finance_external_db.cibs_products AS cp
		INNER JOIN relevant_service_ids ON relevant_service_ids.service_product_id = cp.service_product_id
	WHERE cycle_date = (
			SELECT MAX(cycle_date)
			FROM finance_external_db.cibs_products
		)
		AND product_id NOT IN (
			SELECT DISTINCT free_month_product_id
			FROM finance_external_db.cibs_products
			WHERE cycle_date = (
					SELECT MAX(cycle_date)
					FROM finance_external_db.cibs_products
				)
		)
),
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
		COALESCE(cp.product_id, cibs_id) AS remapped_product_id,
		COALESCE(cp."desc", cibs_product) AS remapped_cibs_product,
		psa.service_full_name,
		user_trans_vol,
		num_user_seats,
		mattg_tm1.number_of_user_seats AS b2bclose_seats,
		mattg_tm1.users_transaction_volume AS b2bclose_volumes,
		CASE
			WHEN cp.service_product_id IS NOT NULL THEN 0 ELSE COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			)
		END AS num_seats_or_copies_tm1,
		CASE
			WHEN cp.service_product_id IS NOT NULL THEN 0
			WHEN rc.min_order_quantity >> COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			) THEN rc.min_order_quantity
			WHEN rc.max_order_quantity << COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			) THEN rc.max_order_quantity ELSE COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			)
		END AS num_seats_or_copies_tm1_minmaxadj,
		CASE
			WHEN cp.service_product_id IS NOT NULL THEN 0
			WHEN rcc.min_order_quantity >> COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			) THEN rcc.min_order_quantity
			WHEN rcc.max_order_quantity << COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			) THEN rcc.max_order_quantity ELSE COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			)
		END AS num_seats_or_copies_tm1_minmaxadj_current,
		SUM(exit_rate) AS exit_rate,
		SUM(total_non_recurring_revenue) AS total_non_recurring_revenue
	FROM fact_external_db.tm1_fact AS tm
		LEFT JOIN service_id_prod_id_mapping AS cp ON tm.cibs_id = cp.service_product_id
		LEFT JOIN dimension_external_db.pib_product_service_attributes AS psa ON psa.billing_code = COALESCE(cp.product_id, tm.cibs_id)
		LEFT JOIN rate_card_simplified AS rc ON rc.product_name = psa.rate_card_name
		AND tm.billing_date BETWEEN rc.rate_card_valid_from AND rc.rate_card_valid_to
		LEFT JOIN rate_card_simplified_current AS rcc ON rcc.product_name = psa.rate_card_name
		LEFT JOIN mattg_tm1 ON mattg_tm1.billing_month = tm.billing_date
		AND mattg_tm1.billing_account_number = tm.billing_account_number
		AND mattg_tm1.cibs_product_id = COALESCE(cp.product_id, tm.cibs_id)
	WHERE billing_date >>= DATE('2022-10-01')
		AND NOT (
			tm.billing_account_number = '9FRE006300'
			AND cibs_id = 'PRDX'
		)
		AND NOT (
			tm.billing_account_number = '9FRE006300'
			AND cibs_id = 'RDSE'
		)
		AND NOT (
			tm.billing_account_number = '9FRE006200'
			AND cibs_id = 'RDSE'
		)
	GROUP BY customer_name,
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
		COALESCE(cp.product_id, cibs_id),
		COALESCE(cp."desc", cibs_product),
		psa.service_full_name,
		user_trans_vol,
		num_user_seats,
		mattg_tm1.number_of_user_seats,
		mattg_tm1.users_transaction_volume,
		CASE
			WHEN cp.service_product_id IS NOT NULL THEN 0 ELSE COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			)
		END,
		CASE
			WHEN cp.service_product_id IS NOT NULL THEN 0
			WHEN rc.min_order_quantity >> COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			) THEN rc.min_order_quantity
			WHEN rc.max_order_quantity << COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			) THEN rc.max_order_quantity ELSE COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			)
		END,
		CASE
			WHEN cp.service_product_id IS NOT NULL THEN 0
			WHEN rcc.min_order_quantity >> COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			) THEN rcc.min_order_quantity
			WHEN rcc.max_order_quantity << COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			) THEN rcc.max_order_quantity ELSE COALESCE(
				COALESCE(
					NULLIF(mattg_tm1.users_transaction_volume, 0),
					NULLIF(mattg_tm1.number_of_user_seats, 0)
				),
				1
			)
		END
),
tm1_inscope_patched AS (
	SELECT tm.customer_name,
		tm.billing_account_number,
		tm.billing_date,
		tm.billed_by_label,
		tm.tm1_name,
		tm.account_name,
		tm.currency,
		tm.tm1_rollup_bu,
		tm.tm1_rollup_segment,
		tm.tm1_rollup_category,
		tm.remapped_product_id AS cibs_id,
		tm.remapped_cibs_product AS cibs_product,
		tm.service_full_name,
		COALESCE(NULLIF(SUM(b2bclose_seats), 0), 1) AS b2bclose_seats,
		COALESCE(NULLIF(SUM(b2bclose_volumes), 0), 1) AS b2bclose_volumes,
		COALESCE(NULLIF(SUM(num_seats_or_copies_tm1), 0), 1) AS num_seats_or_copies_tm1,
		COALESCE(
			NULLIF(SUM(num_seats_or_copies_tm1_minmaxadj), 0),
			1
		) AS num_seats_or_copies_tm1_minmaxadj,
		COALESCE(
			NULLIF(
				SUM(num_seats_or_copies_tm1_minmaxadj_current),
				0
			),
			1
		) AS num_seats_or_copies_tm1_minmaxadj_current,
		SUM(exit_rate) AS exit_rate,
		SUM(total_non_recurring_revenue) AS total_non_recurring_revenue
	FROM tm1_inscope AS tm
	GROUP BY tm.customer_name,
		tm.billing_account_number,
		tm.billing_date,
		tm.billed_by_label,
		tm.tm1_name,
		tm.account_name,
		tm.product_category,
		tm.currency,
		tm.tm1_rollup_bu,
		tm.tm1_rollup_segment,
		tm.tm1_rollup_category,
		tm.remapped_product_id,
		tm.remapped_cibs_product,
		tm.service_full_name
),
cibs_first_charge_date_product AS (
	SELECT bad.cibs_billing_account_id,
		cib.product_id,
		MIN(start_date) AS first_date
	FROM dimension_external_db.pib_cibs_billing_charges_dimension AS cib
		LEFT JOIN dimension_external_db.pib_billing_account_dimension AS bad ON bad.salesforce_billing_account_id = cib.cibs_billing_account
	WHERE current_chg <<>> 'Cancelled'
	GROUP BY bad.cibs_billing_account_id,
		cib.product_id
),
rate_card AS (
	SELECT rate_card_type,
		product_name,
		volume_low,
		volume_high,
		uom,
		monthly_price,
		in_between_tier_pricing_factor,
		additional_volume_dimension,
		additional_volume_unit,
		additional_price,
		rate_card_valid_from,
		rate_card_valid_to,
		policy,
		min_order_quantity,
		max_order_quantity,
		line,
		max_order_quantity_public,
		monthly_price_growing,
		ibt_factor_growing,
		monthly_price_mid,
		ibt_factor_mid,
		monthly_price_premium,
		ibt_factor_premium,
		match,
		ROW_NUMBER() OVER (
			ORDER BY rate_card_valid_from,
				product_name,
				volume_low
		) AS row_number_col
	FROM google_sheets_db.master_rate_card_table_cp_datateam
),
rate_card_current AS (
	SELECT rate_card_type,
		product_name,
		volume_low,
		volume_high,
		uom,
		monthly_price,
		in_between_tier_pricing_factor,
		additional_volume_dimension,
		additional_volume_unit,
		additional_price,
		rate_card_valid_from,
		rate_card_valid_to,
		policy,
		min_order_quantity,
		max_order_quantity,
		line,
		max_order_quantity_public,
		monthly_price_growing,
		ibt_factor_growing,
		monthly_price_mid,
		ibt_factor_mid,
		monthly_price_premium,
		ibt_factor_premium,
		match,
		ROW_NUMBER() OVER (
			ORDER BY rate_card_valid_from,
				product_name,
				volume_low
		) AS row_number_col
	FROM google_sheets_db.master_rate_card_table_cp_datateam
	WHERE rate_card_valid_to >> DATE('9999-01-01')
),
led_row_tbl AS (
	SELECT rate_card.rate_card_type,
		rate_card.product_name,
		rate_card.volume_low,
		rate_card.volume_high,
		rate_card.uom,
		rate_card.monthly_price,
		rate_card.in_between_tier_pricing_factor,
		rate_card.additional_volume_dimension,
		rate_card.additional_volume_unit,
		rate_card.additional_price,
		rate_card.rate_card_valid_from,
		rate_card.rate_card_valid_to,
		rate_card.policy,
		rate_card.min_order_quantity,
		rate_card.max_order_quantity,
		rate_card.line,
		rate_card.max_order_quantity_public,
		rate_card.monthly_price_growing,
		rate_card.ibt_factor_growing,
		rate_card.monthly_price_mid,
		rate_card.ibt_factor_mid,
		rate_card.monthly_price_premium,
		rate_card.ibt_factor_premium,
		rate_card.match,
		rate_card.row_number_col,
		LEAD(row_number_col) OVER (
			ORDER BY row_number_col
		) AS led_row
	FROM rate_card
),
led_row_tbl_current AS (
	SELECT rate_card_current.rate_card_type,
		rate_card_current.product_name,
		rate_card_current.volume_low,
		rate_card_current.volume_high,
		rate_card_current.uom,
		rate_card_current.monthly_price,
		rate_card_current.in_between_tier_pricing_factor,
		rate_card_current.additional_volume_dimension,
		rate_card_current.additional_volume_unit,
		rate_card_current.additional_price,
		rate_card_current.rate_card_valid_from,
		rate_card_current.rate_card_valid_to,
		rate_card_current.policy,
		rate_card_current.min_order_quantity,
		rate_card_current.max_order_quantity,
		rate_card_current.line,
		rate_card_current.max_order_quantity_public,
		rate_card_current.monthly_price_growing,
		rate_card_current.ibt_factor_growing,
		rate_card_current.monthly_price_mid,
		rate_card_current.ibt_factor_mid,
		rate_card_current.monthly_price_premium,
		rate_card_current.ibt_factor_premium,
		rate_card_current.match,
		rate_card_current.row_number_col,
		LEAD(row_number_col) OVER (
			ORDER BY row_number_col
		) AS led_row
	FROM rate_card_current
),
adj_rate_card AS (
	SELECT rate_card.rate_card_type,
		rate_card.product_name,
		rate_card.volume_low,
		rate_card.volume_high,
		rate_card.uom,
		rate_card.monthly_price,
		rate_card.rate_card_valid_from,
		rate_card.rate_card_valid_to,
		rate_card.monthly_price_growing,
		rate_card.monthly_price_mid,
		rate_card.monthly_price_premium,
		rate_card.row_number_col,
		lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor,
		lag.ibt_factor_growing AS lagged_ibt_factor_growing,
		lag.ibt_factor_mid AS lagged_ibt_factor_mid,
		lag.ibt_factor_premium AS lagged_ibt_factor_premium,
		lag.volume_high AS prev_tier_vol_high,
		lag.monthly_price AS prev_tier_price,
		lag.monthly_price_premium AS prev_tier_price_premium,
		lag.monthly_price_mid AS prev_tier_price_mid,
		lag.monthly_price_growing AS prev_tier_price_growing
	FROM rate_card
		LEFT JOIN led_row_tbl AS lag ON lag.led_row = rate_card.row_number_col
),
adj_rate_card_current AS (
	SELECT rate_card_current.rate_card_type,
		rate_card_current.product_name,
		rate_card_current.volume_low,
		rate_card_current.volume_high,
		rate_card_current.monthly_price,
		rate_card_current.row_number_col,
		lag.in_between_tier_pricing_factor AS lagged_in_btwn_tier_factor,
		lag.volume_high AS prev_tier_vol_high,
		lag.monthly_price AS prev_tier_price
	FROM rate_card_current
		LEFT JOIN led_row_tbl_current AS lag ON lag.led_row = rate_card_current.row_number_col
),
partial_sums AS (
	SELECT rate_card.rate_card_type,
		rate_card.product_name,
		rate_card.volume_low,
		rate_card.volume_high,
		rate_card.monthly_price,
		rate_card.monthly_price_growing,
		rate_card.monthly_price_mid,
		rate_card.monthly_price_premium,
		rate_card.rate_card_valid_from,
		rate_card.row_number_col,
		lag.volume_high AS prev_tier_vol_high,
		lag.monthly_price AS prev_tier_price,
		lag.monthly_price_premium AS prev_tier_price_premium,
		lag.monthly_price_mid AS prev_tier_price_mid,
		lag.monthly_price_growing AS prev_tier_price_growing,
		CASE
			WHEN lag.volume_high = -1 THEN CAST(rate_card.volume_high AS BIGINT) * rate_card.monthly_price ELSE (
				CAST(rate_card.volume_high AS BIGINT) - lag.volume_high
			) * rate_card.monthly_price
		END AS tier_price_contribution,
		CASE
			WHEN lag.volume_high = -1 THEN CAST(rate_card.volume_high AS BIGINT) * rate_card.monthly_price_premium ELSE (
				CAST(rate_card.volume_high AS BIGINT) - lag.volume_high
			) * rate_card.monthly_price_premium
		END AS tier_price_contribution_premium,
		CASE
			WHEN lag.volume_high = -1 THEN CAST(rate_card.volume_high AS BIGINT) * rate_card.monthly_price_mid ELSE (
				CAST(rate_card.volume_high AS BIGINT) - lag.volume_high
			) * rate_card.monthly_price_mid
		END AS tier_price_contribution_mid,
		CASE
			WHEN lag.volume_high = -1 THEN CAST(rate_card.volume_high AS BIGINT) * rate_card.monthly_price_growing ELSE (
				CAST(rate_card.volume_high AS BIGINT) - lag.volume_high
			) * rate_card.monthly_price_growing
		END AS tier_price_contribution_growing
	FROM rate_card
		LEFT JOIN led_row_tbl AS lag ON lag.led_row = rate_card.row_number_col
	WHERE rate_card.rate_card_type = 'D'
),
partial_sums_current AS (
	SELECT rate_card_current.rate_card_type,
		rate_card_current.product_name,
		rate_card_current.volume_low,
		rate_card_current.volume_high,
		rate_card_current.monthly_price,
		rate_card_current.monthly_price_growing,
		rate_card_current.monthly_price_mid,
		rate_card_current.monthly_price_premium,
		rate_card_current.rate_card_valid_from,
		rate_card_current.row_number_col,
		lag.volume_high AS prev_tier_vol_high,
		lag.monthly_price AS prev_tier_price,
		lag.monthly_price_premium AS prev_tier_price_premium,
		lag.monthly_price_mid AS prev_tier_price_mid,
		lag.monthly_price_growing AS prev_tier_price_growing,
		CASE
			WHEN lag.volume_high = -1 THEN CAST(rate_card_current.volume_high AS BIGINT) * rate_card_current.monthly_price ELSE (
				CAST(rate_card_current.volume_high AS BIGINT) - lag.volume_high
			) * rate_card_current.monthly_price
		END AS tier_price_contribution,
		CASE
			WHEN lag.volume_high = -1 THEN CAST(rate_card_current.volume_high AS BIGINT) * rate_card_current.monthly_price_premium ELSE (
				CAST(rate_card_current.volume_high AS BIGINT) - lag.volume_high
			) * rate_card_current.monthly_price_premium
		END AS tier_price_contribution_premium,
		CASE
			WHEN lag.volume_high = -1 THEN CAST(rate_card_current.volume_high AS BIGINT) * rate_card_current.monthly_price_mid ELSE (
				CAST(rate_card_current.volume_high AS BIGINT) - lag.volume_high
			) * rate_card_current.monthly_price_mid
		END AS tier_price_contribution_mid,
		CASE
			WHEN lag.volume_high = -1 THEN CAST(rate_card_current.volume_high AS BIGINT) * rate_card_current.monthly_price_growing ELSE (
				CAST(rate_card_current.volume_high AS BIGINT) - lag.volume_high
			) * rate_card_current.monthly_price_growing
		END AS tier_price_contribution_growing
	FROM rate_card_current
		LEFT JOIN led_row_tbl_current AS lag ON lag.led_row = rate_card_current.row_number_col
	WHERE rate_card_current.rate_card_type = 'D'
),
cumulative_sums AS (
	SELECT partial_sums.rate_card_type,
		partial_sums.product_name,
		partial_sums.volume_low,
		partial_sums.volume_high,
		partial_sums.monthly_price,
		partial_sums.monthly_price_growing,
		partial_sums.monthly_price_mid,
		partial_sums.monthly_price_premium,
		partial_sums.rate_card_valid_from,
		partial_sums.row_number_col,
		partial_sums.prev_tier_vol_high,
		partial_sums.tier_price_contribution,
		partial_sums.tier_price_contribution_premium,
		partial_sums.tier_price_contribution_mid,
		partial_sums.tier_price_contribution_growing,
		SUM(tier_price_contribution) OVER (
			PARTITION BY rate_card_valid_from,
			product_name
			ORDER BY row_number_col
		) AS cumulative_tier_price_contribution,
		SUM(tier_price_contribution_premium) OVER (
			PARTITION BY rate_card_valid_from,
			product_name
			ORDER BY row_number_col
		) AS cumulative_tier_price_contribution_premium,
		SUM(tier_price_contribution_mid) OVER (
			PARTITION BY rate_card_valid_from,
			product_name
			ORDER BY row_number_col
		) AS cumulative_tier_price_contribution_mid,
		SUM(tier_price_contribution_growing) OVER (
			PARTITION BY rate_card_valid_from,
			product_name
			ORDER BY row_number_col
		) AS cumulative_tier_price_contribution_growing
	FROM partial_sums
),
cumulative_sums_current AS (
	SELECT partial_sums_current.rate_card_type,
		partial_sums_current.product_name,
		partial_sums_current.volume_low,
		partial_sums_current.volume_high,
		partial_sums_current.monthly_price,
		partial_sums_current.monthly_price_growing,
		partial_sums_current.monthly_price_mid,
		partial_sums_current.monthly_price_premium,
		partial_sums_current.rate_card_valid_from,
		partial_sums_current.row_number_col,
		partial_sums_current.prev_tier_vol_high,
		partial_sums_current.tier_price_contribution,
		partial_sums_current.tier_price_contribution_premium,
		partial_sums_current.tier_price_contribution_mid,
		partial_sums_current.tier_price_contribution_growing,
		SUM(tier_price_contribution) OVER (
			PARTITION BY rate_card_valid_from,
			product_name
			ORDER BY row_number_col
		) AS cumulative_tier_price_contribution,
		SUM(tier_price_contribution_premium) OVER (
			PARTITION BY rate_card_valid_from,
			product_name
			ORDER BY row_number_col
		) AS cumulative_tier_price_contribution_premium,
		SUM(tier_price_contribution_mid) OVER (
			PARTITION BY rate_card_valid_from,
			product_name
			ORDER BY row_number_col
		) AS cumulative_tier_price_contribution_mid,
		SUM(tier_price_contribution_growing) OVER (
			PARTITION BY rate_card_valid_from,
			product_name
			ORDER BY row_number_col
		) AS cumulative_tier_price_contribution_growing
	FROM partial_sums_current
),
final_cumulative_sums AS (
	SELECT cumulative_sums.rate_card_type,
		cumulative_sums.product_name,
		cumulative_sums.volume_low,
		cumulative_sums.volume_high,
		cumulative_sums.monthly_price,
		cumulative_sums.monthly_price_growing,
		cumulative_sums.monthly_price_mid,
		cumulative_sums.monthly_price_premium,
		cumulative_sums.rate_card_valid_from,
		cumulative_sums.row_number_col,
		cumulative_sums.prev_tier_vol_high,
		cumulative_sums.cumulative_tier_price_contribution,
		cumulative_sums.cumulative_tier_price_contribution_premium,
		cumulative_sums.cumulative_tier_price_contribution_mid,
		cumulative_sums.cumulative_tier_price_contribution_growing,
		LAG(cumulative_tier_price_contribution) OVER (
			ORDER BY row_number_col
		) AS prev_row_contribution,
		LAG(cumulative_tier_price_contribution_premium) OVER (
			ORDER BY row_number_col
		) AS prev_row_contribution_premium,
		LAG(cumulative_tier_price_contribution_mid) OVER (
			ORDER BY row_number_col
		) AS prev_row_contribution_mid,
		LAG(cumulative_tier_price_contribution_growing) OVER (
			ORDER BY row_number_col
		) AS prev_row_contribution_growing
	FROM cumulative_sums
),
final_cumulative_sums_current AS (
	SELECT cumulative_sums_current.rate_card_type,
		cumulative_sums_current.product_name,
		cumulative_sums_current.volume_low,
		cumulative_sums_current.volume_high,
		cumulative_sums_current.monthly_price,
		cumulative_sums_current.monthly_price_growing,
		cumulative_sums_current.monthly_price_mid,
		cumulative_sums_current.monthly_price_premium,
		cumulative_sums_current.rate_card_valid_from,
		cumulative_sums_current.row_number_col,
		cumulative_sums_current.prev_tier_vol_high,
		cumulative_sums_current.cumulative_tier_price_contribution,
		cumulative_sums_current.cumulative_tier_price_contribution_premium,
		cumulative_sums_current.cumulative_tier_price_contribution_mid,
		cumulative_sums_current.cumulative_tier_price_contribution_growing,
		LAG(cumulative_tier_price_contribution) OVER (
			ORDER BY row_number_col
		) AS prev_row_contribution_current,
		LAG(cumulative_tier_price_contribution_premium) OVER (
			ORDER BY row_number_col
		) AS prev_row_contribution_current_premium,
		LAG(cumulative_tier_price_contribution_mid) OVER (
			ORDER BY row_number_col
		) AS prev_row_contribution_current_mid,
		LAG(cumulative_tier_price_contribution_growing) OVER (
			ORDER BY row_number_col
		) AS prev_row_contribution_current_growing
	FROM cumulative_sums_current
),
contract_max_modified_dates AS (
	SELECT bad.cibs_billing_account_id,
		con.contract_id,
		MAX(con.last_change_date) AS most_recent_last_change_date
	FROM dimension_external_db.pib_contract_dimension AS con
		JOIN dimension_external_db.pib_billing_account_dimension AS bad ON con.contract_id = bad.contract_id
	GROUP BY bad.cibs_billing_account_id,
		con.contract_id
),
contract_info AS (
	SELECT cibs_billing_account_id,
		con.contract_id,
		con.salesforce_auto_renewal_flag,
		MAX(con.salesforce_term_length_months) AS salesforce_term_length_months,
		MAX(contract_start_date) AS contract_start_date
	FROM contract_max_modified_dates AS mod
		JOIN dimension_external_db.pib_contract_dimension AS con ON con.contract_id = mod.contract_id
		AND con.last_change_date = mod.most_recent_last_change_date
	WHERE salesforce_auto_renewal_flag IS NOT NULL
	GROUP BY cibs_billing_account_id,
		con.contract_id,
		con.salesforce_auto_renewal_flag
),
GENERATED_CTE_4 AS (
	SELECT currency,
		rate,
		year
	FROM reference_external_db.fx_rates_history
),
fx_finance AS (
	SELECT currency,
		rate,
		CAST(
			CONCAT(
				CAST((CAST(year AS INTEGER) - 1) AS VARCHAR),
				'-07-01'
			) AS DATE
		) AS valid_from,
		CAST(CONCAT(year, '-06-30') AS DATE) AS valid_to
	FROM GENERATED_CTE_4
),
fx_rates_pricing_current AS (
	SELECT source_currency,
		exchange_rate
	FROM google_sheets_db.master_rate_card_pricing_fx_rates
	WHERE exchange_rate_valid_to_date >> DATE('9999-01-01')
),
primary_submap AS (
	SELECT DISTINCT duns_number,
		ARRAY_AGG(primary_name) [ 1 ] AS primary_name
	FROM dimension_external_db.dnb_company_information
	GROUP BY duns_number
	UNION ALL
	SELECT '999999999' AS duns_number,
		'Unmapped Accounts' AS primary_name
),
industry_detail AS (
	SELECT DISTINCT duns_number,
		ARRAY_AGG(is_fortune1000_listed) AS is_fortune1000,
		ARRAY_AGG(is_small_business) AS is_small_business,
		ARRAY_AGG(primary_industry_code_us_sicv4_description) AS sic4_desc,
		ARRAY_SORT(
			FILTER(
				ARRAY_AGG(
					DISTINCT CASE
						WHEN LENGTH(industry_codes_code) = 8
						AND SUBSTRING(industry_codes_code, 1, 4) = primary_industry_code_us_sicv4 THEN industry_codes_code
					END
				),
				x->>x IS NOT NULL
			)
		) AS sic8,
		ARRAY_SORT(
			FILTER(
				ARRAY_AGG(
					DISTINCT CASE
						WHEN LENGTH(industry_codes_code) = 6 THEN industry_codes_code
					END
				),
				x->>x IS NOT NULL
			)
		) AS naics6
	FROM dimension_external_db.dnb_industry_and_activity
	WHERE LENGTH(industry_codes_code) >>= 6
	GROUP BY duns_number
	UNION ALL
	SELECT '999999999' AS duns_number,
		ARRAY_AGG(FALSE) AS is_fortune1000,
		ARRAY_AGG(FALSE) AS is_small_business,
		ARRAY_AGG('Unavailable') AS sic4_desc,
		NULL AS sic8,
		NULL AS naics6
),
GENERATED_CTE_5 AS (
	SELECT DISTINCT duns_number,
		is_fortune1000 [ 1 ] AS is_fortune1000,
		is_small_business [ 1 ] AS is_small_business,
		CASE
			WHEN CARDINALITY(sic8) >> 0 THEN sic8 [ 1 ]
		END AS primary_industry_sic,
		CASE
			WHEN CARDINALITY(naics6) >> 0 THEN naics6 [ 1 ]
		END AS primary_industry_naics,
		CASE
			WHEN CARDINALITY(naics6) >> 1 THEN naics6 [ 2 ]
		END AS secondary_industry_naics,
		sic4_desc [ 1 ] AS primary_industry_detail
	FROM industry_detail
),
GENERATED_CTE_6 AS (
	SELECT naics6,
		naics6_desc
	FROM reference_external_db.industry_codes_naics
),
industry_submap AS (
	SELECT ind.duns_number,
		ind.is_fortune1000,
		ind.is_small_business,
		ind.primary_industry_detail,
		sm.sic2_long AS primary_industry_highlevel,
		sm.sic2_short AS primary_industry_toplevel,
		sm.sic8_desc AS primary_sic_max_detail,
		nm.naics6_desc AS naics_industry_detail,
		nm.naics3_desc AS naics_industry_highlevel,
		nm.naics2_desc AS naics_industry_toplevel,
		nm2.naics6_desc AS naics_secondary_industry_detail
	FROM GENERATED_CTE_5 AS ind
		LEFT JOIN reference_external_db.industry_codes_sic AS sm ON ind.primary_industry_sic = sm.sic8
		LEFT JOIN reference_external_db.industry_codes_naics AS nm ON ind.primary_industry_naics = nm.naics6
		LEFT JOIN GENERATED_CTE_6 AS nm2 ON ind.secondary_industry_naics = nm2.naics6
),
dnb_yearly_rev AS (
	SELECT duns_number,
		MAX(financials_yearly_revenue_value / fx.rate) AS financials_yearly_rev_usd
	FROM dnb_firmographic_db.financials_current AS fin
		LEFT JOIN reference_external_db.fx_rates_current AS fx ON fin.financials_yearly_revenue_currency = fx.currency
	GROUP BY duns_number
),
dnb_employee_size AS (
	SELECT duns_number,
		MAX(number_of_employees_value) AS number_of_employees
	FROM dnb_firmographic_db.organization_size_current
	GROUP BY duns_number
),
du_rollup_mapping AS (
	SELECT DISTINCT duns_number,
		domestic_ultimate_duns
	FROM dnb_firmographic_db.corporate_linkage_current
	WHERE domestic_ultimate_duns IS NOT NULL
),
ind_comp_mapping AS (
	SELECT pib.company_sfdc_id,
		COALESCE(
			TRIM(comp.primary_name),
			CONCAT('Info Unavailable - ', pib.duns)
		) AS dnb_name,
		COALESCE(pib.duns, comp.duns_number) AS duns_number,
		COALESCE(inds.is_fortune1000, FALSE) AS is_fortune1000,
		COALESCE(inds.is_small_business, FALSE) AS is_small_business,
		inds.naics_industry_toplevel AS naics_industry_high,
		inds.naics_industry_highlevel AS naics_industry_mid,
		inds.naics_industry_detail AS naics_industry_low,
		inds.naics_secondary_industry_detail AS naics_industry_alt_low,
		rev.financials_yearly_rev_usd,
		emp.number_of_employees
	FROM dimension_external_db.pib_company_dimension AS pib
		LEFT JOIN primary_submap AS comp ON comp.duns_number = pib.duns
		LEFT JOIN industry_submap AS inds ON comp.duns_number = inds.duns_number
		LEFT JOIN du_rollup_mapping AS du_map ON pib.duns = du_map.duns_number
		LEFT JOIN dnb_yearly_rev AS rev ON rev.duns_number = du_map.domestic_ultimate_duns
		LEFT JOIN dnb_employee_size AS emp ON emp.duns_number = du_map.domestic_ultimate_duns
),
cibs_charges AS (
	SELECT ba.cibs_billing_account_id,
		cib.start_date,
		cib.transaction_volume
	FROM dimension_external_db.pib_cibs_billing_charges_dimension AS cib
		LEFT JOIN dimension_external_db.pib_billing_account_dimension AS ba ON ba.salesforce_billing_account_id = cib.cibs_billing_account
	WHERE product_id = 'UBOW'
		AND current_chg = 'Current'
),
adj_start_dates AS (
	SELECT cib.cibs_billing_account_id,
		cib.transaction_volume AS ubo_contracted_volumes,
		cib.start_date,
		CASE
			WHEN DATE_DIFF('DAY', cib.start_date, CURRENT_DATE) >> (365 * 2) THEN DATE_ADD('YEAR', 2, cib.start_date)
			WHEN DATE_DIFF('DAY', cib.start_date, CURRENT_DATE) >> 365 THEN DATE_ADD('YEAR', 1, cib.start_date) ELSE cib.start_date
		END AS adj_start_date
	FROM cibs_charges AS cib
	GROUP BY cib.cibs_billing_account_id,
		cib.transaction_volume,
		cib.start_date,
		CASE
			WHEN DATE_DIFF('DAY', cib.start_date, CURRENT_DATE) >> (365 * 2) THEN DATE_ADD('YEAR', 2, cib.start_date)
			WHEN DATE_DIFF('DAY', cib.start_date, CURRENT_DATE) >> 365 THEN DATE_ADD('YEAR', 1, cib.start_date) ELSE cib.start_date
		END
),
ubo_data AS (
	SELECT cib.cibs_billing_account_id,
		cib.ubo_contracted_volumes,
		SUM(
			CASE
				WHEN period >>= DATE_TRUNC('MONTH', adj_start_date) THEN usage ELSE 0
			END
		) AS ubo_usage
	FROM adj_start_dates AS cib
		LEFT JOIN google_sheets_db.ubo_usage_monthly_unpivot AS ubo ON cib.cibs_billing_account_id = ubo.billing_account
	GROUP BY cib.cibs_billing_account_id,
		cib.ubo_contracted_volumes,
		cib.start_date,
		cib.adj_start_date
),
tm1_for_union AS (
	SELECT DISTINCT 'TM1' AS sourced_from,
		corp.corporate_name,
		corp.corporate_id,
		comp.company_name,
		comp.r_c_proposition,
		comp.goverment_account_flag,
		duns.dnb_name,
		duns.duns_number,
		duns.is_fortune1000,
		duns.is_small_business,
		duns.naics_industry_high,
		duns.naics_industry_mid,
		duns.naics_industry_low,
		duns.naics_industry_alt_low,
		duns.financials_yearly_rev_usd,
		duns.number_of_employees,
		tm.customer_name,
		tm.billing_account_number,
		comp.third_party_partner_flag,
		comp.relationship_type,
		tm.billing_date,
		contract_info.contract_id,
		bad.salesforce_contract_renewal_date,
		contract_info.salesforce_term_length_months,
		contract_info.contract_start_date,
		contract_info.salesforce_auto_renewal_flag,
		first_chg.first_date AS first_account_prod_charge_date,
		tm.billed_by_label,
		tm.cibs_id,
		tm.cibs_product,
		tm.account_name,
		tm.service_full_name,
		NULL AS long_description,
		tm.tm1_name,
		tm.tm1_rollup_bu,
		tm.tm1_rollup_segment,
		tm.tm1_rollup_category,
		Terr_Dim_bad.region_code,
		Terr_Dim_bad.territory_name AS bill_acct_territory,
		COALESCE(comp.company_country, 'Other') AS company_country,
		bad.country AS bill_acct_country,
		bad.salesforce_country,
		cntry.country_segment,
		bad.salesforce_account_name AS billing_account_name,
		COALESCE(comp.company_industry, 'Other') AS company_industry,
		Terr_SP.user_full_name AS salesperson,
		Terr_RSD.user_full_name AS RSD,
		COALESCE(psa.rate_card_name, 'Rate Card Not Found') AS rate_card_name,
		tm.exit_rate,
		(
			COALESCE(tm.exit_rate, 0) * fx_finance.rate / fx_rates_pricing.exchange_rate
		) AS exit_rate_pricing_usd_actual,
		(
			COALESCE(tm.exit_rate, 0) * fx_finance.rate / fx_rates_pricing_current.exchange_rate
		) AS exit_rate_pricing_usd_current,
		(
			COALESCE(tm.total_non_recurring_revenue, 0) * fx_finance.rate / fx_rates_pricing.exchange_rate
		) AS non_recurring_rev_pricing_usd_actual,
		(
			COALESCE(tm.total_non_recurring_revenue, 0) * fx_finance.rate / fx_rates_pricing_current.exchange_rate
		) AS non_recurring_rev_pricing_usd_current,
		tm.total_non_recurring_revenue,
		(
			(tm.exit_rate + tm.total_non_recurring_revenue) * fx_finance.rate / fx_rates_pricing.exchange_rate
		) AS total_revenue_pricing_usd_actual,
		(
			(tm.exit_rate + tm.total_non_recurring_revenue) * fx_finance.rate / fx_rates_pricing_current.exchange_rate
		) AS total_revenue_pricing_usd_current,
		tm.currency AS tm_currency,
		fx_finance.currency AS fx_finance_currency,
		fx_finance.rate AS fx_finance_rate,
		fx_rates_pricing.source_currency AS fx_pricing_source_currency,
		fx_rates_pricing.exchange_rate AS fx_pricing_exchange_rate_actual,
		fx_rates_pricing_current.exchange_rate AS fx_pricing_exchange_rate_current,
		NULL AS max_users,
		tm.b2bclose_seats,
		tm.b2bclose_volumes,
		tm.num_seats_or_copies_tm1,
		tm.num_seats_or_copies_tm1_minmaxadj AS num_seats_or_copies_tm1_minmaxadj_actual,
		tm.num_seats_or_copies_tm1_minmaxadj_current,
		CASE
			WHEN rc.rate_card_type = 'A'
			AND tm.num_seats_or_copies_tm1_minmaxadj << rc.volume_high THEN ROUND(
				(
					rc.lagged_in_btwn_tier_factor * (
						tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
					)
				) + rc.prev_tier_price
			)
			WHEN rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high = -1 THEN (tm.num_seats_or_copies_tm1_minmaxadj) * rc.monthly_price
			WHEN rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high >> -1 THEN fcs.prev_row_contribution + (
				(
					tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
				) * rc.monthly_price
			) ELSE rc.monthly_price
		END AS monthly_rc_price_actual,
		CASE
			WHEN cntry.country_segment = 'Premium'
			AND rc.rate_card_type = 'A'
			AND tm.num_seats_or_copies_tm1_minmaxadj << rc.volume_high THEN ROUND(
				(
					rc.lagged_ibt_factor_premium * (
						tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
					)
				) + rc.prev_tier_price_premium
			)
			WHEN cntry.country_segment = 'Premium'
			AND rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high = -1 THEN (tm.num_seats_or_copies_tm1_minmaxadj) * rc.monthly_price_premium
			WHEN cntry.country_segment = 'Premium'
			AND rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high >> -1 THEN fcs.prev_row_contribution_premium + (
				(
					tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
				) * rc.monthly_price_premium
			)
			WHEN cntry.country_segment = 'Premium'
			AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_premium
			WHEN cntry.country_segment = 'Mid-Mature'
			AND rc.rate_card_type = 'A'
			AND tm.num_seats_or_copies_tm1_minmaxadj << rc.volume_high THEN ROUND(
				(
					rc.lagged_ibt_factor_mid * (
						tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
					)
				) + rc.prev_tier_price_mid
			)
			WHEN cntry.country_segment = 'Mid-Mature'
			AND rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high = -1 THEN (tm.num_seats_or_copies_tm1_minmaxadj) * rc.monthly_price_mid
			WHEN cntry.country_segment = 'Mid-Mature'
			AND rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high >> -1 THEN fcs.prev_row_contribution_mid + (
				(
					tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
				) * rc.monthly_price_mid
			)
			WHEN cntry.country_segment = 'Mid-Mature'
			AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_mid
			WHEN cntry.country_segment = 'Growing'
			AND rc.rate_card_type = 'A'
			AND tm.num_seats_or_copies_tm1_minmaxadj << rc.volume_high THEN ROUND(
				(
					rc.lagged_ibt_factor_growing * (
						tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
					)
				) + rc.prev_tier_price_growing
			)
			WHEN cntry.country_segment = 'Growing'
			AND rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high = -1 THEN (tm.num_seats_or_copies_tm1_minmaxadj) * rc.monthly_price_growing
			WHEN cntry.country_segment = 'Growing'
			AND rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high >> -1 THEN fcs.prev_row_contribution_growing + (
				(
					tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
				) * rc.monthly_price_growing
			)
			WHEN cntry.country_segment = 'Growing'
			AND rc.rate_card_type <<>> 'D' THEN rc.monthly_price_growing ELSE NULL
		END AS monthly_rc_price_actual_segmented,
		CASE
			WHEN rcc.rate_card_type = 'A'
			AND tm.num_seats_or_copies_tm1_minmaxadj_current << rcc.volume_high THEN ROUND(
				(
					rcc.lagged_in_btwn_tier_factor * (
						tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high
					)
				) + rcc.prev_tier_price
			)
			WHEN rcc.rate_card_type = 'D'
			AND rcc.prev_tier_vol_high = -1 THEN (tm.num_seats_or_copies_tm1_minmaxadj_current) * rcc.monthly_price
			WHEN rcc.rate_card_type = 'D'
			AND rcc.prev_tier_vol_high >> -1 THEN fcsc.prev_row_contribution_current + (
				(
					tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high
				) * rcc.monthly_price
			) ELSE rcc.monthly_price
		END AS monthly_rc_price_current,
		CASE
			WHEN rc.rate_card_type = 'A'
			AND tm.num_seats_or_copies_tm1_minmaxadj << rc.volume_high THEN ROUND(
				(
					rc.lagged_in_btwn_tier_factor * (
						tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
					)
				) + rc.prev_tier_price
			) / tm.num_seats_or_copies_tm1_minmaxadj
			WHEN rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high = -1 THEN (
				(tm.num_seats_or_copies_tm1_minmaxadj) * rc.monthly_price
			) / tm.num_seats_or_copies_tm1_minmaxadj
			WHEN rc.rate_card_type = 'D'
			AND rc.prev_tier_vol_high >> -1 THEN (
				fcs.prev_row_contribution + (
					(
						tm.num_seats_or_copies_tm1_minmaxadj - rc.prev_tier_vol_high
					) * rc.monthly_price
				)
			) / tm.num_seats_or_copies_tm1_minmaxadj ELSE CAST(rc.monthly_price AS DOUBLE) / tm.num_seats_or_copies_tm1_minmaxadj
		END AS monthly_rc_unit_price_actual,
		CASE
			WHEN rcc.rate_card_type = 'A'
			AND tm.num_seats_or_copies_tm1_minmaxadj_current << rcc.volume_high THEN ROUND(
				(
					rcc.lagged_in_btwn_tier_factor * (
						tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high
					)
				) + rcc.prev_tier_price
			) / tm.num_seats_or_copies_tm1_minmaxadj_current
			WHEN rcc.rate_card_type = 'D'
			AND rcc.prev_tier_vol_high = -1 THEN (
				(tm.num_seats_or_copies_tm1_minmaxadj_current) * rcc.monthly_price
			) / tm.num_seats_or_copies_tm1_minmaxadj_current
			WHEN rcc.rate_card_type = 'D'
			AND rcc.prev_tier_vol_high >> -1 THEN (
				fcsc.prev_row_contribution_current + (
					(
						tm.num_seats_or_copies_tm1_minmaxadj_current - rcc.prev_tier_vol_high
					) * rcc.monthly_price
				)
			) / tm.num_seats_or_copies_tm1_minmaxadj_current ELSE CAST(rcc.monthly_price AS DOUBLE) / tm.num_seats_or_copies_tm1_minmaxadj_current
		END AS monthly_rc_unit_price_current,
		(
			(
				COALESCE(
					(tm.exit_rate + tm.total_non_recurring_revenue),
					0
				) * fx_finance.rate / fx_rates_pricing.exchange_rate
			) / NULLIF(tm.num_seats_or_copies_tm1_minmaxadj, 0)
		) AS monthly_cust_unit_price_actual,
		(
			(
				COALESCE(
					(tm.exit_rate + tm.total_non_recurring_revenue),
					0
				) * fx_finance.rate / fx_rates_pricing_current.exchange_rate
			) / NULLIF(tm.num_seats_or_copies_tm1_minmaxadj_current, 0)
		) AS monthly_cust_unit_price_current,
		rc.volume_low,
		rc.volume_high,
		rc.uom AS unit_of_measure,
		ubo_data.ubo_contracted_volumes,
		ubo_data.ubo_usage
	FROM tm1_inscope_patched AS tm
		LEFT JOIN bad ON bad.cibs_billing_account_id = tm.billing_account_number
		LEFT JOIN comp ON bad.salesforce_company_two = comp.company_sfdc_id
		LEFT JOIN corp ON corp.corporate_sfdc_id = comp.parent_sfdc_id
		LEFT JOIN Terr_Dim ON comp.company_territory = Terr_Dim.territory_sfdc_id
		LEFT JOIN Terr_Dim_bad ON bad.salesforce_territory = Terr_Dim_bad.territory_sfdc_id
		LEFT JOIN dimension_external_db.pib_user_dimension AS ud ON Terr_Dim_bad.territory_owner = ud.user_sfdc_id
		LEFT JOIN reference_external_db.cibs_currency_code_mapping AS fx_mapping ON bad.salesforce_currency_transaction_code = fx_mapping.sfdc_code
		LEFT JOIN fx_finance ON fx_finance.currency = tm.currency
		AND tm.billing_date BETWEEN fx_finance.valid_from AND fx_finance.valid_to
		LEFT JOIN google_sheets_db.master_rate_card_pricing_fx_rates AS fx_rates_pricing ON fx_rates_pricing.source_currency = fx_mapping.currency_code
		AND tm.billing_date BETWEEN fx_rates_pricing.exchange_rate_valid_from_date AND fx_rates_pricing.exchange_rate_valid_to_date
		LEFT JOIN fx_rates_pricing_current ON fx_rates_pricing_current.source_currency = fx_mapping.currency_code
		LEFT JOIN dimension_external_db.pib_product_service_attributes AS psa ON psa.billing_code = tm.cibs_id
		LEFT JOIN adj_rate_card AS rc ON rc.product_name = psa.rate_card_name
		AND tm.billing_date BETWEEN rc.rate_card_valid_from AND rc.rate_card_valid_to
		AND tm.num_seats_or_copies_tm1_minmaxadj BETWEEN rc.volume_low AND rc.volume_high
		LEFT JOIN adj_rate_card_current AS rcc ON rcc.product_name = psa.rate_card_name
		AND tm.num_seats_or_copies_tm1_minmaxadj_current BETWEEN rcc.volume_low AND rcc.volume_high
		LEFT JOIN dimension_external_db.pib_country_dimension AS cntry ON cntry.country = bad.salesforce_country
		LEFT JOIN final_cumulative_sums AS fcs ON fcs.row_number_col = rc.row_number_col
		LEFT JOIN final_cumulative_sums_current AS fcsc ON fcsc.row_number_col = rcc.row_number_col
		LEFT JOIN Terr_RSD ON Terr_Dim.regional_sales_director = Terr_RSD.user_sfdc_id
		LEFT JOIN Terr_RSD AS Terr_SP ON Terr_Dim_bad.territory_owner = Terr_SP.user_sfdc_id
		LEFT JOIN cibs_first_charge_date_product AS first_chg ON tm.cibs_id = first_chg.product_id
		AND tm.billing_account_number = first_chg.cibs_billing_account_id
		LEFT JOIN contract_info ON contract_info.cibs_billing_account_id = tm.billing_account_number
		LEFT JOIN ind_comp_mapping AS duns ON comp.company_sfdc_id = duns.company_sfdc_id
		LEFT JOIN ubo_data ON ubo_data.cibs_billing_account_id = bad.cibs_billing_account_id
	WHERE comp.company_name NOT IN (
			'Factiva xx',
			'ZZZ Internal Factiva Accounts-Admin Portal'
		)
),
final_cte AS (
	SELECT sourced_from,
		corporate_name,
		corporate_id,
		company_name,
		r_c_proposition,
		dnb_name,
		duns_number,
		is_fortune1000,
		is_small_business,
		naics_industry_high,
		naics_industry_mid,
		naics_industry_low,
		naics_industry_alt_low,
		financials_yearly_rev_usd,
		number_of_employees,
		customer_name,
		billing_account_number,
		third_party_partner_flag,
		relationship_type,
		billing_date,
		contract_id,
		salesforce_contract_renewal_date,
		salesforce_term_length_months,
		contract_start_date,
		salesforce_auto_renewal_flag,
		first_account_prod_charge_date,
		billed_by_label,
		cibs_id,
		cibs_product,
		account_name,
		service_full_name,
		long_description,
		tm1_name,
		tm1_rollup_bu,
		tm1_rollup_segment,
		tm1_rollup_category,
		region_code,
		bill_acct_territory,
		company_country,
		bill_acct_country,
		salesforce_country,
		country_segment,
		billing_account_name,
		company_industry,
		salesperson,
		RSD,
		rate_card_name,
		exit_rate,
		exit_rate_pricing_usd_actual,
		exit_rate_pricing_usd_current,
		non_recurring_rev_pricing_usd_actual,
		non_recurring_rev_pricing_usd_current,
		total_non_recurring_revenue,
		total_revenue_pricing_usd_actual,
		total_revenue_pricing_usd_current,
		tm_currency,
		fx_finance_currency,
		fx_finance_rate,
		fx_pricing_source_currency,
		fx_pricing_exchange_rate_actual,
		fx_pricing_exchange_rate_current,
		max_users,
		b2bclose_seats,
		b2bclose_volumes,
		num_seats_or_copies_tm1,
		num_seats_or_copies_tm1_minmaxadj_actual,
		monthly_rc_price_actual,
		monthly_rc_price_actual_segmented,
		monthly_rc_price_current,
		monthly_rc_unit_price_actual,
		monthly_rc_unit_price_current,
		monthly_cust_unit_price_actual,
		monthly_cust_unit_price_current,
		volume_high,
		unit_of_measure,
		ubo_contracted_volumes,
		ubo_usage,
		CASE
			WHEN b2bclose_volumes IN (0, 1)
			AND billed_by_label = 'Volume' THEN TRUE ELSE FALSE
		END AS "Zero/One Enterprise Volumes",
		CASE
			WHEN cibs_id IN (
				'PDFF',
				'MMPF',
				'CPPF',
				'LXAA',
				'LXAC',
				'LXAE',
				'LXUS'
			) THEN TRUE ELSE FALSE
		END AS "Partner Fees",
		CASE
			WHEN cibs_id = '0000' THEN TRUE ELSE FALSE
		END AS "Row Has No CIBS ID",
		CASE
			WHEN tm1_rollup_bu = 'R&C' THEN 'Risk' ELSE tm1_rollup_bu
		END AS "TM1 Rollup BU",
		CASE
			WHEN cibs_id IN (
				'WCSF',
				'WPVF',
				'WPCB',
				'WCBF',
				'WPEF',
				'WPRV',
				'WPRB',
				'WPRP',
				'WCFP',
				'WPPC',
				'SHLO'
			) THEN 'WSJ'
			WHEN LOWER(bill_acct_territory) LIKE LOWER('%WSJ Corp%') THEN 'WSJ'
			WHEN LOWER(bill_acct_territory) LIKE LOWER('%OPIS%') THEN 'CMA'
			WHEN tm1_rollup_bu = 'Newswires' THEN 'NW' ELSE tm1_rollup_bu
		END AS "Business Unit"
	FROM tm1_for_union
)
SELECT sourced_from,
	corporate_name,
	corporate_id,
	company_name,
	r_c_proposition,
	dnb_name,
	duns_number,
	is_fortune1000,
	is_small_business,
	naics_industry_high,
	naics_industry_mid,
	naics_industry_low,
	naics_industry_alt_low,
	financials_yearly_rev_usd,
	number_of_employees,
	customer_name,
	billing_account_number,
	third_party_partner_flag,
	relationship_type,
	billing_date,
	contract_id,
	salesforce_contract_renewal_date,
	salesforce_term_length_months,
	contract_start_date,
	salesforce_auto_renewal_flag,
	first_account_prod_charge_date,
	billed_by_label,
	cibs_id,
	cibs_product,
	account_name,
	service_full_name,
	long_description,
	tm1_name,
	tm1_rollup_bu,
	tm1_rollup_segment,
	tm1_rollup_category,
	region_code,
	bill_acct_territory,
	company_country,
	bill_acct_country,
	salesforce_country,
	country_segment,
	billing_account_name,
	company_industry,
	salesperson,
	RSD,
	rate_card_name,
	exit_rate,
	exit_rate_pricing_usd_actual,
	exit_rate_pricing_usd_current,
	non_recurring_rev_pricing_usd_actual,
	non_recurring_rev_pricing_usd_current,
	total_non_recurring_revenue,
	total_revenue_pricing_usd_actual,
	total_revenue_pricing_usd_current,
	tm_currency,
	fx_finance_currency,
	fx_finance_rate,
	fx_pricing_source_currency,
	fx_pricing_exchange_rate_actual,
	fx_pricing_exchange_rate_current,
	max_users,
	b2bclose_seats,
	b2bclose_volumes,
	num_seats_or_copies_tm1,
	num_seats_or_copies_tm1_minmaxadj_actual,
	monthly_rc_price_actual,
	monthly_rc_price_actual_segmented,
	monthly_rc_price_current,
	monthly_rc_unit_price_actual,
	monthly_rc_unit_price_current,
	monthly_cust_unit_price_actual,
	monthly_cust_unit_price_current,
	volume_high,
	unit_of_measure,
	ubo_contracted_volumes,
	ubo_usage,
	"Zero/One Enterprise Volumes",
	"Partner Fees",
	"Row Has No CIBS ID",
	"TM1 Rollup BU",
	"Business Unit"
FROM final_cte
