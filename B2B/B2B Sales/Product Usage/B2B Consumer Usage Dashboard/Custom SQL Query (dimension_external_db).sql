-- Dashboard   : "B2B Consumer Usage Dashboard"  [B2B / B2B Sales / Product Usage]
-- Data source : "Custom SQL Query (dimension_external_db)" = published source "B2B Consumer Usage Dashboard - Data Source"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH ConsumerOmnit as (SELECT case when post_evar3 like 'V1-%' or post_evar3 like 'V2-%' then post_evar3 else 'V2-' || post_evar3 end AS vxid_clean,
							 SUBSTRING(cast(cycle_date AS varchar), 1, 7) year_month,
							 post_prop1,
							 post_prop2,
							 ref_type,
							 ref_domain,
                              sum(case when reporting_suite = 'djglobal' and (lower(post_prop8) not like 'dwsjn%' and ((lower(channel) like '%online journal%' or lower(channel) like '%wsj%') or post_prop24 = 'The Wall Street Journal')) 
                              			AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                              			then 1 else 0 end) wsj_djglobal_pvs,
                              sum(case when reporting_suite in ('djappwsj', 'djwsjiphone', 'djwsjipad') AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                              			then 1 else 0 END) wsjApps_pvs,
                              sum(case when reporting_suite = 'djglobal' and ((lower(channel) like '%barron%' or channel like '%bol%') or post_prop24 = 'Barron s' or post_prop1 in ('Barrons US', 'Barrons EMEA', 'Barrons APAC') or post_prop5 = 'www.barrons.com/') 
                              			AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                              			then 1 else 0 END) barrons_djglobal_pvs,
                              sum(case when reporting_suite in ('djappbarrons') AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                              			then 1 else 0 end) barronsApps_pvs
                      FROM fact_external_db.omniture_event_fact 
                      WHERE cycle_date >>= date('2023-01-01')
                      group by 1, 2, 3, 4, 5, 6),
                      
ConsumerActiveDays AS (
SELECT SUBSTRING(cast(cycle_date AS varchar), 1, 7) year_month,
	   case when post_evar3 like 'V1-%' or post_evar3 like 'V2-%' then post_evar3 else 'V2-' || post_evar3 end AS vxid_clean, 
	   (case when reporting_suite = 'djglobal' and (lower(post_prop8) not like 'dwsjn%' and ((lower(channel) like '%online journal%' or lower(channel) like '%wsj%') or post_prop24 = 'The Wall Street Journal')) 
                              			AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                              			then cycle_date else null END) wsj_djglobal_cycleDate,
        (case when reporting_suite in ('djappwsj', 'djwsjiphone', 'djwsjipad') AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                              			then cycle_date else null END) wsjApps_cycleDate,
       (case when reporting_suite = 'djglobal' and ((lower(channel) like '%barron%' or channel like '%bol%') or post_prop24 = 'Barron s' or post_prop1 in ('Barrons US', 'Barrons EMEA', 'Barrons APAC') or post_prop5 = 'www.barrons.com/') 
                              			AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                              			then cycle_date else null END) barrons_djglobal_cycleDate,
       (case when reporting_suite in ('djappbarrons') AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                              			then cycle_date else null end) barronsApps_cycleDate
FROM fact_external_db.omniture_event_fact 
WHERE cycle_date >>= date('2023-01-01')
GROUP BY 1, 2, 3, 4, 5, 6
),

date_tbl AS (
SELECT SUBSTRING(CAST(full_date AS varchar),1,7) AS year_month, MAX(DATE_TRUNC('day',full_date)) AS month_end_date
  FROM reference_external_db.date_dimension
  WHERE full_date >>= DATE('2023-01-01')
    AND full_date <<= DATE_ADD('day',-1,(DATE_TRUNC('month',DATE_ADD('month', 1, CURRENT_DATE))))
  GROUP BY 1),

mem_dim AS ( select
pib_member_id,
uu_id,
user_id,
first_name, 
last_name,
country_code,
city,
email_login,
plan_id,
email,
billing_account_id,
user_status,
web_registration_date
from dimension_external_db.pib_membership_dimension
where billing_account_id NOT LIKE '9ZFB%'
    and billing_account_id NOT LIKE '9ZZZ%'
    and uu_id is not null
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13),


VXID as (
  SELECT encrypted_uuid_v1 as VXID, uuid
  FROM subscription_external_db.identity_lookup
  WHERE encrypted_uuid_v1 IS NOT NULL
  UNION
  SELECT encrypted_uuid_v2 as VXID, uuid
  FROM subscription_external_db.identity_lookup
  WHERE encrypted_uuid_v1 IS NOT NULL),
  
