-- Published data source : "B2B True North - DJDN Source Usage"  [B2B / B2B Product / Data sources / True North Metrics Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month,


COUNT(CASE WHEN reporting_suite = 'djfactiva' AND (post_evar4 = 'Fact_ART_ArticleView' OR post_prop3='ARTICLE' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' 
	OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
        AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8','9'))
        and lower(post_prop8) like '%djdn_%'
        THEN post_prop20 ELSE NULL END) DJDN_desktop_article_views,
        
 COUNT(CASE WHEN reporting_suite = 'djfactiva' AND (post_evar4 = 'Fact_ART_ArticleView' OR post_prop3='ARTICLE' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' 
	OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
        AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8','9'))
        THEN post_prop20 ELSE NULL END) desktop_article_views       



 FROM fact_external_db.omniture_event_fact omnit
 left join dimension_external_db.pib_membership_dimension pmd on omnit.post_evar3 = pmd.pib_member_id
WHERE reporting_suite = 'djfactiva'
AND cycle_date >> date_add('day', -400, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
and pmd.billing_account_id  not like '9ZFB%'
and pmd.billing_account_id  not like '9ZZZ%'
and pmd.billing_account_id  <<>> '9DOW003600'
and pmd.billing_account_id  <<>> '9DOW007100'
and pmd.billing_account_id  <<>> '9FAC067700'
GROUP BY 1
