-- Published data source : "B2B Company-level Usage between Classic and New Factiva - Usage"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with

MonthlyDJM as
(SELECT user_info_user_ref EID,
 		SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month,
 		product,
 		COUNT(distinct cycle_date) active_days,
        sum(case when event_name = 'page_view' THEN 1 ELSE 0 END) page_views,
        count(distinct visit_id) visits,
        sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) article_views,
        --sum(CASE WHEN event_name = 'page_view' AND ti_td_action = 'bookmarks' THEN 1 ELSE 0 END) alert_article_views,
        sum(CASE when event_name = 'page_view' 
AND ti_td_search_record_type is not null AND ti_td_page_content_type_detail  = 'search results' and ti_td_module_tracker like '%previous_page_location%'  THEN 1 ELSE 0 end) total_searches
        --sum(CASE WHEN event_name = 'page_view' and ti_td_page_content_type = 'Article' and
        --(ti_td_page_section = 'Saved Articles' or ti_td_module_tracker_previous_page_location = 'savedArticlesTab') THEN 1 ELSE 0 END) saved_article_views,
        --sum(CASE WHEN event_name = 'user_action' AND ti_td_action = 'article_save_add' THEN 1 ELSE 0 end) article_adds,
        --sum(CASE WHEN event_name = 'page_view' AND lower(ti_td_action) = 'bookmarks' THEN 1 ELSE 0 end) alert_landing_pages
        FROM pib_event_data.pib_product_metrics

		WHERE product = 'New Factiva'
		  and cycle_date >>= date('2022-10-01')
        
		GROUP BY 1, 2, 3),

MonthlyOmnit as
(SELECT post_evar3 EID,
 		SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month,
 		'Classic Factiva' product,
 		COUNT(DISTINCT CASE WHEN lower(post_pagename) NOT LIKE '%login%' THEN cycle_date END) active_days,
        SUM(CASE WHEN reporting_suite = 'djfactiva' AND lower(post_pagename) NOT LIKE '%login%' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9'))
      			 THEN 1 ELSE 0 END) page_views,
 
        COUNT(DISTINCT CASE WHEN reporting_suite = 'djfactiva' AND lower(post_pagename) NOT LIKE '%login%' AND CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '7',  '8',  '9')
         THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) visits,
         
        COUNT(CASE WHEN reporting_suite = 'djfactiva' AND (post_evar4 = 'Fact_ART_ArticleView' OR post_prop3='ARTICLE' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
                   		AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8','9'))
                   THEN post_prop20 ELSE NULL END) Article_Views,

        SUM(CASE WHEN reporting_suite = 'djfactiva' AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9')))
                    AND (post_pagename = 'DJ_FF_HeadlineResults' OR post_pagename = 'DJ_FF_SearchBuilder' OR post_pagename = 'DJF_SS_ContemporaryHeadlinesResults' OR post_pagename = 'DJ_FF_SavedSearch' OR post_pagename = 'DJ_FF_SimpleSearch')
                 THEN 1 ELSE 0 END) SearchResults_Views
  
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite in ('djfactiva', 'djappfactiva')
  and cycle_date >>= date('2022-10-01')
  --and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
GROUP BY 1, 2, 3
ORDER BY 1),		
		
Monthly as (
select * from MonthlyDJM
union 
select * from MonthlyOmnit
),
--max_cycle as
--(select user_info_user_ref EID,  
--MAX(cycle_date) last_visit_NF FROM pib_event_data.pib_product_metrics
--WHERE product = 'New Factiva'
--		  and cycle_date >>= date('2022-10-01')
--		  group by 1
--),
		

mem_dim AS ( select
pib_member_id,
user_id,
first_name,
last_name,
plan_id,
email,
billing_account_id,
user_status,
web_registration_date
from dimension_external_db.pib_membership_dimension
where billing_account_id NOT LIKE '9ZFB%'
    and billing_account_id NOT LIKE '9ZZZ%'
group by 1, 2, 3, 4, 5, 6, 7, 8, 9)



SELECT Monthly.year_month,
	   Monthly.product,
	   mem_dim.*,
	   bill.cibs_billing_account_id,
	   bill.salesforce_status,
	   bill.sales_person,
	   bill.account_sales_territory,
	   ter.territory_roll_up,
	   us1.user_full_name as rsd,
	   comp.company_name,
	  -- diges.digest,
	  -- freq.ef,
	   --max_cycle.last_visit as latest_visit,
	   COALESCE(Monthly.active_days, 0) active_days,
	   COALESCE(Monthly.page_views, 0) page_views,
       COALESCE(Monthly.visits, 0) visits,
       COALESCE(Monthly.article_views, 0) article_views,
       COALESCE(Monthly.total_searches, 0) total_searches
      -- COALESCE(alert_art.int_article_count, 0) int_alert_articles_sent,
      -- COALESCE(alert_art.dig_article_count, 0) dig_alert_articles_sent,
      -- COALESCE(Monthly.saved_article_views, 0) total_saved_article_views,
      -- COALESCE(Monthly.article_adds, 0) total_article_saves,
      -- COALESCE(Monthly.alert_article_views, 0) total_alert_article_views,
      --  COALESCE(Monthly.alert_landing_pages, 0) total_alert_landing_pages,
      -- ints.interest_count as onboarding_interests,
      -- lang.lang_count,
      -- avg_time.avg_visit_seconds as avg_visit_length 
  
FROM mem_dim
LEFT JOIN Monthly ON Monthly.EID = mem_dim.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem_dim.billing_account_id = bill.cibs_billing_account_id
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
left join dimension_external_db.pib_territory_dimension ter on bill.account_sales_territory = ter.territory_name
left join dimension_external_db.pib_user_dimension us1 on ter.regional_sales_director = us1.user_sfdc_id
--left join max_cycle on mem_dim.pib_member_id = max_cycle.EID
where active_days >> 0
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23
