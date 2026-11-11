-- Published data source : "B2B DJRJ Time Spent"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with Time_spent as (
SELECT
    yest_date,
    session_id,
    post_prop4,
    post_evar3,
    (MAX(to_unixtime(CAST(date_time AS timestamp))) - MIN(to_unixtime(CAST(date_time AS timestamp)))) AS total_duration_seconds
FROM (
SELECT
        CAST(CAST(date_time AS date) AS date) AS yest_date,  
        post_prop4,
        post_evar3,
		CAST(post_visid_high AS varchar) || '-' || 
        CAST(post_visid_low AS varchar) || '-' || 
        CAST(visit_num AS varchar) || '-' || 
        CAST(visit_start_time_gmt AS varchar) AS session_id,        
        CAST(date_time AS timestamp) AS date_time  
FROM fact_external_db.omniture_event_fact_hourly
WHERE reporting_suite in ('djb2briskjournal')
and cycle_date >>= date('2025-03-31')
--and post_prop4 is not null
)
where post_prop4 like '%DJRJ%'
--and post_evar3 ='D3WZYJYBD4BQAKLGYYPHYAIHAA'
group by 1,2,3,4
order by 1
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

select Time_spent.*, main_dim.*
FROM Time_spent
LEFT JOIN main_dim ON main_dim.pib_member_id = Time_spent.post_evar3
