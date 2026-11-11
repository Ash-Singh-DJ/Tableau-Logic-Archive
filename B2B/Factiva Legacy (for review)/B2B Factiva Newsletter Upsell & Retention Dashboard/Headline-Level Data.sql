-- Dashboard   : " B2B Factiva Newsletter Upsell & Retention Dashboard"  [B2B / Factiva Legacy (for review)]
-- Data source : "Headline-Level Data" = published source "B2B Factiva Newsletter Upsell & Retention - Headline-Level Data"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH omnit as (
  SELECT *
  FROM
	(SELECT post_evar3, SUBSTRING(CAST(date_time AS varchar),1,7) year_month, post_prop40, post_prop4,
			CASE WHEN STRPOS(post_prop8,'_') = 0 THEN UPPER(post_prop8)
                        ELSE UPPER(SUBSTRING(post_prop8,1,STRPOS(post_prop8,'_')-1)) END AS source_code,
            SUM(CASE WHEN CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> ''
                    AND (post_campaign LIKE 'newsletter%' OR post_evar11 = 'MyCompanyToday') THEN 1 ELSE 0 END)
                    	AS Newsletter_Article_Views,
	        SUM(CASE WHEN CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' 
                    AND (post_evar11 <<>> 'MyCompanyToday' OR post_evar11 IS NULL)
                    AND post_campaign LIKE 'newsletter%' THEN 1 ELSE 0 END) 
                    	AS Non_MCT_Newsletter_Article_Views,
            SUM(CASE WHEN CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' AND post_evar11 = 'MyCompanyToday' THEN 1 ELSE 0 END)
                    	AS MCT_Newsletter_Article_Views
	  FROM (
	    SELECT date_time, hit_source, post_page_event, exclude_hit, post_evar3, post_evar4, post_prop3, post_pagename, 
	    	   post_prop4, post_prop20, post_campaign, post_prop40, post_evar11, post_prop8
	    FROM fact_external_db.omniture_event_fact
	    WHERE reporting_suite = 'djfactiva'
	      AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	      AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	     ) omnit
	  WHERE date_time >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	    AND date_time <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	  GROUP BY 1, 2, 3, 4, 5)
  WHERE Newsletter_Article_Views >> 0)
 

SELECT mem.billing_account_id, omnit.year_month,
	   omnit.post_prop40 AS newsletter_name, omnit.post_prop4 AS headline,
	   comp.company_name, salesforce_status as ba_status,
       ud.user_full_name as sales_person, territory_name as account_sales_territory,
       account_sales_region, regional_sales_director as rsd_id,
       rsdud.user_full_name as rsd,
       omnit.source_code AS adobe_source_code,
       sc.sourcecode AS source_code, sc.sourcename AS source_name,
       SUM(COALESCE(Newsletter_Article_Views,0)) newsletter_article_views,
       SUM(COALESCE(Non_MCT_Newsletter_Article_Views,0)) non_mct_newsletter_article_views,
       SUM(COALESCE(MCT_Newsletter_Article_Views,0)) mct_newsletter_article_views
FROM omnit 
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON omnit.post_evar3 = mem.pib_member_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension ud ON comp.owner_id = ud.user_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension rsdud ON td.regional_sales_director = rsdud.user_sfdc_id
LEFT JOIN sandbox_mk.factiva_content_source_current sc ON omnit.source_code = sc.sourcecode 
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
