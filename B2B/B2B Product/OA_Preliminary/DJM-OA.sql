-- Dashboard   : "OA_Preliminary"  [B2B / B2B Product]
-- Data source : "DJM-OA" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH metrics_oa as
  	(
  	SELECT user_info_user_ref EID, cycle_date,
 		SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month,
 		COUNT(distinct cycle_date) active_days,
        count(distinct visit_id) visits
        FROM pib_event_data.pib_product_metrics
		WHERE product ='Oxford Analytica' and cycle_date >>= date('2025-11-17')
    	GROUP BY 1, 2, 3
	),
	
bad AS (
	SELECT product_access_code, cibs_billing_account_id, company_name AS bad_company_name, country, 
		   city, state, salesforce_business_unit, salesforce_status, account_type, subscription_date,
		   service_provided, salesforce_type, industry,salesforce_salesperson, max_contracted_users_allowed, 
		   salesforce_max_sessions, salesforce_contracted_users, salesforce_billing_start_date, 
		   salesforce_billing_type, account_sales_territory, salesforce_current_month_exit_rate,
		   salesforce_company_two
	FROM dimension_external_db.pib_billing_account_dimension 
),

mem as (
	SELECT first_name, last_name, pib_member_id, city User_city, user_id, email,
		   billing_account_id, plan_id, user_status, company_name, web_registration_date
	FROM dimension_external_db.pib_membership_dimension
),

cd AS (SELECT company_sfdc_id, company_name Company FROM dimension_external_db.pib_company_dimension)

select metrics_oa.*, mem.first_name, mem.last_name, mem.email, mem.user_id, mem.user_status, 
mem.billing_account_id,
mem.web_registration_date, cd.company
FROM metrics_oa
LEFT JOIN mem on mem.pib_member_id = metrics_oa.EID
LEFT JOIN bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN cd  on bad.salesforce_company_two = cd.company_sfdc_id
