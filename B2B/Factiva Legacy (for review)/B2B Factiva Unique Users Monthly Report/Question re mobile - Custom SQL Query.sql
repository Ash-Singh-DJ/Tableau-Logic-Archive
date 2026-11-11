-- Dashboard   : "B2B Factiva Unique Users Monthly Report"  [B2B / Factiva Legacy (for review)]
-- Data source : "Question re mobile" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, reporting_suite,
case when mobile_id = 0 THEN 'Desktop' ELSE 'Mobile' end as platform,
post_evar3, mem_dim.billing_account_id, mem_dim.plan_id, post_pagename, post_prop10, prod.master_product,


SUM(CASE when reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views



 FROM fact_external_db.omniture_event_fact Omnit
 INNER JOIN dimension_external_db.pib_membership_dimension mem_dim ON mem_dim.pib_member_id = Omnit.post_evar3
left join reference_external_db.pib_product_dimension prod on mem_dim.plan_id = prod.access_code
WHERE reporting_suite in ('djappfactiva','djfactiva')
AND cycle_date >>= cast('2024-03-01' as date)
AND cycle_date <<= cast('2024-03-31' as date)
and mobile_id <<>> 0
--AND cycle_date <<= cast('2022-07-31' as date)
GROUP BY 1,2,3,4,5,6,7,8,9
having SUM(CASE when reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0
