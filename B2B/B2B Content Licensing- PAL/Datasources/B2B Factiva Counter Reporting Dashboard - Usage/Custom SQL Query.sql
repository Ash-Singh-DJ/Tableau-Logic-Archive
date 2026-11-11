-- Published data source : "B2B Factiva Counter Reporting Dashboard - Usage"  [B2B / B2B Content Licensing- PAL / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT bad.cibs_billing_account_id, comp.company_sfdc_id, comp.company_name, 
	   comp.company_country, comp.company_industry, td.territory_name,
           cnt.country_name,
	   bad.account_sales_territory, bad.country as ba_country,
	   cycle_date AS year_month_day,
	   ip AS ip_address,
	   CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar) || '-' || CAST(visit_start_time_gmt AS varchar) AS session_id,
	   mem.user_id,
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
       				AND post_pagename = 'viewed_search_results' THEN 1 ELSE 0 END) app_searches_executed,
       SUM(0) AS article_downloads,
       SUM(0) AS view_selected_articles,
       MIN(date_time) AS session_start_time,
       MAX(date_time) AS session_end_time,
       DATE_DIFF('second', MIN(date_time), MAX(date_time)) AS session_length
FROM fact_external_db.omniture_event_fact omnit
INNER JOIN (SELECT * FROM dimension_external_db.pib_membership_dimension WHERE (status_flag <<>> 'DELETE' OR status_flag IS NULL)) mem ON omnit.post_evar3 = mem.pib_member_id 
LEFT JOIN reference_external_db.country_reference cnt ON omnit.geo_country = cnt.geo_country
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_company_dimension WHERE status_flag <<>> 'DELETE') comp ON bad.salesforce_company_two = comp.company_sfdc_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') td ON comp.company_territory = td.territory_sfdc_id
WHERE reporting_suite IN ('djfactiva','djappfactiva')
	AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -3, CURRENT_DATE)))
	AND (plan_id IN ('0086','0087') AND lower(bad.account_sales_territory) LIKE '%proquest%')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ,11, 12, 13
UNION
SELECT bad.cibs_billing_account_id, comp.company_sfdc_id, comp.company_name, 
	   comp.company_country, comp.company_industry, td.territory_name,
           cnt.country_name,
	   bad.account_sales_territory, bad.country as ba_country,
	   cycle_date AS year_month_day,
	   pm.ti_bd_client_ip_address AS ip_address,
	   pm.user_info_session_id AS session_id,
	   mem.user_id,
	   SUM(0) AS desktop_page_views,
	   SUM(0) AS factiva_app_page_views,
	   SUM(0) AS desktop_article_views,
	   SUM(0) AS app_article_views,
	   SUM(0) AS desktop_searches_executed, 
	   SUM(0) AS app_searches_executed,
	   SUM(CASE WHEN pm.ti_td_ad_article_count IS NOT NULL 
	   				AND (pm.ti_td_action LIKE 'download_%'
	   					OR pm.ti_td_action LIKE 'print_%'
	   					OR pm.ti_td_action LIKE 'save_%'
	   					OR pm.ti_td_action LIKE 'email_%') THEN pm.ti_td_ad_article_count ELSE 0 END) AS article_downloads,
	   SUM(CASE WHEN pm.ti_td_ad_article_count IS NOT NULL
	   				AND pm.ti_td_action LIKE 'view_selected_%'
	   			THEN pm.ti_td_ad_article_count ELSE 0 END) AS view_selected_articles,
	   MIN(date_time) AS session_start_time,
       MAX(date_time) AS session_end_time,
       DATE_DIFF('second', MIN(date_time), MAX(date_time)) AS session_length
FROM pib_event_data.pib_product_metrics pm
INNER JOIN (SELECT * FROM dimension_external_db.pib_membership_dimension WHERE (status_flag <<>> 'DELETE' OR status_flag IS NULL)) mem ON pm.user_info_user_ref = mem.pib_member_id 
LEFT JOIN reference_external_db.country_reference cnt ON mem.country_code = cnt.edw_code
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_company_dimension WHERE status_flag <<>> 'DELETE') comp ON bad.salesforce_company_two = comp.company_sfdc_id 
LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') td ON comp.company_territory = td.territory_sfdc_id
WHERE pm.product_code = 'FACT'
	AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -3, CURRENT_DATE)))
	AND (plan_id IN ('0086','0087') AND lower(bad.account_sales_territory) LIKE '%proquest%')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ,11, 12, 13
