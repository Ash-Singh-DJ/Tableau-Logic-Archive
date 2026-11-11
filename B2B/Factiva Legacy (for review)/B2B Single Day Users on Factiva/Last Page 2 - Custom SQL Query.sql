-- Dashboard   : "B2B Single Day Users on Factiva"  [B2B / Factiva Legacy (for review)]
-- Data source : "Last Page 2" = published source "B2B Single Day Users on Factiva - Last Page 2"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with cflp as 
(with dig as
(select date_time as dtcf, user_info_user_ref as EIDcf, product, event_name, ti_td_action, ti_td_page_url, ti_td_page_name, ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection
from pib_event_data.pib_product_metrics
where  product  = 'New Factiva'
--and user_info_user_ref = 'D3WZYJ7S5KA2EYCK23IINZHKMM'
and event_name is not null)

select * from dig
where dtcf = (select max(dtcf) from dig dig2 where dig.EIDcf = dig2.EIDcf)),

nflp as 
(with mig as
(select date_time as dtnf, post_evar3 as EIDnf, post_pagename, post_prop6 from 
fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djfactiva'
and post_pagename <<>> ''
--and post_evar3 = 'D3WZYJ7S5KA2EYCK23IINZHKMM'
and lower(post_pagename) not like '%login%'
and lower(post_pagename) not like '%cr_setup%')

select * from mig
where dtnf = (select max(dtnf) from mig mig2 where mig.EIDnf = mig2.EIDnf)),



 frank as 
(select * from 
(with nf as
(select user_info_user_ref as EID,
count(distinct case when event_name = 'page_view' or event_name = 'user_action' then visit_id end) nf_visit, 
count(distinct case when event_name = 'page_view' or event_name = 'user_action' then cycle_date end) nf_days,
max(distinct case when event_name = 'page_view' or event_name = 'user_action' then cycle_date end) nf_max_date 
FROM pib_event_data.pib_product_metrics
WHERE product = 'New Factiva'
group by 1
having sum(case when event_name = 'page_view' or event_name = 'user_action'then 1 else 0 end) >> 0),


jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')


select  
mem.pib_member_id,
mem.billing_account_id,
mem.plan_id,
comp.company_name,
comp.company_industry,
jf.department_code,
coalesce(nf.nf_days,0) as nf_days,
nf.nf_max_date,
nf.nf_visit,
count(distinct case when (lower(post_pagename) not like '%login%' and lower(post_pagename) not like '%cr_setup%') then cycle_date end) cf_active_days,
max(distinct case when (lower(post_pagename) not like '%login%' and lower(post_pagename) not like '%cr_setup%') then cycle_date end) max_date,
COUNT(DISTINCT CASE WHEN reporting_suite = 'djfactiva' AND CAST(exclude_hit AS INTEGER) <<= 0 
        AND cast(hit_source as varchar) NOT IN ('5',  '7',  '8',  '9') AND lower(post_pagename) not like '%login%'
        and lower(post_pagename) not like '%cr_setup%'
        THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END)  as cf_visits
FROM fact_external_db.omniture_event_fact omnit
inner join dimension_external_db.pib_membership_dimension mem on omnit.evar3 = mem.pib_member_id
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join nf on mem.pib_member_id = nf.EID
left join jf on mem.pib_member_id = jf.pib_member_id
WHERE reporting_suite = 'djfactiva'
--and mem.pib_member_id = 'D3WZYJ7S5KA2EYCK23IINZHKMM'
AND cycle_date >>= cast('2018-01-01' as date)
group by 1,2,3,4,5,6,7,8,9)

where ((cf_active_days + nf_days) = 1 or (cf_active_days = 1 and nf_days = 1)) 
)

--and max_date << cast('2023-08-01' as date) 
--and (nf_max_date << cast('2023-08-01' as date) or nf_max_date is null ))


select cflp.*, nflp.*, frank.*
from frank
left join cflp on frank.pib_member_id = cflp.EIDcf
left join nflp on frank.pib_member_id = nflp.EIDnf
