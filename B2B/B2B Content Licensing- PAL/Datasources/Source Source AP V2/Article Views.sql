-- Published data source : "Source Source AP V2"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "Article Views"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT Source_Code,
         SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
                       CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                  THEN 1 ELSE 0 END) article_views
  	FROM (
	    SELECT date_time, hit_source, post_page_event, exclude_hit, post_evar3, post_evar4, post_prop3, post_pagename, post_prop4, post_prop20,
	           CASE WHEN STRPOS(post_prop8,'_') = 0 THEN UPPER(post_prop8)
	                ELSE UPPER(SUBSTRING(post_prop8,1,STRPOS(post_prop8,'_')-1)) END Source_Code
	    FROM fact_external_db.omniture_event_fact
	    WHERE reporting_suite = 'djfactiva'
	      AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	      --AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	      )
	 WHERE DATE_TRUNC('day',date_time) >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
    	AND DATE_TRUNC('day',date_time) << DATE_TRUNC('month', CURRENT_DATE)

    		 
	 GROUP BY 1
    	
    	HAVING SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
	                      CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                 THEN 1 ELSE 0 END) >> 0

	
	 union all 
	 SELECT 
	 UPPER(substring(ti_td_page_content_source_code, strpos(ti_td_page_content_source_code,'[')+2, strpos(ti_td_page_content_source_code,']') - strpos(ti_td_page_content_source_code,'[')-3)) Source_Code, 

	 sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' and ti_td_article_id is not null THEN 1 ELSE 0 END) article_views
	 from pib_event_data.pib_product_metrics
	 where product = 'New Factiva'
	 --and ti_td_page_content_source_code like '%TRASTC%'
	
	 AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	      --AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	 GROUP BY 1
	 
	 having sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' and ti_td_article_id is not null THEN 1 ELSE 0 END) >> 0
