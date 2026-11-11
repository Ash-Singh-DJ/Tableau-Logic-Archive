-- Dashboard   : "B2B Deloitte Quarterly Report"  [B2B / B2B Sales / GAT]
-- Data source : "Page Type" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with Omnit as

(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 7) year_month, 
post_evar3, (case when post_pagename like 'Fact_Article%' then 'Fact_Article' else post_pagename end) as pagename,   
(CASE WHEN (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
     AND (post_pagename like 'DJF_SS_%'
         AND post_pagename <<>> '' 
                    AND post_pagename <<>> 'DJF_SS_ArticleOverlay_0021' 
                    AND post_pagename <<>> 'DJF_SS_Contemporary_ArticleView' 
                    AND post_pagename <<>> 'DJF_SS_ContemporaryHeadlinesResults' 
                    AND post_pagename <<>> 'DJF_SS_ContemporaryHeadlinesAlert' 
                    AND post_pagename <<>> 'DJF_SS_AdminWorkspace_0001') then 'home_pages'
                    
    WHEN (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
         AND (post_pagename = 'DJ_FF_HeadlineResults' OR post_pagename = 'DJ_FF_SearchBuilder' OR post_pagename = 'DJ_FF_SavedSearch') THEN 'advanced_search_pages'
         
           WHEN (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
         AND (post_pagename = 'DJF_SS_ContemporaryHeadlinesResults' or post_pagename = 'DJ_FF_SimpleSearch') THEN 'simple_search_pages'
         
        WHEN (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))) 
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
                    or post_pagename like '%Quote%' then 'cne_quote_views'
                    
 WHEN (post_pagename = 'Fact_ART_ArticleView' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' 
	OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
        AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8','9')) 
        and post_prop40 = '' and lower(post_prop6) not like '%email%' then 'on_platform_article_views'
        
WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' THEN  'newsletter_article_views'
                    
WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND 
	cast(hit_source as varchar) NOT IN ('5',  '8',  '9')) AND ((post_prop6 LIKE '%email%' or post_prop6 LIKE '%Email%')
	AND (post_campaign in ('Alert', 'alert_sidelink'))) AND lower(post_pagename) LIKE '%article%' 
	THEN 'alert_article_views'
        
WHEN cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
	AND (post_pagename IN ('Fact_RT_My Analytics', 'Fact_RT_Chart Builder', 'DJ_FF_ViewChart')) then 'analytics_charts_views'
    
WHEN cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9')) 
     and post_pagename LIKE '%Newsletter%' OR post_pagename LIKE '%DJ_FF_ImageUpload%' OR post_pagename LIKE '%DJ_FF_HTMLTemplate%' then 'newsletter_builder'
     
     else 'Other'
         
         end) page_type, 
              
SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views
        

        
 FROM fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djfactiva'
--and post_evar3 = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
AND cycle_date >> date_add('day', -620, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
GROUP BY 1,2,3,4
having SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0

),


mem_fact AS (
  SELECT billing_account_id, contract_id, pib_member_id
  FROM fact_external_db.pib_membership_fact
  GROUP BY billing_account_id, contract_id, pib_member_id),

product_master AS (
  SELECT access_code, master_product, product_line, bu
  FROM reference_external_db.pib_product_master
  group by access_code, master_product, product_line, bu),

Bill_Acct_Dim AS (
  SELECT cibs_billing_account_id, contract_id, subscription_date, salesforce_status, salesforce_company_two 
  FROM dimension_external_db.pib_billing_account_dimension
  GROUP BY cibs_billing_account_id, contract_id, subscription_date, salesforce_status, salesforce_company_two),

mem_dim AS (
  SELECT pib_member_id, country_code, plan_id, user_id, billing_account_id
  FROM dimension_external_db.pib_membership_dimension
  GROUP BY pib_member_id, country_code, plan_id, user_id, billing_account_id),

Contract_Dim AS (
  SELECT contract_id
  FROM dimension_external_db.pib_contract_dimension
  GROUP BY contract_id),

Acct_Fact AS ( 
  SELECT contract_id, company_sfdc_id
  FROM fact_external_db.pib_account_hierarchy_fact
  GROUP BY contract_id, company_sfdc_id),

Comp AS ( 
  SELECT company_name, company_sfdc_id, company_industry, company_territory, company_country
  FROM dimension_external_db.pib_company_dimension),

Terr AS (
  SELECT territory_sfdc_id, territory_name
FROM dimension_external_db.pib_territory_dimension)



SELECT Omnit.year_month,    
	   mem_dim.pib_member_id,
	   mem_dim.user_id,
	   mem_dim.plan_id,
	   product_master.master_product,
	   product_master.product_line,
	   product_master.bu,
	   Comp.company_name, 
	   mem_dim.billing_account_id, 
	   Comp.company_industry, 
	   Comp.company_country,
           Terr.territory_name,
           Omnit.pagename,
      Omnit.page_type,
       Omnit.desktop_page_views 

FROM Omnit
LEFT JOIN mem_dim ON mem_dim.pib_member_id = Omnit.post_evar3
LEFT JOIN Bill_Acct_Dim ON mem_dim.billing_account_id = Bill_Acct_Dim.cibs_billing_account_id
LEFT JOIN Comp ON Bill_Acct_Dim.salesforce_company_two = Comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_territory_dimension td ON Comp.company_territory = td.territory_sfdc_id
LEFT JOIN product_master ON mem_dim.plan_id = product_master.access_code
LEFT JOIN Terr ON Comp.company_territory = Terr.territory_sfdc_id
