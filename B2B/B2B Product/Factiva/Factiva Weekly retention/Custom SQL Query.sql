-- Published data source : "Factiva Weekly retention."  [B2B / B2B Product / Factiva]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / reference_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH user_cohorts AS (
  -- Get user's original cohort month (from first activity)
  SELECT 
    mem.pib_member_id,
    mem.billing_account_id,
  	mem.plan_id,
     DATE_TRUNC('month', MIN(djm.cycle_date)) as cohort_week
    FROM pib_event_data.pib_product_metrics djm
	LEFT JOIN dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
	WHERE product in ('Factiva', 'New Factiva')
	and event_name = 'page_view' 
 --and ti_td_page_section <<>>  'Onboarding' 
   
  GROUP BY 1,2,3
    HAVING MIN(djm.cycle_date) >>= date('2023-01-01')  

),

user_periods AS (
  SELECT 
    mem.pib_member_id,
    mem.billing_account_id,
    DATE_TRUNC('month', djm.cycle_date) as period_month
  	FROM pib_event_data.pib_product_metrics djm
	LEFT JOIN dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
	WHERE product in ('Factiva', 'New Factiva')
	and event_name = 'page_view'
 
  GROUP BY mem.pib_member_id, mem.billing_account_id, DATE_TRUNC('month', djm.cycle_date)
), 


cohort_data AS (
  SELECT 
    c.cohort_week,
    c.billing_account_id,
    c.plan_id,
    --c.cluster_name,  -- Use the eventually-determined user type
    p.period_month,
    COUNT(DISTINCT c.pib_member_id) as users
  FROM user_cohorts c
  LEFT JOIN user_periods p ON c.pib_member_id = p.pib_member_id
  WHERE p.period_month >>= c.cohort_week
  GROUP BY c.cohort_week,  c.billing_account_id, c.plan_id, p.period_month
),


comp as (
SELECT ba.cibs_billing_account_id, 
        --ba.salesforce_billing_account_id,
        ba.country,
        ba.industry,
        ba.account_sales_region,
        comp.company_name, 
        corp.corporate_name,
        comp.company_industry, 
        terr.territory_roll_up,
        usr.user_full_name as rsd,
        usr2.user_full_name AS salesperson
FROM dimension_external_db.pib_billing_account_dimension ba 
--ON ba.salesforce_billing_account_id = cib.cibs_billing_account 
LEFT JOIN dimension_external_db.pib_company_dimension comp on ba.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_corporate_dimension corp ON comp.parent_sfdc_id = corp.corporate_sfdc_id 
LEFT JOIN dimension_external_db.pib_territory_dimension terr ON comp.company_territory = terr.territory_sfdc_id 
LEFT JOIN dimension_external_db.pib_user_dimension usr ON usr.user_sfdc_id = terr.regional_sales_director 
LEFT JOIN dimension_external_db.pib_user_dimension usr2 ON usr2.user_sfdc_id = terr.territory_owner      
group by 1,2,3,4,5,6,7,8,9,10
)

select cohort_data.*, comp.company_name, comp.company_industry
from cohort_data
left join comp on cohort_data.billing_account_id = comp.cibs_billing_account_id
ORDER BY cohort_week, period_month, billing_account_id
