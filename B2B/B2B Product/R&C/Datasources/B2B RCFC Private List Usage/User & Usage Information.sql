-- Published data source : "B2B RCFC Private List Usage"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "User & Usage Information"
-- Connection  : Athena (AwsDataCatalog / reference_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
            
              
            
            
            
with metrics as (
SELECT cycle_date, visit_id, cycle_date as year_month, --user_info_plan_id as plan_id,
user_info_account_id as billing_account_id, user_info_user_ref as pib_member_id, ti_td_ad_list_name,
sum (case when ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' or ti_td_page_section = 'Private Lists' then 1 else 0 end) Private_Lists_Views,
sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' AND ti_td_page_section = 'Private Lists'
	 AND ti_td_action = 'create_private_lists' THEN 1 else 0 end) Create_Private_Lists,
sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' AND ti_td_page_section = 'Private Lists'
	 AND ti_td_action = 'delete_private_lists' THEN 1 else 0 end) Delete_Private_Lists,
sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' AND ti_td_page_section = 'Private Lists'
	 AND ti_td_action = 'download_private_lists' THEN 1 else 0 end) Download_Private_Lists,	
sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' AND ti_td_page_section = 'Private Lists'
	 AND ti_td_action = 'download_private_lists_template' THEN 1 else 0 end) Download_Private_Lists_Template,	
sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' AND ti_td_page_section = 'Private Lists'
	 AND ti_td_action = 'edit_private_lists' THEN 1 else 0 end) Edit_Private_Lists,		 
sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' AND ti_td_page_section = 'Private Lists'
	 AND ti_td_action = 'toggle_private_lists' THEN 1 else 0 end) Toggle_Private_Lists,
sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' AND ti_td_page_section = 'Private Lists'
	 AND ti_td_action = 'toggle_private_lists' and ti_td_ad_private_lists ='Enable' THEN 1 else 0 end) Private_Lists_Enabled,
sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Private Lists' AND ti_td_page_section = 'Private Lists'
	 AND ti_td_action = 'toggle_private_lists' and ti_td_ad_private_lists ='Disable' THEN 1 else 0 end) Private_Lists_Disabled
	 
FROM pib_event_data.pib_product_metrics 
	WHERE product in ('Financial Crime', 'RiskCenter')
		AND cycle_date >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
		AND cycle_date >>= DATE('2023-12-01')
		AND (event_name IS NOT NULL OR "action" IS NOT NULL OR ti_td_event_name IS NOT NULL OR ti_td_action IS NOT NULL)
		group by 1,2,3,4,5,6
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
	WHERE user_status = 'A'
),


cd AS (SELECT company_sfdc_id, company_name Company FROM dimension_external_db.pib_company_dimension)

/*
LastLoginDJM AS (
	SELECT 
		user_info_user_ref, 
		max(cycle_date) AS last_login_RCFC 
	FROM pib_event_data.pib_product_metrics 
	WHERE cycle_date >>= DATE('2021-11-01')
		AND product IN ('Financial Crime', 'RiskCenter')
		AND (event_name IS NOT NULL OR "action" IS NOT NULL OR ti_td_event_name IS NOT NULL OR ti_td_action IS NOT NULL)
	GROUP BY 1 
), 

FactOmnit as (SELECT post_evar3,
                    max(cycle_date) last_login_factiva
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djfactiva'
  and lower(post_pagename) NOT LIKE '%login%'
  and cycle_date >>= date('2017-06-01')
  and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
GROUP BY 1
ORDER BY 1)

*/

select metrics.*,mem.first_name, mem.last_name, mem.email, mem.user_id, mem.plan_id, mem.user_status, mem.web_registration_date, 
	   cd.company, bad.country
       --,FactOmnit.last_login_factiva, --LastLoginDJM.last_login_RCFC
FROM metrics
LEFT JOIN mem on mem.pib_member_id = metrics.pib_member_id
LEFT JOIN bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN cd  on bad.salesforce_company_two = cd.company_sfdc_id
--LEFT JOIN FactOmnit ON mem.pib_member_id = FactOmnit.post_evar3
--LEFT JOIN LastLoginDJM ON mem.pib_member_id = LastLoginDJM.user_info_user_ref                              
