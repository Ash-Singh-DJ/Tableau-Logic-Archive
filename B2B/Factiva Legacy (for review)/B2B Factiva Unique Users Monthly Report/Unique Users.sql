-- Dashboard   : "B2B Factiva Unique Users Monthly Report"  [B2B / Factiva Legacy (for review)]
-- Data source : "Unique Users" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, reporting_suite,
case when mobile_id = 0 THEN 'Desktop' ELSE 'Mobile' end as platform,
post_evar3, mem_dim.billing_account_id,


SUM(CASE when reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views,

CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                         AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                        AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') THEN (.34)
                        WHEN reporting_suite = 'djappfactiva' AND post_evar4 <<>> 'viewed_article' AND cast(post_page_event as varchar) = '0'  AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
                       THEN 1 ELSE 0 END)) app_page_views,
                       null as new_fact_page_views
                       

 FROM fact_external_db.omniture_event_fact Omnit
 INNER JOIN dimension_external_db.pib_membership_dimension mem_dim ON mem_dim.pib_member_id = Omnit.post_evar3
WHERE reporting_suite in ('djappfactiva','djfactiva')
AND cycle_date >>= cast('2020-01-01' as date)
--AND cycle_date <<= cast('2022-07-31' as date)
GROUP BY 1,2,3,4,5
having SUM(CASE when reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0  
        or 
        
        CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                         AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                        AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') THEN (.34)
                        WHEN reporting_suite = 'djappfactiva' AND post_evar4 <<>> 'viewed_article' AND cast(post_page_event as varchar) = '0'  AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
                       THEN 1 ELSE 0 END)) >> 0
        
union all

SELECT 
               
               substring(cast(djm.cycle_date as varchar),1,7) year_month,
               product as reporting_suite,
               ti_td_page_content_platform_presentation as platform,
		djm.user_info_user_ref as post_evar3,
        djm.user_info_account_id as billing_account_id,
        null as desktop_page_views,
        null as app_page_views,
        sum(case when djm.event_name = 'page_view' or djm.event_name = 'user_action'  THEN 1 ELSE 0 END) new_fact_page_views
        
FROM pib_event_data.pib_product_metrics djm
INNER JOIN dimension_external_db.pib_membership_dimension mem_dim ON mem_dim.pib_member_id = djm.user_info_user_ref
WHERE product = 'New Factiva'
AND cycle_date >>= cast('2020-01-01' as date)
--AND cycle_date <<= cast('2022-08-31' as date)
group by 1,2,3,4,5,5,6,7
having sum(case when djm.event_name = 'page_view' or djm.event_name = 'user_action'  THEN 1 ELSE 0 END) >> 0
