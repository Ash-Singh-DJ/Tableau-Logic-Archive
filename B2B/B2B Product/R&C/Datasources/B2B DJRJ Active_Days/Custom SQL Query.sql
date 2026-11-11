-- Published data source : "B2B DJRJ Active_Days"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH UserData AS (
select 
--cycle_date, 
SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
post_evar3,
--CONCAT(CAST((year(cycle_date)) as varchar), '-', CAST((week(cycle_date)) as varchar)) as year_cal_week,
--count(distinct cycle_date) AS AD_Per_Month,
COUNT(DISTINCT CASE WHEN lower(post_pagename) NOT LIKE '%login%' THEN cycle_date END) active_days,


    CASE
        WHEN COUNT(DISTINCT CASE WHEN lower(post_pagename) NOT LIKE '%login%' THEN cycle_date END) << 2 THEN 'Monthly User'
        WHEN COUNT(DISTINCT CASE WHEN lower(post_pagename) NOT LIKE '%login%' THEN cycle_date END) BETWEEN 2 AND 12 THEN 'Weekly User'
        WHEN COUNT(DISTINCT CASE WHEN lower(post_pagename) NOT LIKE '%login%' THEN cycle_date END) >> 12 THEN 'Daily User'
    END AS User_Category

FROM fact_external_db.omniture_event_fact_hourly
WHERE reporting_suite in ('djb2briskjournal')
and cycle_date >>= date('2025-03-31')
group by 1,2
order by 1,2
),

User_Cat as(
SELECT 
    year_month,
    post_evar3,
    active_days,
    User_Category,
    LAG(User_Category) OVER (PARTITION BY post_evar3 ORDER BY year_month) AS Previous_User_Category,
    CASE
        WHEN LAG(User_Category) OVER (PARTITION BY post_evar3 ORDER BY year_month) IS NULL THEN 'First Month'
        WHEN User_Category = 'Daily User' AND LAG(User_Category) OVER (PARTITION BY post_evar3 ORDER BY year_month) = 'Weekly User' THEN 'Up'
        WHEN User_Category = 'Daily User' AND LAG(User_Category) OVER (PARTITION BY post_evar3 ORDER BY year_month) = 'Monthly User' THEN 'Up'        WHEN User_Category = 'Monthly User' AND LAG(User_Category) OVER (PARTITION BY post_evar3 ORDER BY year_month) = 'Weekly User' THEN 'Down'
        WHEN User_Category = 'Weekly User' AND LAG(User_Category) OVER (PARTITION BY post_evar3 ORDER BY year_month) = 'Daily User' THEN 'Down'
        WHEN User_Category = 'Monthly User' AND LAG(User_Category) OVER (PARTITION BY post_evar3 ORDER BY year_month) = 'Daily User' THEN 'Down'
        ELSE 'No Change'
    END AS User_Category_Change
FROM UserData
ORDER BY 1,2
),

mem_dim AS (
  SELECT pib_member_id, user_id, billing_account_id, plan_id, email, first_name, last_name
  FROM dimension_external_db.pib_membership_dimension
  where user_status = 'A'
   GROUP BY 1,2,3,4,5,6,7),

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
),

main_dim as (select mem_dim.*, comp.*
from mem_dim
left join comp on mem_dim.billing_account_id = comp.cibs_billing_account_id)


select User_Cat.*, main_dim.*
FROM User_Cat
LEFT JOIN main_dim ON main_dim.pib_member_id = User_Cat.post_evar3
