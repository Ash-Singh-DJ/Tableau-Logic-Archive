-- Dashboard   : "B2B Single Day Users on Factiva"  [B2B / Factiva Legacy (for review)]
-- Data source : "Draft3" = published source "B2B Single Day Users on Factiva - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Main query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with nf as
(select substring(cast(cycle_date as varchar),1 ,7) year_month,  user_info_user_ref as EID,
count(distinct case when event_name = 'page_view' or event_name = 'user_action' then visit_id end) nf_visit, 
count(distinct case when event_name = 'page_view' or event_name = 'user_action' then cycle_date end) nf_days 
FROM pib_event_data.pib_product_metrics
WHERE product = 'New Factiva'
group by 1,2
having sum(case when event_name = 'page_view' or event_name = 'user_action'then 1 else 0 end) >> 0),

cy as 
(with lena as 
(select date_time, post_evar3 as EID, geo_country
FROM fact_external_db.omniture_event_fact omnit
where reporting_suite = 'djfactiva'
--and post_evar3 = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
group by 1,2,3)

select * from lena 
where date_time = (select max(date_time) from lena lenb where lena.EID = lenb.EID)),

jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT'),

fka as 
(select post_evar3, min(cycle_date) as first_login 
FROM fact_external_db.omniture_event_fact omnit
WHERE reporting_suite = 'djfactiva'
AND cycle_date >>= cast('2018-01-01' as date)
group by 1)

select
substring(cast(cycle_date as varchar),1 ,7) year_month,
mem.pib_member_id,
mem.web_registration_date, 
mem.billing_account_id,
mem.plan_id,
comp.company_name,
comp.company_industry, 
nf.nf_days,
nf.nf_visit,
cr.region, 
jf.department_code,
fka.first_login,
count(distinct case when (lower(post_pagename) not like '%login%' and lower(post_pagename) not like '%cr_setup%') then cycle_date end) active_days,
COUNT(DISTINCT CASE WHEN reporting_suite = 'djfactiva' AND CAST(exclude_hit AS INTEGER) <<= 0 
        AND cast(hit_source as varchar) NOT IN ('5',  '7',  '8',  '9') AND lower(post_pagename) not like '%login%'
        and lower(post_pagename) not like '%cr_setup%'
        THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END)  as cf_visits
FROM fact_external_db.omniture_event_fact omnit
inner join dimension_external_db.pib_membership_dimension mem on omnit.evar3 = mem.pib_member_id
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
inner join fka on mem.pib_member_id = fka.post_evar3
left join nf on (mem.pib_member_id = nf.EID and substring(cast(omnit.cycle_date as varchar),1 ,7) = nf.year_month)
left join cy on mem.pib_member_id = cy.EID
left join jf on mem.pib_member_id = jf.pib_member_id
left join reference_external_db.country_reference cr on cy.geo_country = lower(cr.geo_country)
WHERE reporting_suite = 'djfactiva'
--and mem.pib_member_id = 'D3WZYJ7S5KA2FDBB6WJMHRCXFI'
AND cycle_date >>= cast('2018-01-01' as date)
group by 1,2,3,4,5,6,7,8,9,10,11,12
