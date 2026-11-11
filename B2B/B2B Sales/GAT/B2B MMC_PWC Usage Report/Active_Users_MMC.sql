-- Dashboard   : "B2B MMC_PWC Usage Report"  [B2B / B2B Sales / GAT]
-- Data source : "Active_Users_MMC" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH                   
ConsumerActiveDays AS (
SELECT SUBSTRING(cast(cycle_date AS varchar), 1, 7) year_month, post_evar3,
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
WHERE cycle_date >>= DATE('2023-01-01')
AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
GROUP BY 1, 2, 3, 4, 5, 6, 7
),

CF as(
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, post_evar3,
SUM(CASE WHEN reporting_suite in ('djfactiva','djappfactiva') AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) cf_page_views
FROM fact_external_db.omniture_event_fact omni
WHERE reporting_suite in ('djfactiva','djappfactiva')
AND cycle_date >>= DATE('2023-01-01')
AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
group by 1,2        
),

nf as
(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, user_info_account_id,
user_info_user_ref, 
sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) nf_page_views
from pib_event_data.pib_product_metrics omni
where product = 'New Factiva'
and cycle_date >>= DATE('2023-01-01')
AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
and user_info_account_id in ('9WIL000100', 
'9OLI000300','9MAR012400', '9MAR000200','9MAR002100','9MAR011100','9MAR012400','9MAR016000',
'9MAR017300','9MAR024500','9OLI001000','9MAR027600','9OLI000300','9OLI001400','9OLI001500',
'9OLI001600','9OLI001700','9OLI001800','9NER000100','9LIP000100','9GUY000100',
'9PRI001500','9PRI010200','9PRI018200','9PRI023000','9PRI023700','9PRI026900',
'9PRI028200','9PRI029100','9PRI029500','9PRI029900','9PWC000900','9PWC001500','9PWC002200'

)
GROUP BY 1,2,3
having sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) >> 0),

date_tbl AS (
SELECT SUBSTRING(CAST(full_date AS varchar),1,7) AS year_month, MAX(DATE_TRUNC('day',full_date)) AS month_end_date
  FROM reference_external_db.date_dimension
  WHERE full_date >>= DATE('2023-01-01')
  AND full_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
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
where billing_account_id in ('9WIL000100', 
'9OLI000300','9MAR012400', '9MAR000200','9MAR002100','9MAR011100','9MAR012400','9MAR016000',
'9MAR017300','9MAR024500','9OLI001000','9MAR027600','9OLI000300','9OLI001400','9OLI001500',
'9OLI001600','9OLI001700','9OLI001800','9NER000100','9LIP000100','9GUY000100',
'9PRI001500','9PRI010200','9PRI018200','9PRI023000','9PRI023700','9PRI026900',
'9PRI028200','9PRI029100','9PRI029500','9PRI029900','9PWC000900','9PWC001500','9PWC002200'

)
    --and uu_id is not null
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


SELECT shell.year_month,
       mem_dim.pib_member_id,
       mem_dim.user_id,
       mem_dim.email,
       mem_dim.first_name,
       mem_dim.last_name,
       mem_dim.plan_id,
       mem_dim.billing_account_id,
       company_dim.company_name,
       company_dim.company_industry,
       company_dim.company_country,
       COALESCE(active_days_consolidated.wsj_djglobal_activeDays, 0) wsj_djglobal_activeDays, 
       COALESCE(active_days_consolidated.wsjApps_activeDays, 0) wsjApps_activeDays, 
       COALESCE(active_days_consolidated.barrons_djglobal_activeDays, 0) barrons_djglobal_activeDays, 
       COALESCE(active_days_consolidated.barronsApps_activeDays, 0) barronsApps_activeDays,
       COALESCE(SUM(CF.cf_page_views),0) as cf_page_views,
       COALESCE(SUM(NF.nf_page_views),0) as NF_page_views
       --COALESCE(sum(ConsumerOmnit.wsj_djglobal_pvs), 0) wsj_djglobal_pvs,
       --COALESCE(sum(ConsumerOmnit.wsjApps_pvs), 0) wsjApps_pvs,
       --COALESCE(sum(ConsumerOmnit.barrons_djglobal_pvs), 0) barrons_djglobal_pvs,
       --COALESCE(sum(ConsumerOmnit.barronsApps_pvs), 0) barronsApps_pvs
       --Terr_Dim.territory_name,
       --Terr_Dim.region_code,
       --mem_dim.email_login,
       --cr.country_name membership_country_name,
       --mem_dim.city,
       --mem_dim.user_status,
       --mem_dim.web_registration_date,
FROM  mem_dim
CROSS JOIN (SELECT DISTINCT year_month FROM date_tbl) shell
LEFT JOIN Bill_Acct_Dim ON mem_dim.billing_account_id = Bill_Acct_Dim.cibs_billing_account_id
LEFT JOIN company_dim ON Bill_Acct_Dim.salesforce_company_two = company_dim.company_sfdc_id
LEFT JOIN VXID ON mem_dim.uu_id = VXID.uuid
LEFT JOIN CF ON mem_dim.pib_member_id = CF.post_evar3 AND shell.year_month = CF.year_month
LEFT JOIN NF ON mem_dim.pib_member_id = NF.user_info_user_ref AND shell.year_month = NF.year_month
LEFT JOIN active_days_consolidated ON mem_dim.uu_id = active_days_consolidated.uuid AND shell.year_month = active_days_consolidated.year_month
LEFT JOIN Terr_Dim ON Terr_Dim.territory_sfdc_id = company_dim.company_territory
LEFT JOIN reference_external_db.country_reference cr ON cr.edw_code = mem_dim.country_code
where mem_dim.billing_account_id in ('9WIL000100', 
'9OLI000300','9MAR012400', '9MAR000200','9MAR002100','9MAR011100','9MAR012400','9MAR016000',
'9MAR017300','9MAR024500','9OLI001000','9MAR027600','9OLI000300','9OLI001400','9OLI001500',
'9OLI001600','9OLI001700','9OLI001800','9NER000100','9LIP000100','9GUY000100',
'9PRI001500','9PRI010200','9PRI018200','9PRI023000','9PRI023700','9PRI026900',
'9PRI028200','9PRI029100','9PRI029500','9PRI029900','9PWC000900','9PWC001500','9PWC002200'

)
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15--, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26
