-- Published data source : "DJY Usage"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select year_month_day, week_start, fw, post_evar3, email, billing_account_id, company, day_of_week, sum(page_views) as desktop_page_views from (   


WITH 

wk as
(select substring(cast(full_date as varchar),1,10) year_month_day, substring(cast(week_start_date as varchar),1,10) week_start, day_of_week,
week_number_in_fiscal_year as fw
from reference_external_db.date_dimension
where substring(cast(full_date as varchar),1,10) >>= cast('2021-01-01' as varchar)
order by full_date),

metrics_ini AS (
select date_time as UTC_Datetime, geo_city, geo_zip, ip, cycle_date,mcvisid,
date_add('hour', 9, date_time) AS JST_Datetime, 
format_datetime(date_add('hour', 9, date_time), 'yyyy-MM') AS JST_year_month, 
wk.year_month_day, wk.week_start, wk.day_of_week, wk.fw,
post_evar3, post_prop22,  post_prop20, --CAST(visit_num as varchar) as visit_num,
substring(regexp_extract(post_prop22, '^[^_]+_[^_]+_[^_]+_(.+)', 1),1,26) AS Truc_Headlines,
regexp_extract(post_prop22, '^[^_]+_[^_]+_[^_]+_(.+)', 1) AS Headlines,
'Yomiuri' as Product, country, browser,
(case when mobile_id = 0 THEN 'Desktop' ELSE 'Mobile' end) as device,
split_part(split_part(split_part(user_agent,'(',2),')',1),';',1) as OS_Type,
split_part(split_part(split_part(user_agent,'(',2),')',1),';',2) as OS_Version,
(CASE WHEN CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '7',  '8',  '9') 
THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar) || '-' || CAST(visit_start_time_gmt as varchar)) END) as visit_id,
SUM(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) page_views,    
sum( case when post_prop1 = 'Article' then 1 else 0 end) article_views,
sum( case when post_prop1 = 'Home' then 1 else 0 end) home_landing,
sum( case when post_prop1 = 'ResearchTools' then 1 else 0 end) search_views,
sum( case WHEN post_prop1 = 'CustomerResources' then 1 else 0 end) preference
FROM fact_external_db.omniture_event_fact_hourly omnit
left join wk on  format_datetime(date_add('hour', 9, omnit.date_time), 'yyyy-MM-dd') = wk.year_month_day
WHERE reporting_suite = 'djb2byomiuri'
--AND cycle_date >> date_add('day', -800, current_date)
and cycle_date >>= Date('2025-08-27')
and cycle_date <<= Date('2025-10-24')
and post_evar3 <<>> 'D3WZYJ7S5KA2EUQKIGVXCDZ5PM' --EY user, should be exluded.
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24
having SUM(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0
),

VXID as (
  SELECT encrypted_uuid_v1 as VXID, uuid
  FROM subscription_external_db.identity_lookup
  WHERE encrypted_uuid_v1 IS NOT NULL
  UNION
  SELECT encrypted_uuid_v2 as VXID, uuid
  FROM subscription_external_db.identity_lookup
  WHERE encrypted_uuid_v2 IS NOT NULL),
  
pib_mem AS (
  SELECT pib_member_id, uu_id
  FROM dimension_external_db.pib_membership_dimension
  where user_status = 'A'
  GROUP BY 1,2),

mem_id as(
SELECT 
       pib_mem.pib_member_id,
       VXID.uuid,
       VXID.VXID
FROM  pib_mem
LEFT JOIN VXID ON pib_mem.uu_id = VXID.uuid 
where VXID.VXID is not null
GROUP BY 1, 2, 3
),

metrics as (
select metrics_ini.UTC_Datetime,
metrics_ini.JST_Datetime,
metrics_ini.JST_year_month,
metrics_ini.year_month_day,
metrics_ini.week_start,
metrics_ini.day_of_week,
metrics_ini.fw,
metrics_ini.mcvisid,
COALESCE(mem_id.pib_member_id, metrics_ini.post_evar3) AS post_evar3,
--visit_num,
metrics_ini.post_prop22,
metrics_ini.post_prop20,
metrics_ini.Truc_Headlines,
metrics_ini.Headlines,
metrics_ini.Product,
metrics_ini.country,
metrics_ini.geo_city, 
metrics_ini.geo_zip,
metrics_ini.ip,
metrics_ini.cycle_date,
metrics_ini.browser,
metrics_ini.device,
metrics_ini.OS_Type,
metrics_ini.OS_Version,
metrics_ini.visit_id,
metrics_ini.page_views,
metrics_ini.article_views,
metrics_ini.home_landing,
metrics_ini.search_views,
metrics_ini.preference
from metrics_ini
left join mem_id on metrics_ini.post_evar3 = mem_id.VXID
),

