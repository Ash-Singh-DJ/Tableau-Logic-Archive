-- Dashboard   : "B2B Classic Factiva Usage Dashboard"  [B2B / B2B Product / Factiva]
-- Data source : "Usage Athena" = published source "B2B Classic Factiva Usage Dashboard - Usage Athena"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "usage_main"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH Omnit AS ( 

SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
CONCAT(CAST((year(cycle_date)) as varchar), '-', CAST((week(cycle_date)) as varchar)) as year_cal_week,
post_evar3,
geo_country,
mobile_id,
post_prop40,
'Factiva' as Platform,


SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views,

COUNT(DISTINCT CASE WHEN reporting_suite = 'djfactiva' AND CAST(exclude_hit AS INTEGER) <<= 0 
        AND cast(hit_source as varchar) NOT IN ('5',  '7',  '8',  '9') AND lower(post_pagename) not like '%login%' 
        THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) desktop_visits,

COUNT(DISTINCT CASE WHEN reporting_suite = 'djappfactiva' AND CAST(exclude_hit AS INTEGER) <<= 0 
        AND cast(hit_source as varchar) NOT IN ('5',  '7',  '8',  '9')  
        THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) app_visits,

COUNT(DISTINCT CASE WHEN reporting_suite = 'djriskcomplianceprod' AND CAST(exclude_hit AS INTEGER) <<= 0 
        AND cast(hit_source as varchar) NOT IN ('5',  '7',  '8',  '9')  
        THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) RnC_visits,

COUNT(DISTINCT CASE WHEN reporting_suite = 'factivadjnewsplusprod' AND CAST(exclude_hit AS INTEGER) <<= 0 
        AND cast(hit_source as varchar) NOT IN ('5',  '7',  '8',  '9')  
        THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) newsplus_visits, 

COUNT(CASE WHEN reporting_suite = 'djfactiva' AND (post_evar4 = 'Fact_ART_ArticleView' OR post_prop3='ARTICLE' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' 
	OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
        AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8','9')) 
        THEN post_prop20 ELSE NULL END) desktop_article_views,

SUM(CASE WHEN reporting_suite = 'djfactiva' AND (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
         AND (post_pagename = 'DJ_FF_HeadlineResults' OR post_pagename = 'DJ_FF_SearchBuilder' OR post_pagename = 'DJF_SS_ContemporaryHeadlinesResults' 
         OR post_pagename = 'DJ_FF_SavedSearch' OR post_pagename = 'DJ_FF_SimpleSearch') THEN 1 ELSE 0 END) SearchResults_Views,


SUM(CASE WHEN reporting_suite = 'djfactiva' AND (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
     AND (post_pagename like 'DJF_SS_%'
         AND post_pagename <<>> '' 
                    AND post_pagename <<>> 'DJF_SS_ArticleOverlay_0021' 
                    AND post_pagename <<>> 'DJF_SS_Contemporary_ArticleView' 
                    AND post_pagename <<>> 'DJF_SS_ContemporaryHeadlinesResults' 
                    AND post_pagename <<>> 'DJF_SS_ContemporaryHeadlinesAlert' 
                    AND post_pagename <<>> 'DJF_SS_AdminWorkspace_0001')  
                  THEN 1 ELSE 0 END) Homepage_Views,

SUM(CASE WHEN reporting_suite = 'djfactiva' AND (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
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

SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND 
	cast(hit_source as varchar) NOT IN ('5',  '8',  '9')) AND ((post_prop6 LIKE '%email%' or post_prop6 LIKE '%Email%')
	AND (post_campaign in ('Alert', 'alert_sidelink'))) AND lower(post_pagename) LIKE '%article%' 
	THEN 1 ELSE 0 END) Alert_Landing_page_views,

SUM(CASE WHEN cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
	AND (post_pagename IN ('Fact_RT_My Analytics', 'Fact_RT_Chart Builder', 'DJ_FF_ViewChart')) THEN 1 ELSE 0 END) analytics_charts_pvs,

SUM(CASE WHEN (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit as integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9')))
	AND (lower(post_pagename) LIKE '%alert%' AND lower(post_pagename) NOT LIKE '%appsplashmodal%' 
	AND lower(post_pagename) NOT LIKE '%flipboard%') THEN 1 ELSE 0 END) fact_alert_management_pvs,

SUM(CASE WHEN (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
	AND (post_pagename = 'DJ_FF_ViewNewspage') THEN 1 ELSE 0 END) fact_newspage_pvs,


CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                         AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0' 
                        AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') THEN (.34)
                        WHEN reporting_suite = 'djappfactiva' AND post_evar4 <<>> 'viewed_article' AND cast(post_page_event as varchar) = '0'  AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
                       THEN 1 ELSE 0 END)) app_page_views,

CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0'
                         AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) 
			AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND cast(post_page_event as varchar) = '0'
                        AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5','8','9')) AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') 
                       THEN (.34) ELSE 0 END)) app_article_views,

