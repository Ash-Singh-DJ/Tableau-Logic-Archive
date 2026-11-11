-- Dashboard   : "B2B Account Level Billing and Usage Metrics: RCFC"  [B2B / B2B Sales / Product Usage]
-- Data source : "User Level data by Account RCFC" = published source "User Level data by Account RCFC"  [B2B / B2B Product / Factiva]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with metrics as (
SELECT substring(cast(cycle_date as varchar),1,7) as year_month, --user_info_plan_id as plan_id,
user_info_account_id as billing_account_id, user_info_user_ref as pib_member_id, 
sum( case when event_name = 'UBO_Search_Click' or ti_td_action = 'search_ubo' then 1 else 0 end) Total_UBO_Searches,
sum( case when event_name = 'page_view' then 1 else 0 end) Page_Views,
count(distinct case when event_name in ('page_view','user_action') then visit_id end) Visits,
sum( case when event_name = 'AdvancedSearch_Click' or ti_td_action = 'search_advanced' then 1 else 0 end) Advanced_Search,
sum( case when event_name = 'SimpleSearch_Click' or ti_td_action = 'search_simple' then 1 else 0 end) Simple_Search,
sum( case when ti_td_page_name = 'DJRCFC_Home_Dashboard' or ti_td_action = 'sanctions_insight_view_newsletter' then 1 else 0 end) Sanctions_Insight_Views,
sum( case when ti_td_page_name = 'DJRCFC_ResearchTools_Profile_entity' or ti_td_action = 'download_profile_overlay_view' then 1 else 0 end) Profile_Overlay_Download,
sum( case WHEN ti_td_action = 'profiles_bulk_actions' then 1 else 0 end) Profile_Bulk_Download
--sum (case WHEN ti_td_page_name = 'DJRCFC_ResearchTools_Audit Trail' AND ti_td_page_section = 'Audit Trail'
--     AND event_name = 'user_action' AND ti_td_action = 'download_audit' then 1 else 0 end) Audit_Download

FROM pib_event_data.pib_product_metrics 
	WHERE product in ('Financial Crime', 'RiskCenter')
		AND cycle_date >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -14, CURRENT_DATE)))
                and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
		--AND cycle_date >>= DATE('2021-11-01')
		--and cycle_date >>= DATE('2024-10-16')
		AND (event_name IS NOT NULL OR "action" IS NOT NULL OR ti_td_event_name IS NOT NULL OR ti_td_action IS NOT NULL)
		and user_info_plan_id in ('0598', '0599', '0607', '0608', '0609', '0610', '0618', '0641', '0642', '0643', '0644', 
                '0647', '0648', '0649', '0650', '0651', '0652', '0653', '0654', '0655', '0656', '0657', '0658', '0659', '0660', '0661', 
                '0662', '0663', '0664', '0665', '0611', '0613', '0614', '0616', '0705','2040', '2041', '2042', '2043', '2044', '8246','8247')
		group by 1,2,3
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


sterr as
(select territory_sfdc_id, territory_name, territory_owner, regional_sales_director
from dimension_external_db.pib_territory_dimension
group by 1,2,3,4
),



mem as (
	SELECT first_name, last_name, pib_member_id, city User_city, user_id, email,long_user_id,
		   billing_account_id, plan_id, user_status, company_name, web_registration_date
	FROM dimension_external_db.pib_membership_dimension
	--WHERE user_status = 'A'
),


cd AS (SELECT company_sfdc_id, company_name Company, company_territory FROM dimension_external_db.pib_company_dimension),

/*RiskOmnit as (SELECT post_evar3,
                    max(cycle_date) last_login_RC
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djriskcomplianceprod'
  and cycle_date >>= date('2017-06-01')
  and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
GROUP BY 1
ORDER BY 1),
*/

LastLoginDJM AS (
	SELECT 
		user_info_user_ref, 
		max(cycle_date) AS last_login_RCFC 
	FROM pib_event_data.pib_product_metrics 
	WHERE cycle_date >>= DATE('2020-03-16')
		AND product IN ('Financial Crime', 'RiskCenter')
		AND (event_name IS NOT NULL OR "action" IS NOT NULL OR ti_td_event_name IS NOT NULL OR ti_td_action IS NOT NULL)
	GROUP BY 1 
)


select metrics.*,mem.first_name, mem.last_name, mem.email, mem.user_id, mem.plan_id, mem.user_status, mem.web_registration_date, mem.long_user_id,
cd.company, bad.country, LastLoginDJM.last_login_RCFC, sterr.territory_sfdc_id,
            sterr.territory_name,
            us1.user_full_name,
            us2.user_full_name as rsd
            
FROM metrics
LEFT JOIN mem on mem.pib_member_id = metrics.pib_member_id
LEFT JOIN bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN cd  on bad.salesforce_company_two = cd.company_sfdc_id
LEFT JOIN LastLoginDJM ON mem.pib_member_id = LastLoginDJM.user_info_user_ref
LEFT JOIN sterr ON cd.company_territory = sterr.territory_sfdc_id
left join dimension_external_db.pib_user_dimension us1 on sterr.territory_owner = us1.user_sfdc_id
left join dimension_external_db.pib_user_dimension us2 on sterr.regional_sales_director = us2.user_sfdc_id
