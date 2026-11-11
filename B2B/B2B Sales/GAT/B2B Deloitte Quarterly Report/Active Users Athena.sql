-- Dashboard   : "B2B Deloitte Quarterly Report"  [B2B / B2B Sales / GAT]
-- Data source : "Active Users Athena" (embedded in the workbook)
-- Relation    : Custom SQL "custom_sql_query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH
omnit as (select post_evar3, SUM(CASE
        WHEN cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9') and lower(post_pagename) not like '%login%') THEN 1
        ELSE 0 END) page_views
                from fact_external_db.omniture_event_fact
                where reporting_suite in ('djfactiva','djappfactiva','factivadjnewsplusprod', 'djriskcomplianceprod')
                AND cycle_date >> date_add('day', -182, current_date)
              
                
                group by post_evar3
                having SUM(CASE
        WHEN cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9')) THEN 1
        ELSE 0 END) >> 0)
                

SELECT  comp.company_name, comp.company_industry, comp.company_country, mem.plan_id,
 pm.master_product, pm.product_line, pm.bu, count(distinct mem.pib_member_id) active_users          
from dimension_external_db.pib_membership_dimension mem
JOIN omnit ON omnit.post_evar3 = mem.eid
LEFT JOIN reference_external_db.pib_product_dimension prod ON mem.plan_id = prod.access_code  
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN reference_external_db.pib_product_dimension pm ON mem.plan_id = pm.access_code
where user_status = 'A'
group by 1,2,3,4,5,6,7