SUM(CASE WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND lower(post_pagename) LIKE '%newslettersent%' THEN 1 ELSE 0 END) newsletter_publishes,

SUM(CASE WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' THEN 1 ELSE 0 END) newsletter_article_views,

SUM(CASE WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' AND post_evar11 = 'MyCompanyToday' THEN 1 ELSE 0 END) mct_newsletter_article_views,

SUM(CASE WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' AND (post_evar11 <<>> 'MyCompanyToday' OR post_evar11 IS NULL) THEN 1 ELSE 0 END) non_mct_newsletter_article_views,
          
SUM(CASE WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND post_prop35 LIKE 'SB:%' THEN 1 ELSE 0 END) expert_searches,

SUM(CASE WHEN reporting_suite = 'factivadjnewsplusprod' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
AND lower(post_pagename) not like '%login%'
                  THEN 1 ELSE 0 END) newsplus_page_views,

SUM(CASE WHEN reporting_suite = 'factivadjnewsplusprod' AND post_page_event_var2 like '%click_banner-breakingnews%'
                  THEN 1 ELSE 0 END) breaking_news_banner_clicks,

SUM(CASE WHEN reporting_suite = 'factivadjnewsplusprod' AND post_page_event_var2 like '%click_banner-newsroom%'
                  THEN 1 ELSE 0 END) newsroom_banner_clicks,

SUM(CASE WHEN reporting_suite = 'factivadjnewsplusprod' AND post_page_event_var2 like '%click_banner-product%'
                  THEN 1 ELSE 0 END) product_banner_clicks,

SUM(CASE WHEN reporting_suite = 'factivadjnewsplusprod' AND post_prop66 like '%Coronavirus Top Stories%'
                  THEN 1 ELSE 0 END) corona_button_clicks,

SUM(CASE WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND post_prop60 <<>> '' AND post_prop60 like 'i%' THEN 1
            ELSE 0 END) Industry_Interactions,

SUM(CASE WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND post_prop60 <<>> '' AND post_prop60 not like 'i%' THEN 1
            ELSE 0 END) Company_Interactions,
       
SUM(CASE WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND post_pagename = 'Fact_RT_ExecutiveProfile' THEN 1
            ELSE 0 END) Executive_Profile_views,
            
SUM(CASE WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND post_pagename like '%Quote%' THEN 1
        ELSE 0 END) Quote_pvs,

SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
	AND (post_pagename like '%Fact_RT_AnalysisProfiles%') THEN 1 ELSE 0 END) Analysis_Profiles_PVs,
	
SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
	AND (post_pagename like '%Fact_RT_RegulatoryFilings%') THEN 1 ELSE 0 END) Regulatory_Filings_PVs,
	

SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
	AND (post_pagename like '%Fact_RT_CorpFamily%') THEN 1 ELSE 0 END) Corporate_Family_PVs,
	
SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
	AND (post_pagename like '%Fact_RT_CoHeadlineResults%') THEN 1 ELSE 0 END) Company_News_PVs,
	
	0 as bulk_upload_button,
	0 as list_upload_success


 FROM fact_external_db.omniture_event_fact
