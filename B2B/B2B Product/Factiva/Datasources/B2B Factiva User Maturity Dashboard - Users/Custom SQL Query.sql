-- Published data source : "B2B Factiva User Maturity Dashboard - Users"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 

jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT'),



cld as 
( select post_evar3 as eid,
MIN(CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' then cycle_date END) as min_login
          
 FROM fact_external_db.omniture_event_fact
 where reporting_suite = 'djfactiva' 
 group by 1),
 
 nld as 
 (select user_info_user_ref as eid,
 min(case when event_name = 'page_view' or event_name = 'user_action' THEN cycle_date END) min_login
 from pib_event_data.pib_product_metrics
 where product = 'New Factiva'
 group by 1),


nf as
(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, mem.web_registration_date, 
mem.pib_member_id, mem.billing_account_id, mem.plan_id, mem.user_id, mem.first_name, mem.last_name,jf.department_code,
(case when billing_account_id in

(WITH dataset AS ( 
    SELECT * FROM   
        (  select client_name, product, migration_date, split(billing_accounts,',')
     FROM google_sheets_db.saml_master_list_b2b_current
     where product like '%Factiva%'

 ) AS t (client_name, product, migration_date, metrics_array))

select metric as saml_billing_account
from dataset
cross join unnest(metrics_array) as t(metric))
then 'saml_billing_account' end) as saml,

comp.company_name, 'New Factiva' as platform,
nld.min_login,
count(distinct case when event_name = 'page_view' or event_name = 'user_action' THEN cycle_date END) active_days,
max(case when event_name = 'page_view' or event_name = 'user_action' THEN cycle_date END) max_date_in_mth
   
      from pib_event_data.pib_product_metrics omni


join dimension_external_db.pib_membership_dimension mem on omni.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join nld on omni.user_info_user_ref = nld.eid
left join jf on mem.pib_member_id = jf.pib_member_id

where product = 'New Factiva'
AND cycle_date >> date_add('day', -400, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
having sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) >> 0),

cf as (
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, mem.web_registration_date,  
mem.pib_member_id, mem.billing_account_id, mem.plan_id, mem.user_id, mem.first_name, mem.last_name, jf.department_code,

(case when billing_account_id in

(WITH dataset AS ( 
    SELECT * FROM   
        (  select client_name, product, migration_date, split(billing_accounts,',')
     FROM google_sheets_db.saml_master_list_b2b_current
     where product like '%Factiva%'

 ) AS t (client_name, product, migration_date, metrics_array))

select metric as saml_billing_account
from dataset
cross join unnest(metrics_array) as t(metric))
then 'saml_billing_account' end) as saml,
comp.company_name, 'Classic Factiva' as platform,
cld.min_login,


count(distinct CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' then cycle_date END) active_days,
          
          
max(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' then cycle_date END) max_date_in_mth
        

FROM fact_external_db.omniture_event_fact omni
join dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join cld on omni.post_evar3 = cld.eid
left join jf on mem.pib_member_id = jf.pib_member_id

WHERE reporting_suite = 'djfactiva'
AND cycle_date >> date_add('day', -400, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
having SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0)
        
        
        select * from cf     
        union all
        select * from nf
