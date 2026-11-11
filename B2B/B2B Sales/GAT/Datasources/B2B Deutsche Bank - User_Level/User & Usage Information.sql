-- Published data source : "B2B Deutsche Bank - User_Level"  [B2B / B2B Sales / GAT / Datasources]
-- Relation    : Custom SQL "User & Usage Information"
-- Connection  : Athena (AwsDataCatalog / reference_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH MonthlyOmnit as
(SELECT post_evar3,
 		SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month,
 		COUNT(DISTINCT CASE WHEN lower(post_pagename) NOT LIKE '%login%' THEN cycle_date END) active_days,
        SUM(CASE WHEN reporting_suite = 'djfactiva' AND lower(post_pagename) NOT LIKE '%login%' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9'))
      			 THEN 1 ELSE 0 END) page_views,
      	CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0' 
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' 
                       THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0'
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') 
                       THEN (.34)
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 <<>> 'viewed_article' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) 
                       THEN 1 ELSE 0 END)) factiva_app_page_views,
        COUNT(DISTINCT CASE WHEN reporting_suite = 'djfactiva' AND lower(post_pagename) NOT LIKE '%login%' AND CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '7',  '8',  '9')
         THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) visits,
        COUNT(CASE WHEN reporting_suite = 'djfactiva' AND (post_evar4 = 'Fact_ART_ArticleView' OR post_prop3='ARTICLE' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
                   		AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8','9'))
                   THEN post_prop20 ELSE NULL END) Article_Views,
        SUM(CASE WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
	                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' THEN 1 ELSE 0 END) Article_Views_on_Newsletters,
        SUM(CASE
            WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND post_prop60 <<>> '' AND post_prop60 like 'i%' THEN 1
            ELSE 0 END) Industry_Interactions,
        SUM(CASE
            WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND post_prop60 <<>> '' AND post_prop60 not like 'i%' THEN 1
            ELSE 0 END) Company_Interactions,
        SUM(CASE
            WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND post_pagename = 'Fact_RT_ExecutiveProfile' THEN 1
            ELSE 0 END) Executive_Profile_views,
        SUM(CASE
            WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND upper(post_prop3) = 'ANALYST' THEN 1
            ELSE 0 END) TR_Analyst_Report_page_views,
        SUM(CASE WHEN reporting_suite = 'djfactiva' AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9')))
                    AND (post_pagename = 'DJ_FF_HeadlineResults' OR post_pagename = 'DJ_FF_SearchBuilder' OR post_pagename = 'DJF_SS_ContemporaryHeadlinesResults' OR post_pagename = 'DJ_FF_SavedSearch' OR post_pagename = 'DJ_FF_SimpleSearch')
                 THEN 1 ELSE 0 END) SearchResults_Views,
        SUM(CASE WHEN reporting_suite = 'djfactiva' AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9')))
                    AND (post_pagename LIKE 'DJF_SS\_%' ESCAPE '\'
                    AND post_pagename <<>> '')
                  THEN 1 ELSE 0 END) Homepage_Views,
        SUM(CASE WHEN reporting_suite = 'djfactiva' AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9')))
                    AND (post_pagename <<>> ''
                    AND post_pagename LIKE '%\_RT\_%' ESCAPE '\'
                    AND post_pagename NOT LIKE '%\_SrcInfo\_%' ESCAPE '\'
                    AND post_pagename NOT LIKE '%\_Newsletter%' ESCAPE '\'
                    AND post_pagename NOT LIKE '%\_RegInfo\_%' ESCAPE '\'
                    AND post_pagename NOT LIKE '%\_Chart%' ESCAPE '\'
                    AND post_pagename NOT LIKE '%\_FES\_%' ESCAPE '\'
                    AND post_pagename NOT LIKE '%\_RSS%' ESCAPE '\'
                    AND post_pagename NOT LIKE 'Fact_Article\_%' ESCAPE '\'
                    AND post_pagename NOT LIKE 'Fact_ART\_%' ESCAPE '\'
                    AND post_pagename NOT LIKE 'Fact_RT_My Analytics%'
                    AND lower(post_pagename) NOT LIKE '%alert%')
                  THEN 1 ELSE 0 END) CnE_Views,
        SUM(CASE WHEN reporting_suite = 'djfactiva' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) AND ((post_prop6 LIKE '%/email/%' or post_prop6 LIKE '%/Email/%')
                    AND (post_campaign in ('Alert', 'alert_sidelink'))) AND lower(post_pagename) LIKE '%article%'
                  THEN 1 ELSE 0 END) Alert_Landing_page_views
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite in ('djfactiva', 'djappfactiva')
  and cycle_date >>= date('2022-10-01')
  and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
GROUP BY 1, 2
ORDER BY 1),

alerts_data AS (
SELECT SUBSTRING(CAST(report_date AS varchar), 1, 7) as alert_month,
         user_id,
         account_id,
         SUM(CAST(email_count AS INTEGER)) as email_alerts_sent,
         SUM(CAST(article_count AS INTEGER)) as articles_sent,
         SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(email_count AS INTEGER) ELSE 0 END) full_text_email_alerts_sent,
         SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(article_count AS INTEGER) ELSE 0 END) full_text_articles_sent
FROM dimension_external_db.pib_alerts 
where account_id IN('9DEU001700','9DEU005300','9DEU004800',
'9DEU001500','9DEU008900','9DEU004000','9DEU006000','9DEU011300',
'9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
GROUP BY 1, 2, 3),