WHERE reporting_suite in ('djfactiva', 'djappfactiva', 'djriskcomplianceprod','factivadjnewsplusprod')
AND cycle_date >> date_add('day', -760, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
GROUP BY 1,2,3,4,5,6,7

union all 

SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
CONCAT(CAST((year(cycle_date)) as varchar), '-', CAST((week(cycle_date)) as varchar)) as year_cal_week,
user_info_user_ref as post_evar3,
null as geo_country,
null as mobile_id,
null as post_prop40,
'Factiva' as Platform,

0 as desktop_page_views, 
0 as desktop_visits, 
0 as app_visits,
0 as RnC_visits,
0 as newsplus_visits,
0 as desktop_article_views, 
0 as SearchResults_Views,
0 as Homepage_Views,
0 as CnE_Views,
0 as Alert_Landing_page_views,
0 as analytics_charts_pvs,
0 as fact_alert_management_pvs,
0 as fact_newspage_pvs,
0 as app_page_views,
0 as app_article_views,
0 as newsletter_publishes,
0 as newsletter_article_views,
0 as mct_newsletter_article_views,
0 as non_mct_newsletter_article_views,
0 as expert_searches,
0 as newsplus_page_views,
0 as breaking_news_banner_clicks,
0 as newsroom_banner_clicks,
0 as product_banner_clicks,
0 as corona_button_clicks,
0 as Industry_Interactions,
0 as Company_Interactions,
0 as Executive_Profile_views,
0 as Quote_pvs,
0 as Analysis_Profiles_PVs,
0 as Regulatory_Filings_PVs,
0 as Corporate_Family_PVs,
0 as Company_News_PVs,
sum(case when event_name = 'user_action' and ti_td_action = 'upload_company_overlay_view' then 1 else 0 end) bulk_upload_button,

sum(case when event_name = 'user_action' and ti_td_action = 'bulk_upload_company' and ti_td_ad_status = 'success' then 1 else 0 end) list_upload_success

from pib_event_data.pib_product_metrics 
where product = 'Factiva'
AND cycle_date >> date_add('day', -760, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
group by 1,2,3,4,5,6,7
having sum(case when event_name = 'user_action' and ti_td_action = 'upload_company_overlay_view' then 1 else 0 end) >> 0
or sum(case when event_name = 'user_action' and ti_td_action = 'bulk_upload_company' and ti_td_ad_status = 'success' then 1 else 0 end) >> 0 



union all 

SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
CONCAT(CAST((year(cycle_date)) as varchar), '-', CAST((week(cycle_date)) as varchar)) as year_cal_week,
user_info_user_ref as post_evar3,
null as geo_country,
null as mobile_id,
null as post_prop40,
'New Factiva' as Platform,
sum(case when (event_name = 'page_view' or event_name = 'user_action') then 1 else 0 end ) as desktop_page_views, 
count(distinct case when (event_name = 'page_view' or event_name = 'user_action') then visit_id end ) as desktop_visits, 
0 as app_visits,
0 as RnC_visits,
0 as newsplus_visits,
0 as desktop_article_views, 
0 as SearchResults_Views,
0 as Homepage_Views,
0 as CnE_Views,
0 as Alert_Landing_page_views,
0 as analytics_charts_pvs,
0 as fact_alert_management_pvs,
0 as fact_newspage_pvs,
0 as app_page_views,
0 as app_article_views,
0 as newsletter_publishes,
0 as newsletter_article_views,
0 as mct_newsletter_article_views,
0 as non_mct_newsletter_article_views,
0 as expert_searches,
0 as newsplus_page_views,
0 as breaking_news_banner_clicks,
0 as newsroom_banner_clicks,
0 as product_banner_clicks,
0 as corona_button_clicks,
0 as Industry_Interactions,
0 as Company_Interactions,
0 as Executive_Profile_views,
0 as Quote_pvs,
0 as Analysis_Profiles_PVs,
0 as Regulatory_Filings_PVs,
0 as Corporate_Family_PVs,
0 as Company_News_PVs,
0 as bulk_upload_button,
0 as list_upload_success 

from pib_event_data.pib_product_metrics 
where product = 'New Factiva'
AND cycle_date >> date_add('day', -760, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
group by 1,2,3,4,5,6,7
having sum(case when (event_name = 'page_view' or event_name = 'user_action') then 1 else 0 end ) >> 0),



product_master AS (
  SELECT access_code, master_product, product_line, bu
  FROM reference_external_db.pib_product_master
  group by access_code, master_product, product_line, bu),

Bill_Acct_Dim AS (
  SELECT cibs_billing_account_id, contract_id, subscription_date, salesforce_status, salesforce_company_two,

(case when cibs_billing_account_id in

(WITH dataset AS ( 
    SELECT * FROM   
        (  select client_name, product, migration_date, split(billing_accounts,',')
     FROM google_sheets_db.saml_master_list_b2b_current
     where product like '%Factiva%'

 ) AS t (client_name, product, migration_date, metrics_array))

select metric as saml_billing_account
from dataset
cross join unnest(metrics_array) as t(metric))
then 'saml_billing_account' end) as saml

  FROM dimension_external_db.pib_billing_account_dimension
  GROUP BY 1,2,3,4,5),

mem_dim AS (
  SELECT pib_member_id, country_code, plan_id, user_id, billing_account_id
  FROM dimension_external_db.pib_membership_dimension
  GROUP BY pib_member_id, country_code, plan_id, user_id, billing_account_id),


Comp AS ( 
  SELECT company_name, company_sfdc_id, company_industry, company_territory, company_country
  FROM dimension_external_db.pib_company_dimension),

Terr AS (
  SELECT territory_sfdc_id, territory_name
FROM dimension_external_db.pib_territory_dimension)



SELECT Omnit.year_month,
       Omnit.year_cal_week,     
	   mem_dim.pib_member_id,
	   mem_dim.user_id,
	   mem_dim.country_code,
	   mem_dim.plan_id,
	   product_master.master_product,
	   product_master.product_line,
	   product_master.bu,
	   Comp.company_name, 
	   mem_dim.billing_account_id, 
	   Comp.company_industry, 
	   Comp.company_country,
           Terr.territory_name,
	   td.region_code,
	   cut.country_name,
           cut.region,
           Omnit.mobile_id,
           Bill_Acct_Dim.salesforce_status,
Bill_Acct_Dim.saml,
       Omnit.Platform,
      
       Omnit.desktop_page_views, 
       Omnit.app_page_views,
       Omnit.desktop_visits, 
       Omnit.app_visits,
       Omnit.RnC_visits,
       Omnit.newsplus_visits,
       Omnit.desktop_Article_Views, 
       Omnit.app_article_views,
       Omnit.SearchResults_Views,
       Omnit.CnE_Views,
       Omnit.Homepage_Views,
       Omnit.Alert_Landing_page_views,
       Omnit.newsletter_publishes,
       Omnit.newsletter_article_views,
       Omnit.mct_newsletter_article_views,
       Omnit.non_mct_newsletter_article_views,
       Omnit.expert_searches,
       Omnit.newsplus_page_views,
       Omnit.analytics_charts_pvs,
       Omnit.fact_alert_management_pvs,
       Omnit.fact_newspage_pvs,
       Omnit.breaking_news_banner_clicks,
       Omnit.newsroom_banner_clicks,
       Omnit.product_banner_clicks,
       Omnit.corona_button_clicks,
       Omnit.post_prop40,
       Omnit.Industry_Interactions,
       Omnit.Company_Interactions,
       Omnit.Executive_Profile_views,
       Omnit.Quote_pvs,
       Omnit.Analysis_Profiles_PVs,
       Omnit.Regulatory_Filings_PVs,
       Omnit.Corporate_Family_PVs,
       Omnit.Company_News_PVs,
       Omnit.bulk_upload_button,
       Omnit.list_upload_success



FROM Omnit
LEFT JOIN mem_dim ON mem_dim.pib_member_id = Omnit.post_evar3
LEFT JOIN Bill_Acct_Dim ON mem_dim.billing_account_id = Bill_Acct_Dim.cibs_billing_account_id
LEFT JOIN Comp ON Bill_Acct_Dim.salesforce_company_two = Comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_territory_dimension td ON Comp.company_territory = td.territory_sfdc_id
LEFT JOIN product_master ON mem_dim.plan_id = product_master.access_code
LEFT JOIN Terr ON Comp.company_territory = Terr.territory_sfdc_id
left join reference_external_db.country_reference  cut on Omnit.geo_country = cut.geo_country
