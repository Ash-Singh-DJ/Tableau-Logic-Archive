-- Dashboard   : "Factiva Homepage Modules"  [B2B / B2B Sales / Product Usage]
-- Data source : "Homepage Modules" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with

dat as 

(select substring(cast(full_date as varchar),1,10) as full_date, substring(cast(week_start_date as varchar),1,10) as wsd,  week_number_in_fiscal_year as fw,
day_of_week as dow
from  reference_external_db.date_dimension 
where full_date >> date_add('day', -1200, current_date)
),

jf as 

(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')


SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) as year_month_day, dat.wsd, 
SUBSTRING(CAST(cycle_date AS varchar), 1, 7) as year_month,
post_evar3, post_prop53, 
 mem.pib_member_id, mem.plan_id, mem.user_id, comp.company_name, comp.company_industry, jf.department_code,

SUM(CASE WHEN reporting_suite = 'djfactiva' AND (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
     AND post_pagename like 'DJF_SS_%' THEN 1 ELSE 0 END) Homepage_Views


FROM fact_external_db.omniture_event_fact omnit
JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = omnit.post_evar3
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join dat on SUBSTRING(CAST(omnit.cycle_date AS varchar), 1, 10) = dat.full_date
left join jf on mem.pib_member_id = jf.pib_member_id
WHERE reporting_suite = 'djfactiva'
and post_pagename like 'DJF_SS_%'
and post_prop53 not like '%|%'
and post_prop53 <<>> ''
and mem.billing_account_id not like '9ZZZ%'
and mem.billing_account_id not like '9ZFB%'
and mem.billing_account_id <<>> '9DOW003600'
and mem.billing_account_id <<>> '9DOW007100'
and mem.billing_account_id <<>> '9FAC067700'

AND cycle_date >>= cast('2025-09-01' as date)


GROUP BY 1,2,3,4,5,6,7,8,9,10,11

having SUM(CASE WHEN reporting_suite = 'djfactiva' AND (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
     AND post_pagename like 'DJF_SS_%' THEN 1 ELSE 0 END) >> 0
