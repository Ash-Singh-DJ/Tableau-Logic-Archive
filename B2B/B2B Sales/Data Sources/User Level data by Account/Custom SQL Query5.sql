-- Published data source : "User Level data by Account"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query5"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with cpr AS (
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
LEFT JOIN djx_volume_subquery djx ON mg.billing_month = djx.cycle_date AND mg.billing_account_number = djx.billing_account_number 
AND mg.cibs_product_id = djx.product_id)

select billing_account_number, sum(number_of_user_seats) num_of_user_seats from  mattg_tm1
where billing_month = (select max(billing_month) from mattg_tm1)
group by 1
