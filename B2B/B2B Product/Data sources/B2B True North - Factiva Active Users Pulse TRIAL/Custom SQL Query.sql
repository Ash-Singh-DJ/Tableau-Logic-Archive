-- Published data source : "B2B True North - Factiva Active Users Pulse TRIAL"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with

dat as 

(select substring(cast(full_date as varchar),1,10) as full_date, substring(cast(week_start_date as varchar),1,10) as wsd,  
day_of_week as dow
from  reference_external_db.date_dimension 
where full_date >> date_add('day', -800, current_date)
),

nf as
(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) day_date, dat.wsd, dat.dow,
mem.pib_member_id, mem.billing_account_id, comp.company_name, comp.company_industry,  'New Factiva' as platform, mem.plan_id,
prod.master_product, prod.product_line,

sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) desktop_page_views,

sum(case when (event_name = 'page_view' or event_name = 'user_action') and ti_td_article_id 
is not null THEN 1 ELSE 0 END) article_views

   
      from pib_event_data.pib_product_metrics omni


join dimension_external_db.pib_membership_dimension mem on omni.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join reference_external_db.pib_product_dimension prod on mem.plan_id = prod.access_code 
left join dat on SUBSTRING(CAST(omni.cycle_date AS varchar), 1, 10) = dat.full_date

where product = 'New Factiva'
AND cycle_date >> date_add('day', -800, current_date)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11
having sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) >> 0),

cf as (
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) day_date, dat.wsd, dat.dow,
mem.pib_member_id, mem.billing_account_id, comp.company_name, comp.company_industry, 'Classic Factiva Desktop' as platform, mem.plan_id,
prod.master_product, prod.product_line,


SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views,
        
        COUNT(CASE WHEN reporting_suite = 'djfactiva' AND (post_evar4 = 'Fact_ART_ArticleView' OR post_prop3='ARTICLE' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' 
	OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
        AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8','9')) 
        THEN post_prop20 ELSE NULL END) article_views
        

FROM fact_external_db.omniture_event_fact omni
join dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join reference_external_db.pib_product_dimension prod on mem.plan_id = prod.access_code 
left join dat on SUBSTRING(CAST(omni.cycle_date AS varchar), 1, 10) = dat.full_date

WHERE reporting_suite = 'djfactiva'
AND cycle_date >> date_add('day', -800, current_date)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11
having SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0),
        
app as (
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) day_date, dat.wsd, dat.dow,
mem.pib_member_id, mem.billing_account_id, comp.company_name, comp.company_industry, 
 'Factiva App' as platform, mem.plan_id, prod.master_product, prod.product_line,

CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                         AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                        AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') THEN (.34)
                        WHEN reporting_suite = 'djappfactiva' AND post_evar4 <<>> 'viewed_article' AND cast(post_page_event as varchar) = '0'  AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
                       THEN 1 ELSE 0 END)) desktop_page_views,
                       
                      
CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0'
                         AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0'
                        AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') 
                       THEN (.34) ELSE 0 END)) article_views
        

FROM fact_external_db.omniture_event_fact omni
join dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join reference_external_db.pib_product_dimension prod on mem.plan_id = prod.access_code 
left join dat on SUBSTRING(CAST(omni.cycle_date AS varchar), 1, 10) = dat.full_date

WHERE reporting_suite = 'djappfactiva'
AND cycle_date >> date_add('day', -800, current_date)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11
having CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                         AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                        AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') THEN (.34)
                        WHEN reporting_suite = 'djappfactiva' AND post_evar4 <<>> 'viewed_article' AND cast(post_page_event as varchar) = '0'  AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
                       THEN 1 ELSE 0 end)) >> 0)
        
        select * from cf     
        union all
        select * from nf
        union all
        select * from app order by 1
