-- Published data source : "B2B True North - R&C and NP Active Users"  [B2B / B2B Product / Data sources / True North Metrics Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with

dat as 

(select substring(cast(full_date as varchar),1,10) as full_date, substring(cast(week_start_date as varchar),1,10) as wsd, concat(cast(fiscal_year as varchar),'-',cast(month_number_in_fiscal_year as varchar)) as fiscal_ym,
week_number_in_fiscal_year as fw, day_of_week as dow
from  reference_external_db.date_dimension 
where full_date >> date_add('day', -800, current_date)
),

rcfc as
(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, dat.wsd, dat.fw, dat.fiscal_ym, 
mem.pib_member_id, null as email, mem.billing_account_id, comp.company_name, product as platform, dat.dow,
null AS URL_Base,
sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) desktop_page_views
   
      from pib_event_data.pib_product_metrics omni


join dimension_external_db.pib_membership_dimension mem on omni.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dat on SUBSTRING(CAST(omni.cycle_date AS varchar), 1, 10) = dat.full_date

where product in ('Financial Crime', 'Trade Compliance')
AND cycle_date >> date_add('day', -800, current_date)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11
having sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) >> 0),

rc as (
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, dat.wsd, dat.fw, dat.fiscal_ym,  
mem.pib_member_id, null as email, mem.billing_account_id, comp.company_name,  'RiskCenter' as platform, dat.dow,
null AS URL_Base,

SUM(CASE WHEN reporting_suite ='djriskcomplianceprod' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views
        

FROM fact_external_db.omniture_event_fact omni
join dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dat on SUBSTRING(CAST(omni.cycle_date AS varchar), 1, 10) = dat.full_date

WHERE reporting_suite = 'djriskcomplianceprod'
AND cycle_date >> date_add('day', -800, current_date)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11
having SUM(CASE WHEN reporting_suite = 'djriskcomplianceprod' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0),
        
        
np as
(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, dat.wsd, dat.fw, dat.fiscal_ym, 
mem.pib_member_id, null as email, mem.billing_account_id, comp.company_name,  'Newsplus' as platform, dat.dow,
REGEXP_EXTRACT(ti_td_page_url, 'https?://[^/]+\.com') AS URL_Base,
sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) desktop_page_views
   
      from pib_event_data.pib_product_metrics omni


join dimension_external_db.pib_membership_dimension mem on omni.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dat on SUBSTRING(CAST(omni.cycle_date AS varchar), 1, 10) = dat.full_date

where product = 'NewsPlus'
AND cycle_date >> date_add('day', -800, current_date)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11
having sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) >> 0),

yom as 
(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, dat.wsd, dat.fw, dat.fiscal_ym, 
mem.pib_member_id, mem.email, mem.billing_account_id, comp.company_name,  'Yomiuri' as platform, dat.dow,
null AS URL_Base,
SUM(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views
   
     FROM fact_external_db.omniture_event_fact_hourly omni
     
join dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dat on SUBSTRING(CAST(omni.cycle_date AS varchar), 1, 10) = dat.full_date

 WHERE reporting_suite = 'djb2byomiuri'
AND cycle_date >> date_add('day', -800, current_date)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11
having 
SUM(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0),
        
rj as 
(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, dat.wsd, dat.fw, dat.fiscal_ym, 
mem.pib_member_id, null as email, mem.billing_account_id, comp.company_name,  'Risk Journal' as platform, dat.dow,
null AS URL_Base,
SUM(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views
   
     FROM fact_external_db.omniture_event_fact_hourly omni
     
join dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dat on SUBSTRING(CAST(omni.cycle_date AS varchar), 1, 10) = dat.full_date

 WHERE reporting_suite = 'djb2briskjournal'
AND cycle_date >> date_add('day', -800, current_date)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11
having 
SUM(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0)

   

        select * from rcfc     
        union all
        select * from rc
        union all
        select * from np
        union all
        select * from yom
        union all
        select * from rj