active_days_uuid AS (
SELECT ConsumerActiveDays.year_month, VXID.uuid, ConsumerActiveDays.wsj_djglobal_cycleDate, ConsumerActiveDays.wsjApps_cycleDate, ConsumerActiveDays.barrons_djglobal_cycleDate, ConsumerActiveDays.barronsApps_cycleDate
FROM ConsumerActiveDays
LEFT JOIN VXID ON VXID = ConsumerActiveDays.vxid_clean
GROUP BY 1, 2, 3, 4, 5, 6
),

active_days_consolidated AS (
SELECT year_month, uuid, 
		count(DISTINCT wsj_djglobal_cycleDate) wsj_djglobal_activeDays,
		count(DISTINCT wsjApps_cycleDate) wsjApps_activeDays,
		count(DISTINCT barrons_djglobal_cycleDate) barrons_djglobal_activeDays,
		count(DISTINCT barronsApps_cycleDate) barronsApps_activeDays
FROM active_days_uuid
GROUP BY 1, 2
),
  
Bill_Acct_Dim AS (
	SELECT distinct cibs_billing_account_id, salesforce_company_two 
	FROM dimension_external_db.pib_billing_account_dimension ),
  
company_dim AS (
	SELECT DISTINCT company_sfdc_id, company_name, company_industry, company_territory, company_country
	FROM dimension_external_db.pib_company_dimension ),
	
usr as (
SELECT DISTINCT
	user_sfdc_id,
	user_full_name
FROM
	dimension_external_db.pib_user_dimension),
	
Terr_Dim as (
select
	DISTINCT 
	territory_sfdc_id,
	territory_name,
	territory_owner,
	territory_roll_up,
	regional_sales_director,
	region_code
from
	dimension_external_db.pib_territory_dimension)


SELECT mem_dim.user_id,
       mem_dim.pib_member_id,
       mem_dim.email,
       mem_dim.first_name,
       mem_dim.last_name,
       mem_dim.plan_id,
       mem_dim.email_login,
       cr.country_name membership_country_name,
       mem_dim.city,
       mem_dim.billing_account_id,
       mem_dim.user_status,
       mem_dim.web_registration_date,
       company_dim.company_name,
       company_dim.company_industry,
       company_dim.company_country,
       Terr_Dim.territory_name,
       Terr_Dim.region_code,
       shell.year_month,
       ConsumerOmnit.post_prop1 AS content_type,
       ConsumerOmnit.post_prop2 AS content_section,
       ConsumerOmnit.ref_type,
       ConsumerOmnit.ref_domain,
       COALESCE(active_days_consolidated.wsj_djglobal_activeDays, 0) wsj_djglobal_activeDays, 
       COALESCE(active_days_consolidated.wsjApps_activeDays, 0) wsjApps_activeDays, 
       COALESCE(active_days_consolidated.barrons_djglobal_activeDays, 0) barrons_djglobal_activeDays, 
       COALESCE(active_days_consolidated.barronsApps_activeDays, 0) barronsApps_activeDays, 
       COALESCE(sum(ConsumerOmnit.wsj_djglobal_pvs), 0) wsj_djglobal_pvs,
       COALESCE(sum(ConsumerOmnit.wsjApps_pvs), 0) wsjApps_pvs,
       COALESCE(sum(ConsumerOmnit.barrons_djglobal_pvs), 0) barrons_djglobal_pvs,
       COALESCE(sum(ConsumerOmnit.barronsApps_pvs), 0) barronsApps_pvs
FROM  mem_dim
CROSS JOIN (SELECT DISTINCT year_month FROM date_tbl) shell
LEFT JOIN Bill_Acct_Dim ON mem_dim.billing_account_id = Bill_Acct_Dim.cibs_billing_account_id
LEFT JOIN company_dim ON Bill_Acct_Dim.salesforce_company_two = company_dim.company_sfdc_id
LEFT JOIN VXID ON mem_dim.uu_id = VXID.uuid
LEFT JOIN ConsumerOmnit ON VXID.VXID = ConsumerOmnit.vxid_clean AND shell.year_month = ConsumerOmnit.year_month
LEFT JOIN active_days_consolidated ON mem_dim.uu_id = active_days_consolidated.uuid AND shell.year_month = active_days_consolidated.year_month
LEFT JOIN Terr_Dim ON Terr_Dim.territory_sfdc_id = company_dim.company_territory
LEFT JOIN reference_external_db.country_reference cr ON cr.edw_code = mem_dim.country_code
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26
