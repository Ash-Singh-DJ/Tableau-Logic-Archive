-- Dashboard   : "B2B Factiva Counter Reporting Dashboard"  [B2B / B2B Content Licensing- PAL]
-- Data source : "B2B Factiva Counter Report Query (dimension_external_db)" = published source "B2B Factiva Counter Reporting Dashboard - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Counter Report Query"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT bad.cibs_billing_account_id, comp.company_sfdc_id, comp.company_name, 
	   comp.company_country, comp.company_industry, td.territory_name,
	   bad.account_sales_territory,
	   CASE WHEN STRPOS(post_prop8,'_') = 0 THEN UPPER(post_prop8) ELSE UPPER(SUBSTRING(post_prop8,1,STRPOS(post_prop8,'_')-1)) END AS source_code,
	   CASE WHEN post_prop3 = 'PDF' THEN 'PDF' ELSE 'HTML' END article_view_type,
	   SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month,
	   SUM(CASE WHEN reporting_suite = 'djfactiva' AND lower(post_pagename) NOT LIKE '%login%' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) 
                  THEN 1 ELSE 0 END) desktop_page_views,
       CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0' 
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' 
                       THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0'
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') 
                       THEN (.34)
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 <<>> 'viewed_article' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) 
                       THEN 1 ELSE 0 END)) factiva_app_page_views,
	   COUNT(CASE WHEN reporting_suite = 'djfactiva' AND (post_evar4 = 'Fact_ART_ArticleView' OR post_prop3='ARTICLE' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' 
	   				OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
                    AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8','9')) 
                  THEN post_prop20 ELSE NULL END) desktop_article_views,
	   CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0'
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' 
                     THEN 1
                     WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0'
                       	 AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') 
                     THEN (.34) ELSE 0 END)) app_article_views,
       SUM(CASE WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 
       				AND CAST(hit_source AS varchar) NOT IN ('5', '8','9')) 
       				AND ((post_pagename LIKE '%HeadlineResults%' 
       				AND (lower(post_referrer) LIKE '%napc=s%' OR lower(post_referrer) LIKE '%napc=g%'))
       				OR post_pagename LIKE '%DJF_SS_ContemporaryHeadlinesResults%') THEN 1 ELSE 0 END) AS desktop_searches_executed,
       SUM(CASE WHEN reporting_suite = 'djappfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 
       				AND CAST(hit_source AS varchar) NOT IN ('5', '8','9')) 
       				AND post_pagename = 'viewed_search_results' THEN 1 ELSE 0 END) app_searches_executed
FROM fact_external_db.omniture_event_fact omnit
INNER JOIN (SELECT * FROM dimension_external_db.pib_membership_dimension WHERE (status_flag <<>> 'DELETE' OR status_flag IS NULL)) mem ON omnit.post_evar3 = mem.pib_member_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_company_dimension WHERE status_flag <<>> 'DELETE') comp ON bad.salesforce_company_two = comp.company_sfdc_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') td ON comp.company_territory = td.territory_sfdc_id
WHERE reporting_suite IN ('djfactiva','djappfactiva')
	AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -24, CURRENT_DATE)))
	AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	AND (plan_id IN ('0086','0087') AND lower(bad.account_sales_territory) LIKE '%proquest%')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
