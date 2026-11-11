-- Published data source : "B2B DJRJ Onboard"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with t1 as(
select
t.post_evar3, t.date_time, t.post_page_event_var2, t.post_evar184, t.cycle_date,
trim(split_part) as evar12
FROM fact_external_db.omniture_event_fact_hourly t
CROSS JOIN UNNEST(
    regexp_split(t.post_evar12, ',')
) AS u(split_part)
WHERE reporting_suite in ('djb2briskjournal')
and cycle_date >>= date('2025-03-31')
and post_evar3 not in ('E6OO2HVCQHVPE36GA45VEIW3PA','D3WZYJYBD4BQAC2TAVG2OMAAAA')
and post_evar184 in ('Alert','Topics')
--or post_page_event_var2 like '%complete%'
GROUP BY 1,2,3,4,5,6
order by date_time
),

mem_dim AS (
  SELECT pib_member_id, user_id, billing_account_id, plan_id, email, first_name, last_name, user_status
  FROM dimension_external_db.pib_membership_dimension
  --where user_status = 'A'
   GROUP BY 1,2,3,4,5,6,7,8),

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
left join comp on mem_dim.billing_account_id = comp.cibs_billing_account_id),

onboarding as (
SELECT 
  cycle_date, 
  date_time, 
  SUBSTRING(CAST(cycle_date AS varchar), 1, 7) AS year_month, 
  post_evar3, 
  post_page_event_var2, 
  post_evar184,

  -- Topic selection logic
  CASE 
    WHEN LOWER(evar12) LIKE 'anti-c%' THEN 'Anti-Corruption & Bribery'
    WHEN LOWER(evar12) LIKE 'artifi%' THEN 'Artificial Intelligence'
    WHEN LOWER(evar12) LIKE 'human%' THEN 'Human Trafficking & Forced Labor'
    WHEN LOWER(evar12) LIKE 'sanctions%' THEN 'Sanctions & Trade Controls'
    WHEN LOWER(evar12) LIKE 'su%' THEN 'Supply Chain'
    WHEN LOWER(evar12) LIKE 'workp%' THEN 'Workplace & Labor'
    ELSE evar12 
  END AS topic_selections,

  -- New separate columns for each alert type
  CASE 
    WHEN LOWER(post_page_event_var2) LIKE '%customer%' AND LOWER(post_page_event_var2) LIKE '%add%' THEN 1
    ELSE 0
  END AS onboard_add,

  CASE 
    WHEN LOWER(post_page_event_var2) LIKE '%customer%' AND LOWER(post_page_event_var2) LIKE '%remove%' THEN 1
    ELSE 0
  END AS onboard_remove,

  CASE 
    WHEN LOWER(post_page_event_var2) LIKE '%add%' AND NOT LOWER(post_page_event_var2) LIKE '%customer%' THEN 1
    ELSE 0
  END AS manage_add,

  CASE 
    WHEN LOWER(post_page_event_var2) LIKE '%remove%' AND NOT LOWER(post_page_event_var2) LIKE '%customer%' THEN 1
    ELSE 0
  END AS manage_remove

FROM t1)

select onboarding.*, main_dim.*
FROM onboarding
LEFT JOIN main_dim ON main_dim.pib_member_id = onboarding.post_evar3