IP_INFO AS (
    SELECT
        client_account_id,
        client_ip_address,
        cycle_date,
        country_name,
        city_name,
        COUNT(DISTINCT id) AS transactions
    FROM pib_event_data.pib_platform_trace
    WHERE client_id ='mznZ58ktblEQ4Ube1vUp7yGPenmRUIWLwwqydCko'
      AND event_source = 'in_web_genericproxy'
      AND client_account_id IS NOT NULL
      AND cycle_date BETWEEN DATE('2025-08-27') AND DATE('2025-10-24')
      AND client_ip_address IN (
          SELECT DISTINCT ip
          FROM metrics
          WHERE post_evar3 IS NULL
             OR post_evar3 = ''
             OR (post_evar3 NOT LIKE 'D%' AND post_evar3 NOT LIKE 'E%')
      )
    GROUP BY client_account_id, client_ip_address, cycle_date, country_name, city_name
),

UNIQUE_IP AS (
    SELECT
        client_ip_address,
        cycle_date
    FROM IP_INFO
    GROUP BY client_ip_address, cycle_date
    HAVING COUNT(DISTINCT client_account_id) = 1
),

UNIQUE_IP_BA AS(
SELECT 
    i.client_account_id,
    i.client_ip_address,
    i.cycle_date
FROM IP_INFO i
JOIN UNIQUE_IP u
  ON i.client_ip_address = u.client_ip_address
 AND i.cycle_date = u.cycle_date
 ),
 
