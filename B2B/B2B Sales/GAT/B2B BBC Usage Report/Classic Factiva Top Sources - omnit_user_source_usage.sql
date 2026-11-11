-- Dashboard   : "B2B BBC Usage Report"  [B2B / B2B Sales / GAT]
-- Data source : "Classic Factiva Top Sources" (embedded in the workbook)
-- Relation    : Custom SQL "omnit_user_source_usage"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH omnit AS (
	SELECT SUBSTRING(CAST(date_time AS varchar),1,10) year_month_day, post_evar3, Source_Code,
         SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
                       CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                  THEN 1 ELSE 0 END) article_views,
	SUM(CASE WHEN cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND 
	cast(hit_source as varchar) NOT IN ('5',  '8',  '9')) AND ((post_prop6 LIKE '%email%' or post_prop6 LIKE '%Email%')
	AND (post_campaign in ('Alert', 'alert_sidelink'))) AND lower(post_pagename) LIKE '%article%' 
	THEN 1 ELSE 0 END) Alert_Landing_page_views,
 	
	--SUM(CASE WHEN CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND post_prop60 <<>> '' AND post_prop60 not like 'i%' THEN 1
    --        ELSE 0 END) Company_Interactions,
	
	SUM(CASE WHEN (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
         AND (post_pagename = 'DJ_FF_HeadlineResults' OR post_pagename = 'DJ_FF_SearchBuilder' OR post_pagename = 'DJF_SS_ContemporaryHeadlinesResults' 
         OR post_pagename = 'DJ_FF_SavedSearch' OR post_pagename = 'DJ_FF_SimpleSearch') THEN 1 ELSE 0 END) SearchResults_Views,

	SUM(CASE WHEN  (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
                    AND (post_pagename <<>> '' 
                    AND post_pagename LIKE '%_RT_%' 
                    AND post_pagename NOT LIKE '%_SrcInfo_%' 
                    AND post_pagename NOT LIKE '%_Newsletter%' 
                    AND post_pagename NOT LIKE '%_RegInfo_%' 
                    AND post_pagename NOT LIKE '%_Chart%' 
                    AND post_pagename NOT LIKE '%_FES_%' 
                    AND post_pagename NOT LIKE '%_RSS%' 
                    AND post_pagename NOT LIKE 'Fact_Article_%' 
                    AND post_pagename NOT LIKE 'Fact_ART_%' 
                    AND post_pagename NOT LIKE 'Fact_RT_My Analytics%' 
                    AND lower(post_pagename) NOT LIKE '%alert%') 
                  THEN 1 ELSE 0 END) CnE_Views,         
    SUM(CASE WHEN cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND post_prop35 LIKE 'SB:%' THEN 1 ELSE 0 END) expert_searches   
         
  	FROM (
	    SELECT date_time, hit_source, post_page_event, exclude_hit, post_evar3, post_evar4, post_prop3, post_pagename, post_prop4, post_prop20, post_prop6,post_campaign,post_prop60,post_prop35,
	           CASE WHEN STRPOS(post_prop8,'_') = 0 THEN UPPER(post_prop8)
	                ELSE UPPER(SUBSTRING(post_prop8,1,STRPOS(post_prop8,'_')-1)) END Source_Code
	    FROM fact_external_db.omniture_event_fact
	    WHERE reporting_suite = 'djfactiva'
	      AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -36, CURRENT_DATE)))
	      AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	      )
	 WHERE DATE_TRUNC('day',date_time) >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -36, CURRENT_DATE)))
    	AND DATE_TRUNC('day',date_time) << DATE_TRUNC('month', CURRENT_DATE)    	
	 GROUP BY 1, 2, 3
),

company_mapping AS (
	SELECT mem.pib_member_id, mem.user_id, mem.first_name, mem.last_name, mem.email, 
	       mem.billing_account_id, mem.plan_id, mem.country_code, pm.product_line,
	       pm.master_product, comp.company_name, comp.company_country, comp.company_industry,
	       td.territory_name, bad.account_sales_territory
	FROM dimension_external_db.pib_membership_dimension mem
	LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
	LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
	LEFT JOIN reference_external_db.pib_product_dimension pm ON mem.plan_id = pm.access_code
	LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id
)

SELECT omnit.post_evar3, omnit.Source_code,
       -DATE_DIFF('month', DATE_TRUNC('month',CAST(year_month_day as date)), DATE_TRUNC('month',CURRENT_DATE)) as month_num,
       company_mapping.*,
       cnt.*,
       SUM(omnit.article_views) article_views,
       SUM(omnit.Alert_Landing_page_views) Alert_Landing_page_views,
       --SUM(omnit.Company_Interactions) Company_Interactions,
       SUM(omnit.SearchResults_Views) SearchResults_Views,
       SUM(omnit.CnE_Views) CnE_Views,
       SUM(omnit.expert_searches) expert_searches
       
FROM omnit
LEFT JOIN company_mapping ON omnit.post_evar3 = company_mapping.pib_member_id
LEFT JOIN reference_external_db.country_reference cnt ON company_mapping.country_code = cnt.edw_code 
where --company_mapping.company_name ='Bain & Company Inc'
company_mapping.billing_account_id in ('9BBC002100')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22
