-- Dashboard   : "B2B New Factiva Off Platform Users"  [B2B / Factiva Legacy (for review)]
-- Data source : "Off Platform Digest users" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with cf as 
(select SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, post_evar3,
COUNT(distinct CASE WHEN cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN cycle_date END) cf_active_days
          
          FROM fact_external_db.omniture_event_fact omnit
          where reporting_suite = 'djfactiva'
          and cycle_date >>= cast('2024-02-01' as date)
          group by 1,2),
 
 nf as 
(select SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, user_info_user_ref, 
count(distinct case when event_name = 'page_view' or event_name = 'user_action' then cycle_date end) nf_active_days
from pib_event_data.pib_product_metrics
where product = 'New Factiva'
and cycle_date >>= cast('2024-02-01' as date)
--and user_info_user_ref = 'D3WZYJ7S5KA2FOPUPHN4PNICME'
group by 1,2)


select 
substring(eventdatetime,1,10) year_month_day,
substring(eventdatetime,1,7) year_month,
op.producttype,
op.senderuserid,
mem.pib_member_id,
op.event,
bill.cibs_billing_account_id,
comp.company_name,
cf.cf_active_days,
nf.nf_active_days

from pib.email_open_rates op
left join dimension_external_db.pib_membership_dimension mem on op.senderuserid = mem.user_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id  
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join cf on (substring(op.eventdatetime,1,7) = cf.year_month and mem.pib_member_id = cf.post_evar3)
left join nf on (substring(op.eventdatetime,1,7) = nf.year_month and mem.pib_member_id = nf.user_info_user_ref)

where cast(substring(op.eventdatetime,1,10) as date) >> cast('2024-02-01' as date)
and producttype in ('iba','sba','sre') 
and op.event = 'Open'
group by 1,2,3,4,5,6,7,8,9,10