Metrics_from_ipBA as (
SELECT 
    m.*,
    f.client_account_id
FROM metrics m
LEFT JOIN UNIQUE_IP_BA f
  ON m.ip = f.client_ip_address
 AND m.cycle_date = f.cycle_date
WHERE (m.post_evar3 IS NULL OR m.post_evar3 = '' OR (m.post_evar3 NOT LIKE 'D3%' AND m.post_evar3 NOT LIKE 'E6%'))

UNION ALL
SELECT 
    m.*,
    null as client_account_id
FROM metrics m
WHERE m.post_evar3 LIKE 'D3%' 
   OR m.post_evar3 LIKE 'E6%'
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

cd AS (SELECT company_sfdc_id, company_name Company FROM dimension_external_db.pib_company_dimension),

Metrics_COL_BA as(
select 
Metrics_from_ipBA.UTC_Datetime,
Metrics_from_ipBA.JST_Datetime,
Metrics_from_ipBA.JST_year_month,
Metrics_from_ipBA.year_month_day,
Metrics_from_ipBA.week_start,
Metrics_from_ipBA.day_of_week,
Metrics_from_ipBA.fw,
Metrics_from_ipBA.post_evar3,
Metrics_from_ipBA.post_prop22,
Metrics_from_ipBA.post_prop20,
Metrics_from_ipBA.Headlines,
Metrics_from_ipBA.Truc_Headlines,
Metrics_from_ipBA.Product,
Metrics_from_ipBA.country,
Metrics_from_ipBA.geo_city,
Metrics_from_ipBA.geo_zip,
Metrics_from_ipBA.ip,
Metrics_from_ipBA.cycle_date,
Metrics_from_ipBA.browser,
Metrics_from_ipBA.device,
Metrics_from_ipBA.OS_Type,
Metrics_from_ipBA.OS_Version,
Metrics_from_ipBA.visit_id,
Metrics_from_ipBA.mcvisid,
Metrics_from_ipBA.page_views,
Metrics_from_ipBA.article_views,
Metrics_from_ipBA.home_landing,
Metrics_from_ipBA.search_views,
Metrics_from_ipBA.preference,
COALESCE(Metrics_from_ipBA.client_account_id, mem.billing_account_id) AS billing_account_id,
mem.first_name, mem.last_name, mem.email, mem.user_id, mem.user_status, mem.web_registration_date
FROM Metrics_from_ipBA
LEFT JOIN mem on mem.pib_member_id = Metrics_from_ipBA.post_evar3 and Metrics_from_ipBA.client_account_id is null
),

backfill_ini as(
select Metrics_COL_BA.*, cd.company
FROM Metrics_COL_BA
LEFT JOIN bad on Metrics_COL_BA.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN cd  on bad.salesforce_company_two = cd.company_sfdc_id
),

visit_id AS (
  SELECT
    mcvisid,
    post_evar3
  FROM (
    SELECT
      mcvisid,
      post_evar3,
      ROW_NUMBER() OVER (PARTITION BY mcvisid ORDER BY date_time DESC) AS rn
    FROM fact_external_db.omniture_event_fact_hourly omnit
	WHERE reporting_suite = 'djb2byomiuri'
	AND (post_evar3 LIKE 'D3%' OR post_evar3 LIKE 'E6%')

  )
  WHERE rn = 1
),   

backfill as(
SELECT
    m.*,
    COALESCE(v.post_evar3, m.mcvisid) AS post_evar3_adj
FROM backfill_ini AS m
LEFT JOIN visit_id AS v
    ON TRIM(m.mcvisid) = TRIM(v.mcvisid)
),

backfill_final as (
select  
UTC_Datetime,
JST_Datetime,
JST_year_month,
year_month_day,
week_start,
day_of_week,
fw,
post_evar3_adj as post_evar3,
post_prop22,
post_prop20,
Truc_Headlines,
Headlines,
Product,
country,
browser,
device,
OS_Type,
OS_Version,
visit_id,
page_views,
article_views,
home_landing,
search_views,
preference,
first_name,
last_name,
email,
user_id,
user_status,
billing_account_id,
web_registration_date,
company
from backfill
),

Good_ini as(
select date_time as UTC_Datetime, 
date_add('hour', 9, date_time) AS JST_Datetime, 
format_datetime(date_add('hour', 9, date_time), 'yyyy-MM') AS JST_year_month, 
wk.year_month_day, wk.week_start, wk.day_of_week, wk.fw,
post_evar3, post_prop22,  post_prop20, --CAST(visit_num as varchar) as visit_num,
substring(regexp_extract(post_prop22, '^[^_]+_[^_]+_[^_]+_(.+)', 1),1,26) AS Truc_Headlines,
regexp_extract(post_prop22, '^[^_]+_[^_]+_[^_]+_(.+)', 1) AS Headlines,
'Yomiuri' as Product, country, browser,
(case when mobile_id = 0 THEN 'Desktop' ELSE 'Mobile' end) as device,
split_part(split_part(split_part(user_agent,'(',2),')',1),';',1) as OS_Type,
split_part(split_part(split_part(user_agent,'(',2),')',1),';',2) as OS_Version,
(CASE WHEN CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '7',  '8',  '9') 
THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar) || '-' || CAST(visit_start_time_gmt as varchar)) END) as visit_id,
SUM(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) page_views,    
sum( case when post_prop1 = 'Article' then 1 else 0 end) article_views,
sum( case when post_prop1 = 'Home' then 1 else 0 end) home_landing,
sum( case when post_prop1 = 'ResearchTools' then 1 else 0 end) search_views,
sum( case WHEN post_prop1 = 'CustomerResources' then 1 else 0 end) preference
FROM fact_external_db.omniture_event_fact_hourly omnit
left join wk on  format_datetime(date_add('hour', 9, omnit.date_time), 'yyyy-MM-dd') = wk.year_month_day
WHERE reporting_suite = 'djb2byomiuri'
--AND cycle_date >> date_add('day', -800, current_date)
and cycle_date NOT BETWEEN DATE '2025-08-27' AND DATE '2025-10-24'
and post_evar3 <<>> 'D3WZYJ7S5KA2EUQKIGVXCDZ5PM' --EY user, should be exluded.
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
having SUM(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0
),

good_data as(
select Good_ini.*, mem.first_name, mem.last_name, mem.email, mem.user_id, mem.user_status, 
mem.billing_account_id,
mem.web_registration_date, cd.company
FROM Good_ini
LEFT JOIN mem on mem.pib_member_id = Good_ini.post_evar3
LEFT JOIN bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN cd  on bad.salesforce_company_two = cd.company_sfdc_id
)

select *,   
CASE
        WHEN REGEXP_LIKE(Headlines, '^[A-Za-z0-9[:punct:][:space:]]+$') THEN 'English'
        ELSE 'Japanese'
    END AS lang_type

/*
CASE
    WHEN regexp_like(Headlines, '^[\\x00-\\x7F]+$') THEN 'English'
    WHEN regexp_like(Headlines, '[\\x00-\\x7F]') AND regexp_like(Headlines, '[^\\x00-\\x7F]') THEN 'Mixed'
    ELSE 'Japanese'
END AS lang_type
*/
from good_data
union all 
select *,
    CASE
        WHEN REGEXP_LIKE(Headlines, '^[A-Za-z0-9[:punct:][:space:]]+$') THEN 'English'
        ELSE 'Japanese'
    END AS lang_type
from backfill_final)

group by 1,2,3,4,5,6,7,8