/*
RiskOmnit as (SELECT post_evar3,
                    max(cycle_date) last_login_RC
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djriskcomplianceprod'
  and cycle_date >>= date('2017-06-01')
  and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
GROUP BY 1
ORDER BY 1),

FactOmnit as (SELECT post_evar3,
                    max(cycle_date) last_login_factiva
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djfactiva'
  and lower(post_pagename) NOT LIKE '%login%'
  and cycle_date >>= date('2017-06-01')
  and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
GROUP BY 1
ORDER BY 1),

FactAppOmnit as (SELECT post_evar3,
                    max(cycle_date) last_login_factivaApp
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djappfactiva'
  and cycle_date >>= date('2017-06-01')
  and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
GROUP BY 1
ORDER BY 1),
*/

mem_dim AS ( select
pib_member_id,
user_id,
first_name,
last_name,
plan_id,
email,
billing_account_id,
user_status,
web_registration_date,
country_code
from dimension_external_db.pib_membership_dimension
where billing_account_id IN('9DEU001700','9DEU005300','9DEU004800',
'9DEU001500','9DEU008900','9DEU004000','9DEU006000','9DEU011300',
'9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')    
group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10),

bad as (
select cibs_billing_account_id, salesforce_company_two
from dimension_external_db.pib_billing_account_dimension
group by 1,2),

comp as (
select company_sfdc_id, company_name, company_territory
from dimension_external_db.pib_company_dimension
group by 1,2,3),

sterr as
(select territory_sfdc_id, territory_name
from dimension_external_db.pib_territory_dimension
group by 1,2
),

core_user_list AS (
SELECT DISTINCT pib_member_id
FROM mem_dim
INNER JOIN alerts_data ON mem_dim.user_id = alerts_data.user_id AND mem_dim.billing_account_id = alerts_data.account_id
UNION ALL (SELECT DISTINCT pib_member_id FROM MonthlyOmnit INNER JOIN mem_dim ON MonthlyOmnit.post_evar3 = mem_dim.pib_member_id)),

months AS (SELECT DISTINCT year_month FROM MonthlyOmnit),

shell AS (
SELECT DISTINCT year_month, pib_member_id FROM core_user_list
CROSS JOIN months)

SELECT shell.year_month,
	   mem_dim.*,
            comp.company_sfdc_id,
	    comp.company_name,
            sterr.territory_sfdc_id,
            sterr.territory_name,
            cr.country_name,
	   COALESCE(MonthlyOmnit.active_days, 0) active_days,
	   COALESCE(MonthlyOmnit.page_views, 0) page_views,
       COALESCE(MonthlyOmnit.factiva_app_page_views, 0) factiva_app_page_views,
       COALESCE(MonthlyOmnit.visits, 0) visits,
       COALESCE(MonthlyOmnit.Article_Views, 0) article_views,
       COALESCE(MonthlyOmnit.Article_Views_on_Newsletters, 0) Article_Views_on_Newsletters,
       COALESCE(MonthlyOmnit.SearchResults_Views, 0) SearchResults_Views,
       COALESCE(MonthlyOmnit.Homepage_Views, 0) Homepage_Views,
       COALESCE(MonthlyOmnit.CnE_Views, 0) cne_Views,
       COALESCE(MonthlyOmnit.Industry_Interactions, 0) Industry_Interactions,
       COALESCE(MonthlyOmnit.Company_Interactions, 0) Company_Interactions,
       COALESCE(MonthlyOmnit.Executive_Profile_views, 0) Executive_Profile_views,
       COALESCE(MonthlyOmnit.TR_Analyst_Report_page_views, 0) TR_Analyst_Report_page_views,
       COALESCE(MonthlyOmnit.Alert_Landing_page_views, 0) Alert_Landing_page_views,
       COALESCE(alerts_data.email_alerts_sent, 0) email_alerts_sent,
       COALESCE(alerts_data.articles_sent, 0) articles_sent,
       COALESCE(alerts_data.full_text_email_alerts_sent, 0) full_text_email_alerts_sent,
       COALESCE(alerts_data.full_text_articles_sent, 0) full_text_articles_sent
       --FactOmnit.last_login_factiva,
       --FactAppOmnit.last_login_factivaApp,
       --RiskOmnit.last_login_RC
FROM shell
LEFT JOIN mem_dim ON shell.pib_member_id = mem_dim.pib_member_Id
LEFT JOIN MonthlyOmnit ON shell.pib_member_id = MonthlyOmnit.post_evar3 AND shell.year_month = MonthlyOmnit.year_month
LEFT JOIN alerts_data ON shell.year_month = alerts_data.alert_month AND mem_dim.user_id = alerts_data.user_id AND mem_dim.billing_account_id = alerts_data.account_id
--LEFT JOIN FactOmnit ON mem_dim.pib_member_id = FactOmnit.post_evar3
--LEFT JOIN FactAppOmnit ON mem_dim.pib_member_id = FactAppOmnit.post_evar3
--LEFT JOIN RiskOmnit ON mem_dim.pib_member_id = RiskOmnit.post_evar3
LEFT JOIN reference_external_db.country_reference cr on mem_dim.country_code = cr.edw_code
LEFT JOIN bad ON mem_dim.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN comp ON bad.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN sterr ON comp.company_territory = sterr.territory_sfdc_id
WHERE active_days >> 0 OR email_alerts_sent >> 0
and mem_dim.billing_account_id IN('9DEU001700','9DEU005300','9DEU004800',
'9DEU001500','9DEU008900','9DEU004000','9DEU006000','9DEU011300',
'9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
