-- Published data source : "B2B DJ Search Dashboard - Factiva Source breakdown"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / reference_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH omnit AS (
	SELECT SUBSTRING(CAST(date_time AS varchar),1,7) year_month, post_evar3, Source_Code, 'Factiva' as platform,
         SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
                       CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                  THEN 1 ELSE 0 END) article_views
             FROM (
	    SELECT date_time, hit_source, post_page_event, exclude_hit, post_evar3, post_evar4, post_prop3, post_pagename, 
	    lag(post_pagename ,1) over(PARTITION BY post_evar3 order by date_time) as page_lag,
	    post_prop4, post_prop20,
	           CASE WHEN STRPOS(post_prop8,'_') = 0 THEN UPPER(post_prop8)
	                ELSE UPPER(SUBSTRING(post_prop8,1,STRPOS(post_prop8,'_')-1)) END Source_Code
	    FROM fact_external_db.omniture_event_fact
	    WHERE reporting_suite = 'djfactiva'
	    --and post_evar3 = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
	      AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	  
	      )
	 WHERE DATE_TRUNC('day',date_time) >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
    	
    	and (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
    	and page_lag in ('DJ_FF_HeadlineResults','Fact_ART_ArticleView', 'DJF_SS_ContemporaryHeadlinesResults' )
    	
    		 
	 GROUP BY 1, 2, 3, 4
    	
    	HAVING SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
	                      CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                 THEN 1 ELSE 0 END) >> 0

	
	 union all 
	 
	 SELECT SUBSTRING(CAST(date_time AS varchar),1,7) year_month, user_info_user_ref as post_evar3,
	 UPPER(substring(ti_td_page_content_source_code, strpos(ti_td_page_content_source_code,'[')+2, strpos(ti_td_page_content_source_code,']') - strpos(ti_td_page_content_source_code,'[')-3)) Source_Code, 
	 'New Factiva' as platform,
	 sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' and ti_td_article_id is not null THEN 1 ELSE 0 END) article_views
	 from pib_event_data.pib_product_metrics
	 where product = 'New Factiva'
     and lower(ti_td_page_section) in ('keyword', 'company', 'industry')
	

	 AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	     
	 GROUP BY 1, 2, 3
	 
	 having sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' and ti_td_article_id is not null THEN 1 ELSE 0 END) >> 0 
	 

),

company_mapping AS (
	SELECT mem.pib_member_id, mem.user_id, 
	       mem.billing_account_id, mem.plan_id, mem.country_code, pm.product_line,
	       pm.master_product, comp.company_name,  comp.company_industry

	FROM dimension_external_db.pib_membership_dimension mem
	LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
	LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
	LEFT JOIN reference_external_db.pib_product_dimension pm ON mem.plan_id = pm.access_code
	LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id
)

SELECT omnit.post_evar3, omnit.Source_code, platform,
year_month,
       company_mapping.*,
  
       SUM(omnit.article_views) article_views
FROM omnit
LEFT JOIN company_mapping ON omnit.post_evar3 = company_mapping.pib_member_id
where company_mapping.plan_id <<>> '0086'  and    company_mapping.plan_id <<>> '0087'
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
