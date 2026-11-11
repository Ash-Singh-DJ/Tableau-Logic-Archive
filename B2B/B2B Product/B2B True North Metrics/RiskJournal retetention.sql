-- Dashboard   : "B2B True North Metrics"  [B2B / B2B Product]
-- Data source : "RiskJournal retetention" = published source "B2B True North - RiskJournal retetention"  [B2B / B2B Product / Data sources / True North Metrics Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH user_cohorts AS (
  -- Get user's original cohort month (from first activity)
  SELECT 
    mem.pib_member_id,
    mem.billing_account_id,
    DATE_TRUNC('month', MIN(omni.cycle_date)) as cohort_month
  	FROM fact_external_db.omniture_event_fact_hourly omni
	LEFT JOIN dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id
	WHERE reporting_suite in ('djb2briskjournal')
    and omni.post_evar3 not in ('E6OO2HVCQHVPE36GA45VEIW3PA','D3WZYJYBD4BQAC2TAVG2OMAAAA')
  GROUP BY 1,2
    HAVING MIN(omni.cycle_date) >>= date('2025-03-31')  

),

user_periods AS (
  SELECT 
    mem.pib_member_id,
    mem.billing_account_id,
    DATE_TRUNC('month', omni.cycle_date) as period_month
  	FROM fact_external_db.omniture_event_fact_hourly omni
	LEFT JOIN dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id
	WHERE reporting_suite in ('djb2briskjournal')
    and omni.post_evar3 not in ('E6OO2HVCQHVPE36GA45VEIW3PA','D3WZYJYBD4BQAC2TAVG2OMAAAA')
  GROUP BY mem.pib_member_id, mem.billing_account_id, DATE_TRUNC('month', omni.cycle_date)
), 

cohort_data AS (
  SELECT 
    c.cohort_month,
    c.billing_account_id,
    --c.cluster_name,  -- Use the eventually-determined user type
    p.period_month,
    COUNT(DISTINCT c.pib_member_id) as users
  FROM user_cohorts c
  LEFT JOIN user_periods p ON c.pib_member_id = p.pib_member_id
  WHERE p.period_month >>= c.cohort_month
  GROUP BY c.cohort_month,  c.billing_account_id, p.period_month
),

comp as (
SELECT ba.cibs_billing_account_id, 
        --ba.salesforce_billing_account_id,
        ba.country,
        ba.industry,
        ba.account_sales_region,
        comp.company_name, 
        corp.corporate_name,
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
group by 1,2,3,4,5,6,7,8,9
)

select cohort_data.* ,comp.company_name
from cohort_data
left join comp on cohort_data.billing_account_id = comp.cibs_billing_account_id
ORDER BY cohort_month, period_month, billing_account_id
