-- Dashboard   : "B2B Factiva Retention Model Dashboard 3.0"  [B2B / B2B Sales / Product Usage]
-- Data source : "Churn_Company_Filtered_Data_v2" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / zoolander_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH Omnit AS ( 
    SELECT SUBSTRING(CAST(date_time AS varchar), 1, 7) year_month,
         post_evar3,
         COUNT(DISTINCT CASE WHEN (reporting_suite = 'djfactiva' AND lower(post_pagename) NOT LIKE '%login%')  or reporting_suite = 'djappfactiva' THEN cycle_date END) factiva_active_days,
         COUNT(DISTINCT CASE WHEN reporting_suite = 'djriskcomplianceprod' THEN cycle_date END) rnc_active_days,
         COUNT(DISTINCT cycle_date) active_days,
         SUM(CASE WHEN reporting_suite = 'djfactiva' AND lower(post_pagename) NOT LIKE '%login%' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) 
                  THEN 1 ELSE 0 END) desktop_page_views,
         COUNT(DISTINCT CASE WHEN reporting_suite = 'djfactiva' AND lower(post_pagename) NOT LIKE '%login%' AND CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '7',  '8',  '9') 
                             THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) desktop_visits,
         COUNT(DISTINCT CASE WHEN reporting_suite = 'djappfactiva' AND CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '7',  '8',  '9')
                             THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) app_visits,
         COUNT(DISTINCT CASE WHEN reporting_suite = 'djriskcomplianceprod' AND CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '7',  '8',  '9')
                             THEN (CAST(post_visid_high as varchar) || '-' || CAST(post_visid_low as varchar) || '-' || CAST(visit_num as varchar)) END) RnC_visits,
         COUNT(CASE WHEN reporting_suite = 'djfactiva' AND (post_evar4 = 'Fact_ART_ArticleView' OR post_prop3='ARTICLE' OR post_pagename = 'DJF_SS_ArticleOverlay_0021' OR post_pagename = 'DJF_SS_Contemporary_ArticleView' OR lower(post_pagename) LIKE '%article%')
                      AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8','9')) 
                    THEN post_prop20 ELSE NULL END) desktop_article_views,
         SUM(CASE WHEN reporting_suite = 'djfactiva' AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                    AND (post_pagename = 'DJ_FF_HeadlineResults' OR post_pagename = 'DJ_FF_SearchBuilder' OR post_pagename = 'DJF_SS_ContemporaryHeadlinesResults' OR post_pagename = 'DJ_FF_SavedSearch' OR post_pagename = 'DJ_FF_SimpleSearch')
                  THEN 1 ELSE 0 END) SearchResults_Views,
         SUM(CASE WHEN reporting_suite = 'djfactiva' AND (CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))) 
                    AND (post_pagename LIKE 'DJF_SS\_%' ESCAPE '\'
                    AND post_pagename <<>> '' 
                    AND post_pagename <<>> 'DJF_SS_ArticleOverlay_0021' 
                    AND post_pagename <<>> 'DJF_SS_Contemporary_ArticleView' 
                    AND post_pagename <<>> 'DJF_SS_ContemporaryHeadlinesResults' 
                    AND post_pagename <<>> 'DJF_SS_ContemporaryHeadlinesAlert' 
                    AND post_pagename <<>> 'DJF_SS_AdminWorkspace_0001')  
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
                  THEN 1 ELSE 0 END) Alert_Landing_page_views,
         CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0' 
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' 
                       THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0'
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') 
                       THEN (.34)
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 <<>> 'viewed_article' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) 
                       THEN 1 ELSE 0 END)) factiva_app_page_views,
         CEIL(SUM(CASE WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0'
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND lower(post_prop72) NOT LIKE '%2.3.0%' AND lower(post_prop72) NOT LIKE '%2.3.1%' 
                       THEN 1
                       WHEN reporting_suite = 'djappfactiva' AND post_evar4 = 'viewed_article' AND CAST(post_page_event AS varchar) = '0'
                         AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5','8','9')) AND (lower(post_prop72) LIKE '%2.3.0%' OR lower(post_prop72) LIKE '%2.3.1%') 
                       THEN (.34) ELSE 0 END)) app_article_views,
         SUM(CASE WHEN reporting_suite = 'djfactiva' and CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                    AND lower(post_pagename) LIKE '%newslettersent%' THEN 1 ELSE 0 END) newsletter_publishes,
         SUM(CASE WHEN reporting_suite = 'djfactiva' and CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' THEN 1 ELSE 0 END) newsletter_article_views,
         SUM(CASE WHEN reporting_suite = 'djfactiva' and CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' AND post_evar11 = 'MyCompanyToday' THEN 1 ELSE 0 END) mct_newsletter_article_views,  
         SUM(CASE WHEN reporting_suite = 'djfactiva' and CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' AND (post_evar11 <<>> 'MyCompanyToday' OR post_evar11 IS NULL) THEN 1 ELSE 0 END) non_mct_newsletter_article_views,          
         SUM(CASE WHEN reporting_suite = 'djfactiva' and CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                    AND post_prop35 LIKE 'SB:%' THEN 1 ELSE 0 END) expert_searches
    FROM fact_external_db.omniture_event_fact
    WHERE reporting_suite in ('djfactiva', 'djappfactiva', 'djriskcomplianceprod')
        AND cycle_date >>= DATE('2018-01-01')
    GROUP BY 1, 2),
		
djm AS (
	SELECT 
		substring(CAST(date_time AS varchar), 1, 7) year_month, 
		user_info_user_ref, 
		count(DISTINCT cycle_date) nf_active_days,
		sum(CASE WHEN event_name = 'page_view' THEN 1 ELSE 0 END) nf_page_views, 
		sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Home' THEN 1 ELSE 0 END) nf_homepage_views, 
		sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) nf_article_views 
	FROM pib_event_data.pib_product_metrics 
	WHERE product in ('New Factiva')
		AND cycle_date >>= DATE('2021-11-01')
		AND event_name IS NOT NULL
	GROUP BY 1, 2), 

mem_fact AS (
  SELECT billing_account_id, contract_id, pib_member_id
  FROM fact_external_db.pib_membership_fact
  GROUP BY 1, 2, 3),

product_master AS (
  SELECT access_code, master_product
  FROM reference_external_db.pib_product_dimension
  GROUP BY 1, 2),

Bill_Acct_Dim AS (
  SELECT cibs_billing_account_id, contract_id, subscription_date, salesforce_company_two
  FROM dimension_external_db.pib_billing_account_dimension
  GROUP BY 1, 2, 3, 4),

mem_dim AS (
  SELECT pib_member_id, country_code, plan_id
  FROM dimension_external_db.pib_membership_dimension
  GROUP BY 1, 2, 3),

Contract_Dim AS (
  SELECT contract_id
  FROM dimension_external_db.pib_contract_dimension
  GROUP BY 1),

Acct_Fact AS ( 
  SELECT contract_id, company_sfdc_id
  FROM fact_external_db.pib_account_hierarchy_fact
  GROUP BY 1, 2),
  
Acct_Fact_Opps AS (
  SELECT pib_opportunity_sfdc_id, company_sfdc_id 
  FROM fact_external_db.pib_account_hierarchy_fact 
  GROUP BY 1, 2),

Comp AS ( 
  SELECT company_name, company_sfdc_id, company_industry, company_territory, factiva_f_code, company_country
  FROM dimension_external_db.pib_company_dimension),

subscription_dates AS (
  SELECT Comp.company_sfdc_id, Comp.company_name, Comp.factiva_f_code, Comp.company_industry, td.territory_name, td.region_code, 
  		 MIN(Bill_Acct_Dim.subscription_date) as oldest_sub_date
  FROM Bill_Acct_Dim
  LEFT JOIN Acct_Fact ON Bill_Acct_Dim.contract_id = Acct_Fact.contract_id
  LEFT JOIN Comp ON Acct_Fact.company_sfdc_id = Comp.company_sfdc_id
  LEFT JOIN dimension_external_db.pib_territory_dimension td ON Comp.company_territory = td.territory_sfdc_id
  GROUP BY 1, 2, 3, 4, 5, 6),

month_end AS (
  SELECT SUBSTRING(CAST(full_date AS varchar),1,7) AS year_month, MAX(DATE_TRUNC('day',full_date)) AS month_end_date
  FROM reference_external_db.date_dimension
  WHERE full_date >>= DATE('2018-01-01')
    AND full_date <<= DATE_ADD('day',-1,(DATE_TRUNC('month',DATE_ADD('month', 1, CURRENT_DATE))))
  GROUP BY 1),
   
max_record AS (
  SELECT eid,
         year_month,
         month_end_date,
         MAX(CASE WHEN cycle_date <<= month_end_date THEN cycle_date END) AS max_record_date
  FROM dimension_external_db.pib_membership_history
  CROSS JOIN month_end
  GROUP BY 1, 2, 3),
  
max_record_contacts AS (
  SELECT contact_sfdc_id,
         year_month,
         month_end_date,
         MAX(CASE WHEN cycle_date <<= month_end_date THEN cycle_date END) AS max_record_date
  FROM dimension_external_db.pib_contact_dimension_history
  CROSS JOIN month_end
  GROUP BY 1, 2, 3),
  
contact_history AS (
  SELECT month_end_date, 
         year_month,
         company_sfdc_id,
         company_name,
         COUNT(DISTINCT CASE WHEN cd_history.cycle_date <<= max_record_contacts.max_record_date THEN cd_history.contact_sfdc_id ELSE NULL END) contacts
  FROM dimension_external_db.pib_contact_dimension_history cd_history
  LEFT JOIN max_record_contacts ON (cd_history.contact_sfdc_id = max_record_contacts.contact_sfdc_id AND cd_history.cycle_date = max_record_contacts.max_record_date)
  LEFT JOIN dimension_external_db.pib_company_dimension comp ON cd_history.account_id = comp.company_sfdc_id
  GROUP BY 1, 2, 3, 4),

product_filter AS (
  SELECT master_product, tm1_product
  FROM reference_external_db.pib_product_dimension 
  WHERE tm1_product IS NOT NULL 
  AND (lower(product_line) LIKE '%factiva%' 
    OR lower(product_line) LIKE '%djx%' 
    OR lower(product_line) LIKE '%riskcenter%')),
                      
access_code_filter AS (
  SELECT access_code, product_line, master_product 
  FROM reference_external_db.pib_product_dimension 
  WHERE master_product IN (SELECT master_product FROM product_filter) 
    AND access_code <<>> ''),

reg_users AS (
	SELECT month_end_date reg_date, year_month, billing_account_id,
		   COUNT(DISTINCT CASE WHEN mem_history.cycle_date <<= max_record.max_record_date THEN mem_history.EID ELSE NULL END) registered_users, 
	   COUNT(DISTINCT CASE WHEN (mem_history.cycle_date <<= max_record.max_record_date AND lower(master_product) LIKE '%reader%') THEN mem_history.EID ELSE NULL END) reader_registered_users, 
		   COUNT(DISTINCT CASE WHEN mem_history.cycle_date <<= max_record.max_record_date AND (lower(product_line) LIKE '%factiva%' OR lower(product_line) LIKE '%djx%') THEN mem_history.EID ELSE NULL END) factiva_djx_registered_users,
		   COUNT(DISTINCT CASE WHEN mem_history.cycle_date <<= max_record.max_record_date AND lower(product_line) LIKE '%riskcenter%' THEN mem_history.EID ELSE NULL END) rnc_registered_users
	FROM dimension_external_db.pib_membership_history mem_history
	LEFT JOIN max_record ON (mem_history.eid = max_record.eid AND mem_history.cycle_date = max_record.max_record_date)
	LEFT JOIN access_code_filter ON mem_history.plan_id = access_code_filter.access_code
	WHERE mem_history.user_status = 'A'
		AND plan_id in (SELECT access_code FROM access_code_filter)
	  	AND year_month IS NOT NULL
	GROUP BY 1, 2, 3),

ba_comp AS (
	SELECT Bill_Acct_Dim.cibs_billing_account_id, comp.company_sfdc_id, Comp.company_name
	FROM Bill_Acct_Dim
	LEFT JOIN Contract_Dim ON Bill_Acct_Dim.contract_id = Contract_Dim.contract_id
	LEFT JOIN Acct_Fact ON Contract_Dim.contract_id = Acct_Fact.contract_id
	LEFT JOIN Comp ON Acct_Fact.company_sfdc_id = Comp.company_sfdc_id
	GROUP BY 1, 2, 3), 
				
reg_users_by_company AS (
  SELECT inny.reg_date, inny.year_month, ba_comp.company_sfdc_id, ba_comp.company_name, 
  SUM(registered_users) registered_users, 
  SUM(reader_registered_users) reader_registered_users, 
  SUM(factiva_djx_registered_users) factiva_djx_registered_users, 
  SUM(rnc_registered_users) rnc_registered_users
  FROM reg_users inny
  LEFT JOIN ba_comp ON ba_comp.cibs_billing_account_id = inny.billing_account_id
  GROUP BY 1, 2, 3, 4),

factiva_metrics AS (
  SELECT omnit.year_month year_month,
         Comp.company_sfdc_id company_sfdc_id,
         Comp.company_name company_name, Comp.company_country company_country,
         COUNT(DISTINCT mem_fact.billing_account_id) as billing_account_ids,
         COUNT(DISTINCT mem_dim.pib_member_id) AS users,
         COUNT(DISTINCT CASE WHEN factiva_active_days >> 0 THEN mem_dim.pib_member_id END) AS factiva_users,
         COUNT(DISTINCT CASE WHEN rnc_active_days >> 0 THEN mem_dim.pib_member_id END) AS rnc_users,
         COUNT(DISTINCT CASE WHEN factiva_active_days = 1  THEN mem_dim.pib_member_id END) single_day_users,
         COUNT(DISTINCT CASE WHEN factiva_active_days >>= 2 AND factiva_active_days << 7 THEN mem_dim.pib_member_id END) occasional_users,
         COUNT(DISTINCT CASE WHEN factiva_active_days >>= 7 AND factiva_active_days << 12 THEN mem_dim.pib_member_id END) light_users,
         COUNT(DISTINCT CASE WHEN factiva_active_days >>= 12 AND factiva_active_days << 17 THEN mem_dim.pib_member_id END) mid_users,
         COUNT(DISTINCT CASE WHEN factiva_active_days >>= 17 THEN mem_dim.pib_member_id END) super_users,
         SUM(desktop_page_views) desktop_page_views, 
         SUM(factiva_app_page_views) factiva_app_page_views, 
         SUM(desktop_visits) desktop_visits, 
         SUM(app_visits) app_visits,
         SUM(RnC_visits) Rnc_visits,
         SUM(desktop_Article_Views) desktop_Article_Views, 
         SUM(app_article_views) app_article_views,
         SUM(SearchResults_Views) SearchResults_Views,
         SUM(CnE_Views) CnE_Views,
         SUM(Homepage_Views) Homepage_Views,
         SUM(Alert_Landing_page_views) Alert_Landing_page_views,
         SUM(newsletter_publishes) newsletter_publishes,
         SUM(newsletter_article_views) newsletter_article_views,
         SUM(mct_newsletter_article_views) mct_newsletter_article_views,
         SUM(non_mct_newsletter_article_views) non_mct_newsletter_article_views,
         SUM(expert_searches) expert_searches
  FROM omnit
  LEFT JOIN mem_fact ON omnit.post_evar3 = mem_fact.pib_member_id
  LEFT JOIN mem_dim ON mem_fact.pib_member_id = mem_dim.pib_member_id
  LEFT JOIN product_master ON mem_dim.plan_id = product_master.access_code
  LEFT JOIN Contract_Dim ON mem_fact.contract_id = Contract_Dim.contract_id
  LEFT JOIN Acct_Fact ON Contract_Dim.contract_id = Acct_Fact.contract_id
  LEFT JOIN Comp ON Acct_Fact.company_sfdc_id = Comp.company_sfdc_id
  LEFT JOIN Bill_Acct_Dim ON mem_fact.billing_account_id = Bill_Acct_Dim.cibs_billing_account_id
  GROUP BY 1, 2, 3, 4),
		
djm_rollup AS (
	SELECT 
		djm.year_month year_month,
		Comp.company_sfdc_id company_sfdc_id, Comp.company_name nf_company_name, Comp.company_country nf_company_country, 
        COUNT(DISTINCT mem_fact.billing_account_id) as nf_billing_account_ids,
        COUNT(DISTINCT mem_dim.pib_member_id) AS nf_users,
        COUNT(DISTINCT CASE WHEN nf_active_days >> 0 THEN mem_dim.pib_member_id END) AS new_factiva_users,
        COUNT(DISTINCT CASE WHEN nf_active_days = 1  THEN mem_dim.pib_member_id END) single_day_nf_users,
        COUNT(DISTINCT CASE WHEN nf_active_days >>= 2 AND nf_active_days << 7 THEN mem_dim.pib_member_id END) occasional_nf_users,
        COUNT(DISTINCT CASE WHEN nf_active_days >>= 7 AND nf_active_days << 12 THEN mem_dim.pib_member_id END) light_nf_users,
        COUNT(DISTINCT CASE WHEN nf_active_days >>= 12 AND nf_active_days << 17 THEN mem_dim.pib_member_id END) mid_nf_users,
        COUNT(DISTINCT CASE WHEN nf_active_days >>= 17 THEN mem_dim.pib_member_id END) super_nf_users,
		SUM(nf_page_views) nf_page_views, 
		SUM(nf_homepage_views) nf_homepage_views, 
		SUM(nf_article_views) nf_article_views
	FROM djm 
    LEFT JOIN mem_fact ON djm.user_info_user_ref = mem_fact.pib_member_id
	LEFT JOIN mem_dim ON mem_fact.pib_member_id = mem_dim.pib_member_id
	LEFT JOIN product_master ON mem_dim.plan_id = product_master.access_code
	LEFT JOIN Contract_Dim ON mem_fact.contract_id = Contract_Dim.contract_id
	LEFT JOIN Acct_Fact ON Contract_Dim.contract_id = Acct_Fact.contract_id
	LEFT JOIN Comp ON Acct_Fact.company_sfdc_id = Comp.company_sfdc_id
	LEFT JOIN Bill_Acct_Dim ON mem_fact.billing_account_id = Bill_Acct_Dim.cibs_billing_account_id
	GROUP BY 1, 2, 3, 4),
  
alerts_by_company AS (
  SELECT Comp.company_sfdc_id, 
         SUBSTRING(CAST(report_date AS varchar), 1, 7) as alert_month,
         SUM(CAST(nullif(email_count, '') AS INTEGER)) as email_alerts_sent,
         SUM(CAST(nullif(article_count, '') AS INTEGER)) as articles_sent,
         SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(nullif(email_count, '') AS INTEGER) ELSE 0 END) full_text_email_alerts_sent, 
         SUM(CASE WHEN lower(display_format) LIKE '%fulltext%' THEN CAST(nullif(article_count, '') AS INTEGER) ELSE 0 END) full_text_articles_sent
  FROM dimension_external_db.pib_alerts alert
  LEFT JOIN Bill_Acct_Dim ON Bill_Acct_Dim.cibs_billing_account_id = alert.account_id
  LEFT JOIN Comp ON Bill_Acct_Dim.salesforce_company_two = Comp.company_sfdc_id
  GROUP BY 1, 2),
  
tm AS (
  SELECT billing_account_number,
         TRIM(product) AS product,
         pm.product_line,
         SUBSTRING(CAST(billing_date AS varchar), 1, 7) billing_date,
         SUM(exit_rate*12) annualized_rev
  FROM fact_external_db.tm1_fact tm1
  LEFT JOIN reference_external_db.pib_product_dimension pm ON tm1.product = pm.tm1_product
  WHERE TRIM(product) IN (SELECT tm1_product FROM product_filter)
  GROUP BY 1, 2, 3, 4),
  
tm_other AS (
  SELECT billing_account_number,
         TRIM(product) AS product,
         pm.product_line,
         SUBSTRING(CAST(billing_date AS varchar), 1, 7) billing_date,
         SUM(exit_rate*12) annualized_rev
  FROM fact_external_db.tm1_fact tm1
  LEFT JOIN reference_external_db.pib_product_dimension pm ON tm1.product = pm.tm1_product
  WHERE TRIM(product) NOT IN (SELECT tm1_product FROM product_filter)
  GROUP BY 1, 2, 3, 4),
  
tm1_company_name AS (
  SELECT company_sfdc_id, company_name, billing_date, 
         SUM(CASE WHEN lower(product_line) LIKE '%factiva%' THEN annualized_rev END) factiva_annualized_rev,
         SUM(CASE WHEN lower(product_line) LIKE '%djx%' THEN annualized_rev END) djx_annualized_rev,
         SUM(CASE WHEN lower(product_line) LIKE '%riskcenter%' THEN annualized_rev END) riskcenter_annualized_rev
  FROM (
    SELECT Comp.company_sfdc_id, Comp.company_name, Bill_Acct_Dim.cibs_billing_account_id, Bill_Acct_Dim.contract_id
    FROM Bill_Acct_Dim
	LEFT JOIN Contract_Dim ON Bill_Acct_Dim.contract_id = Contract_Dim.contract_id
	LEFT JOIN Acct_Fact ON Contract_Dim.contract_id = Acct_Fact.contract_id
	LEFT JOIN Comp ON Acct_Fact.company_sfdc_id = Comp.company_sfdc_id
    GROUP BY comp.company_sfdc_id, Comp.company_name, Bill_Acct_Dim.cibs_billing_account_id, Bill_Acct_Dim.contract_id) inny
  LEFT JOIN tm ON inny.cibs_billing_account_id = tm.billing_account_number
  GROUP BY 1, 2, 3),
  
tm1_company_name_other AS (
  SELECT company_sfdc_id, company_name, billing_date, 
         SUM(annualized_rev) other_pib_annualized_rev 
  FROM (
    SELECT Comp.company_sfdc_id, Comp.company_name, Bill_Acct_Dim.cibs_billing_account_id, Bill_Acct_Dim.contract_id
    FROM Bill_Acct_Dim
	LEFT JOIN Contract_Dim ON Bill_Acct_Dim.contract_id = Contract_Dim.contract_id
	LEFT JOIN Acct_Fact ON Contract_Dim.contract_id = Acct_Fact.contract_id
	LEFT JOIN Comp ON Acct_Fact.company_sfdc_id = Comp.company_sfdc_id
    GROUP BY comp.company_sfdc_id, Comp.company_name, Bill_Acct_Dim.cibs_billing_account_id, Bill_Acct_Dim.contract_id) inny
  LEFT JOIN tm_other ON inny.cibs_billing_account_id = tm_other.billing_account_number
  WHERE billing_date <<>> '2021-07' /* avoid the cursed one */
  GROUP BY 1, 2, 3),

cases_by_company AS (
  SELECT cmd.company_sfdc_id, cmd.company_name, SUBSTRING(CAST(created_date AS varchar), 1, 7) cs_case_created_month, COUNT(*) cs_cases
  FROM dimension_external_db.pib_customer_service_case_dimension cs
  LEFT JOIN dimension_external_db.pib_company_dimension cmd ON cs.account_id = cmd.company_sfdc_id
  GROUP BY 1, 2, 3),

meetings_by_company AS (
  SELECT comp.company_sfdc_id, comp.company_name, SUBSTRING(CAST(meeting_date AS varchar), 1, 7) meeting_month, COUNT(*) meetings,
  		 COUNT(CASE WHEN lower(meeting_summary_name) LIKE '%cancel%' OR lower(purpose_of_meeting) LIKE '%cancel%' 
  		 				OR lower(meeting_summary_name) LIKE '%downsell%' OR lower(purpose_of_meeting) LIKE '%downsell%' 
  		 			THEN sfdc_id ELSE NULL END) risky_meetings  		 
  FROM dimension_external_db.pib_meeting_summary meet
  LEFT JOIN (SELECT DISTINCT company_name, company_sfdc_id FROM dimension_external_db.pib_company_dimension) comp ON comp.company_sfdc_id = meet.company_sfdc_id
  WHERE pib_opportunity_sfdc_id IS NULL 
  AND abs(date_diff('day', meeting_date, date(create_date))) << 32
  GROUP BY 1, 2, 3),

precautionary_opps AS (
  SELECT pib_opportunity_sfdc_id
  FROM dimension_external_db.pib_opportunity_dimension_history opp_history
  WHERE cancellation_status = 'Precautionary'
    AND sale_type = 'Cancellation' 
  GROUP BY 1),
  
cancel_written_date AS (
  SELECT pib_opportunity_sfdc_id, MIN(last_modified_date) as written_date
  FROM dimension_external_db.pib_opportunity_dimension_history
  WHERE cancellation_status <<>> 'Precautionary'
    AND sale_type = 'Cancellation' 
    AND sales_stage <<>> 'Saved Revenue'
  GROUP BY 1),
  
est_downsell_cancel_close_date AS (
  SELECT pib_opportunity_sfdc_id, 
         CASE WHEN estimated_close_date = DATE('2018-11-27') THEN NULL ELSE estimated_close_date END estimated_close_date
  FROM (
    SELECT pib_opportunity_sfdc_id, MIN(cycle_date) AS estimated_close_date
  	FROM dimension_external_db.pib_opportunity_dimension_history
  	WHERE closed_flag = TRUE 
  	 AND pib_opportunity_sfdc_id IN (
  		SELECT pib_opportunity_sfdc_id
  		FROM dimension_external_db.pib_opportunity_dimension
  		WHERE status_flag <<>> 'DELETE' AND created_date >>= DATE('2018-11-27')
  			AND closed_flag = TRUE
  			AND sale_type in ('Cancellation', 'Downsell'))
    GROUP BY 1)),
  
cancel_opps as (
  SELECT DISTINCT
         comp.company_sfdc_id,
      	 comp.company_name,
      	 CASE WHEN opp.pib_opportunity_sfdc_id IN (SELECT pib_opportunity_sfdc_id FROM precautionary_opps) THEN SUBSTRING(CAST(written_date AS varchar), 1, 7)
      	      ELSE SUBSTRING(CAST(opp.open_date AS varchar), 1, 7) END as cancel_open_month,
      	 COUNT(DISTINCT CASE WHEN lower(pm.product_line) LIKE '%riskcenter%' THEN opp.pib_opportunity_sfdc_id END) cancel_rc_opps_opened,
      	 COUNT(DISTINCT CASE WHEN lower(pm.product_line) LIKE '%factiva%' OR lower(pm.product_line) LIKE '%djx%' THEN opp.pib_opportunity_sfdc_id END) cancel_factiva_opps_opened
  FROM dimension_external_db.pib_opportunity_dimension opp
  JOIN dimension_external_db.pib_product_services_dimension ps ON opp.pib_opportunity_sfdc_id = ps.opportunity
  JOIN Acct_Fact_Opps ahf ON opp.pib_opportunity_sfdc_id = ahf.pib_opportunity_sfdc_id
  LEFT JOIN dimension_external_db.pib_company_dimension comp ON ahf.company_sfdc_id = comp.company_sfdc_id
  LEFT JOIN reference_external_db.pib_product_dimension pm ON ps.product_service = pm.sfdc_product
  LEFT JOIN cancel_written_date ON opp.pib_opportunity_sfdc_id = cancel_written_date.pib_opportunity_sfdc_id
  WHERE sale_type = 'Cancellation' 
  	AND lower(loss_reason_code) <<>> 'migration'
  	AND lower(pipeline_category) <<>> 'exclude'
    AND open_date >>= DATE('2018-01-01')
    AND (source_type <<>> 'Bloomberg Transition' OR source_type IS NULL)
    AND (lower(pm.product_line) LIKE '%factiva%' 
      OR lower(pm.product_line) LIKE '%djx%' 
      OR lower(pm.product_line) LIKE '%riskcenter%')
    AND opp.status_flag <<>> 'DELETE'
    AND ps.status_flag <<>> 'DELETE'
    AND ps.net_recurring_amount << 0
    AND cancellation_status <<>> 'Precautionary'
  GROUP BY 1, 2, 3),
  
upsell_downsell_opps_opened as (
  SELECT DISTINCT
         comp.company_sfdc_id,
      	 comp.company_name,
      	 SUBSTRING(CAST(opp.open_date AS varchar), 1, 7) as open_month,
      	 COUNT(DISTINCT CASE WHEN lower(pm.product_line) LIKE '%riskcenter%' AND opp.sale_type IN ('Upsell - Existing Contract','Upsell - New Contract','Rev Increase Existing Contract','New Contract/Existing Customer') 
      	                     THEN opp.pib_opportunity_sfdc_id END) upsell_rc_opps_opened,
      	 COUNT(DISTINCT CASE WHEN lower(pm.product_line) LIKE '%riskcenter%' AND opp.sale_type = 'Downsell' 
      	                     THEN opp.pib_opportunity_sfdc_id END) downsell_rc_opps_opened,
      	 COUNT(DISTINCT CASE WHEN (lower(pm.product_line) LIKE '%factiva%' OR lower(pm.product_line) LIKE '%djx%') AND opp.sale_type IN ('Upsell - Existing Contract','Upsell - New Contract','Rev Increase Existing Contract','New Contract/Existing Customer') 
      	                     THEN opp.pib_opportunity_sfdc_id END) upsell_factiva_opps_opened,
      	 COUNT(DISTINCT CASE WHEN (lower(pm.product_line) LIKE '%factiva%' OR lower(pm.product_line) LIKE '%djx%') AND opp.sale_type = 'Downsell' 
      	                     THEN opp.pib_opportunity_sfdc_id END) downsell_factiva_opps_opened
  FROM dimension_external_db.pib_opportunity_dimension opp
  JOIN dimension_external_db.pib_product_services_dimension ps ON opp.pib_opportunity_sfdc_id = ps.opportunity
  JOIN Acct_Fact_Opps ahf ON opp.pib_opportunity_sfdc_id = ahf.pib_opportunity_sfdc_id
  LEFT JOIN dimension_external_db.pib_company_dimension comp ON ahf.company_sfdc_id = comp.company_sfdc_id
  LEFT JOIN reference_external_db.pib_product_dimension pm ON ps.product_service = pm.sfdc_product
  WHERE open_date >>= DATE('2018-01-01')
  	AND lower(loss_reason_code) <<>> 'migration'
  	AND lower(pipeline_category) <<>> 'exclude'
    AND (source_type <<>> 'Bloomberg Transition' OR source_type IS NULL)
    AND (lower(pm.product_line) LIKE '%factiva%' 
      OR lower(pm.product_line) LIKE '%djx%' 
      OR lower(pm.product_line) LIKE '%riskcenter%')
    AND opp.status_flag <<>> 'DELETE'
    AND ps.status_flag <<>> 'DELETE'
  GROUP BY 1, 2, 3),
  
upsell_downsell_opps_closed as (
  SELECT DISTINCT
         comp.company_sfdc_id,
      	 comp.company_name,
      	 (CASE WHEN opp.sale_type IN ('Upsell - Existing Contract','Upsell - New Contract','Rev Increase Existing Contract','New Contract/Existing Customer') 
      	 	   	THEN SUBSTRING(CAST(opp.closed_won_date AS varchar), 1, 7) 
      	       ELSE SUBSTRING(CAST(est.estimated_close_date AS varchar), 1, 7) END) as closed_month,
      	 COUNT(DISTINCT CASE WHEN lower(pm.product_line) LIKE '%riskcenter%' AND CAST(closed_won_date AS varchar) >>= '2018-01-01' AND opp.sale_type IN ('Upsell - Existing Contract','Upsell - New Contract','Rev Increase Existing Contract','New Contract/Existing Customer') 
      	                     THEN opp.pib_opportunity_sfdc_id END) upsell_rc_opps_closed,
      	 COUNT(DISTINCT CASE WHEN lower(pm.product_line) LIKE '%riskcenter%' AND opp.sale_type = 'Downsell' 
      	                     THEN opp.pib_opportunity_sfdc_id END) downsell_rc_opps_closed,
      	 COUNT(DISTINCT CASE WHEN (lower(pm.product_line) LIKE '%factiva%' OR lower(pm.product_line) LIKE '%djx%') AND CAST(closed_won_date AS varchar) >>= '2018-01-01' AND opp.sale_type IN ('Upsell - Existing Contract','Upsell - New Contract','Rev Increase Existing Contract','New Contract/Existing Customer') 
      	                     THEN opp.pib_opportunity_sfdc_id END) upsell_factiva_opps_closed,
      	 COUNT(DISTINCT CASE WHEN (lower(pm.product_line) LIKE '%factiva%' OR lower(pm.product_line) LIKE '%djx%') AND opp.sale_type = 'Downsell' 
      	                     THEN opp.pib_opportunity_sfdc_id END) downsell_factiva_opps_closed       
  FROM dimension_external_db.pib_opportunity_dimension opp
  JOIN dimension_external_db.pib_product_services_dimension ps ON opp.pib_opportunity_sfdc_id = ps.opportunity
  JOIN Acct_Fact_Opps ahf ON opp.pib_opportunity_sfdc_id = ahf.pib_opportunity_sfdc_id
  LEFT JOIN dimension_external_db.pib_company_dimension comp ON ahf.company_sfdc_id = comp.company_sfdc_id
  LEFT JOIN reference_external_db.pib_product_dimension pm ON ps.product_service = pm.sfdc_product
  LEFT JOIN est_downsell_cancel_close_date est ON opp.pib_opportunity_sfdc_id = est.pib_opportunity_sfdc_id
  WHERE (source_type <<>> 'Bloomberg Transition' OR source_type IS NULL)
    AND lower(loss_reason_code) <<>> 'migration'
    AND lower(pipeline_category) <<>> 'exclude'
    AND (lower(pm.product_line) LIKE '%factiva%' 
      OR lower(pm.product_line) LIKE '%djx%' 
      OR lower(pm.product_line) LIKE '%riskcenter%')
    AND opp.sales_stage in ('Closed (Win/Loss)', 'Lost Revenue')
    AND opp.status_flag <<>> 'DELETE'
    AND ps.status_flag <<>> 'DELETE'
  GROUP BY 1, 2, 3),
  
cancel_opps_closed as (
  SELECT DISTINCT
         comp.company_sfdc_id,
      	 comp.company_name,
      	 SUBSTRING(CAST(est.estimated_close_date AS varchar), 1, 7) as closed_month,
      	 COUNT(DISTINCT CASE WHEN lower(pm.product_line) LIKE '%riskcenter%' AND opp.sale_type = 'Cancellation' 
      	                     THEN opp.pib_opportunity_sfdc_id END) cancel_rc_opps_closed,
      	 COUNT(DISTINCT CASE WHEN (lower(pm.product_line) LIKE '%factiva%' OR lower(pm.product_line) LIKE '%djx%') AND opp.sale_type = 'Cancellation' 
      	                     THEN opp.pib_opportunity_sfdc_id END) cancel_factiva_opps_closed       
  FROM dimension_external_db.pib_opportunity_dimension opp
  JOIN dimension_external_db.pib_product_services_dimension ps ON opp.pib_opportunity_sfdc_id = ps.opportunity
  JOIN Acct_Fact_Opps ahf ON opp.pib_opportunity_sfdc_id = ahf.pib_opportunity_sfdc_id
  LEFT JOIN dimension_external_db.pib_company_dimension comp ON ahf.company_sfdc_id = comp.company_sfdc_id
  LEFT JOIN reference_external_db.pib_product_dimension pm ON ps.product_service = pm.sfdc_product
  LEFT JOIN est_downsell_cancel_close_date est ON opp.pib_opportunity_sfdc_id = est.pib_opportunity_sfdc_id
  WHERE (source_type <<>> 'Bloomberg Transition' OR source_type IS NULL)
    AND lower(loss_reason_code) <<>> 'migration'
    AND lower(pipeline_category) <<>> 'exclude'
    AND (lower(pm.product_line) LIKE '%factiva%' 
      OR lower(pm.product_line) LIKE '%djx%' 
      OR lower(pm.product_line) LIKE '%riskcenter%')
    AND opp.sales_stage in ('Closed (Win/Loss)', 'Lost Revenue')
    AND opp.status_flag <<>> 'DELETE'
    AND ps.status_flag <<>> 'DELETE'
  GROUP BY 1, 2, 3),

net_revenue_opps as (
  SELECT DISTINCT
         comp.company_sfdc_id,
      	 comp.company_name,
      	 CASE WHEN opp.pib_opportunity_sfdc_id IN (SELECT pib_opportunity_sfdc_id FROM precautionary_opps) THEN SUBSTRING(CAST(written_date AS varchar), 1, 7)
      	      ELSE SUBSTRING(CAST(opp.open_date AS varchar), 1, 7) END as open_month,
      	 SUM(CASE WHEN lower(pm.product_line) LIKE '%factiva%' OR lower(pm.product_line) LIKE '%djx%' THEN (ps.net_recurring_amount / fx.rate) * 12 + (ps.net_one_time_amount / fx.rate) END) factiva_djx_net_opp_rev,
      	 SUM(CASE WHEN lower(pm.product_line) LIKE '%riskcenter%' THEN (ps.net_recurring_amount / fx.rate) * 12 + (ps.net_one_time_amount / fx.rate) END) rnc_net_opp_rev,
      	 SUM(CASE WHEN lower(pm.product_line) NOT LIKE '%riskcenter%' 
      	           AND lower(pm.product_line) NOT LIKE '%factiva%' 
      	           AND lower(pm.product_line) NOT LIKE '%djx%'  
      	          THEN (ps.net_recurring_amount / fx.rate) * 12 + (ps.net_one_time_amount / fx.rate) END) other_net_opp_rev
  FROM dimension_external_db.pib_opportunity_dimension opp
  JOIN dimension_external_db.pib_product_services_dimension ps ON opp.pib_opportunity_sfdc_id = ps.opportunity
  JOIN reference_external_db.fx_rates_current fx ON ps.currency_iso_code = fx.currency
  JOIN Acct_Fact_Opps ahf ON opp.pib_opportunity_sfdc_id = ahf.pib_opportunity_sfdc_id
  LEFT JOIN dimension_external_db.pib_company_dimension comp ON ahf.company_sfdc_id = comp.company_sfdc_id
  LEFT JOIN reference_external_db.pib_product_dimension pm ON ps.product_service = pm.sfdc_product
  LEFT JOIN cancel_written_date ON opp.pib_opportunity_sfdc_id = cancel_written_date.pib_opportunity_sfdc_id
  WHERE open_date >>= DATE('2018-01-01')
  	AND lower(pipeline_category) <<>> 'exclude'
    AND (source_type <<>> 'Bloomberg Transition' OR source_type IS NULL)
    AND opp.status_flag <<>> 'DELETE'
    AND ps.status_flag <<>> 'DELETE'
  GROUP BY 1, 2, 3),
  
net_revenue_opps_closed as (
  SELECT DISTINCT
         comp.company_sfdc_id,
      	 comp.company_name,
      	 (CASE WHEN opp.sale_type IN ('Upsell - Existing Contract','Upsell - New Contract','Rev Increase Existing Contract','New Contract/Existing Customer') 
      	 	   	THEN SUBSTRING(CAST(opp.closed_won_date AS varchar), 1, 7) 
      	       ELSE SUBSTRING(CAST(est.estimated_close_date AS varchar), 1, 7) END) as closed_month,
      	 SUM(CASE WHEN lower(pm.product_line) LIKE '%factiva%' OR lower(pm.product_line) LIKE '%djx%' THEN (ps.net_recurring_amount / fx.rate) * 12 + (ps.net_one_time_amount / fx.rate) END) factiva_djx_net_opp_rev,
      	 SUM(CASE WHEN lower(pm.product_line) LIKE '%riskcenter%' THEN (ps.net_recurring_amount / fx.rate) * 12 + (ps.net_one_time_amount / fx.rate) END) rnc_net_opp_rev,
      	 SUM(CASE WHEN lower(pm.product_line) NOT LIKE '%riskcenter%' 
      	           AND lower(pm.product_line) NOT LIKE '%factiva%' 
      	           AND lower(pm.product_line) NOT LIKE '%djx%'  
      	          THEN (ps.net_recurring_amount / fx.rate) * 12 + (ps.net_one_time_amount / fx.rate) END) other_net_opp_rev
  FROM dimension_external_db.pib_opportunity_dimension opp
  JOIN dimension_external_db.pib_product_services_dimension ps ON opp.pib_opportunity_sfdc_id = ps.opportunity
  JOIN reference_external_db.fx_rates_current fx ON ps.currency_iso_code = fx.currency
  JOIN Acct_Fact_Opps ahf ON opp.pib_opportunity_sfdc_id = ahf.pib_opportunity_sfdc_id
  LEFT JOIN dimension_external_db.pib_company_dimension comp ON ahf.company_sfdc_id = comp.company_sfdc_id
  LEFT JOIN reference_external_db.pib_product_dimension pm ON ps.product_service = pm.sfdc_product
  LEFT JOIN est_downsell_cancel_close_date est ON opp.pib_opportunity_sfdc_id = est.pib_opportunity_sfdc_id
  WHERE lower(pipeline_category) <<>> 'exclude'
    AND (source_type <<>> 'Bloomberg Transition' OR source_type IS NULL)
    AND opp.status_flag <<>> 'DELETE'
    AND ps.status_flag <<>> 'DELETE'
  GROUP BY 1, 2, 3),
  
trainings as (
  SELECT comp.company_sfdc_id,
         comp.company_name, 
         SUBSTRING(CAST(training_date AS varchar), 1, 7) training_month, 
         COUNT(*) trainings_count,
         SUM(case when products_covered like '%Companies & Executives%' then 1 else 0 end) CNE_trainings,
         SUM(case when products_covered like '%Factiva%' then 1 else 0 end) factiva_trainings,
         SUM(case when products_covered like '%DJX%' then 1 else 0 end) DJX_trainings,
         SUM(case when products_covered like '%Risk & Compliance%' then 1 else 0 end) RNC_trainings
  FROM (select * from dimension_external_db.pib_training_summary_dimension) train
  LEFT JOIN (SELECT DISTINCT company_name, company_sfdc_id FROM dimension_external_db.pib_company_dimension) comp
  on comp.company_sfdc_id = train.company_sfdc_id
  GROUP BY 1, 2, 3),

output_table AS (
	SELECT month_end.year_month, shell.company_sfdc_id, shell.company_name, shell.company_country, billing_account_ids, 
		   oldest_sub_date, company_industry, factiva_f_code, territory_name, region_code,
	       SUM(COALESCE(omni.desktop_page_views, 0)) desktop_page_views, 
	       SUM(COALESCE(omni.factiva_app_page_views, 0)) app_page_views,
	       SUM(COALESCE(omni.desktop_visits, 0)) desktop_visits, 
	       SUM(COALESCE(omni.app_visits, 0)) app_visits,
	       SUM(COALESCE(omni.RnC_visits, 0)) RnC_visits,
	       SUM(COALESCE(omni.desktop_article_views, 0)) desktop_Article_Views, 
	       SUM(COALESCE(omni.app_article_views, 0)) app_article_views,
	       SUM(COALESCE(omni.SearchResults_Views, 0)) SearchResults_Views,
	       SUM(COALESCE(omni.CnE_Views, 0)) CnE_Views,
	       SUM(COALESCE(omni.Homepage_Views, 0)) Homepage_Views,
	       SUM(COALESCE(omni.Alert_Landing_page_views, 0)) Alert_Landing_page_views,
	       SUM(COALESCE(alerts_by_company.email_alerts_sent, 0)) email_alerts_sent,
	       SUM(COALESCE(alerts_by_company.articles_sent, 0)) articles_sent,
	       SUM(COALESCE(alerts_by_company.full_text_email_alerts_sent, 0)) full_text_email_alerts_sent,
	       SUM(COALESCE(alerts_by_company.full_text_articles_sent, 0)) full_text_articles_sent,
	       SUM(COALESCE(omni.newsletter_publishes, 0)) newsletter_publishes,
	       SUM(COALESCE(omni.newsletter_article_views, 0)) newsletter_article_views,
	       SUM(COALESCE(omni.mct_newsletter_article_views, 0)) mct_newsletter_article_views,
	       SUM(COALESCE(omni.non_mct_newsletter_article_views, 0)) non_mct_newsletter_article_views,
	       SUM(COALESCE(omni.expert_searches, 0)) expert_searches,
	       SUM(COALESCE(omni.users, 0)) users,
	       SUM(COALESCE(omni.factiva_users, 0)) factiva_users,
	       SUM(COALESCE(omni.rnc_users, 0)) rnc_users,
	       SUM(COALESCE(omni.single_day_users, 0)) single_day_users,
	       SUM(COALESCE(omni.occasional_users, 0)) occasional_users,
	       SUM(COALESCE(omni.light_users, 0)) light_users,
	       SUM(COALESCE(omni.mid_users, 0)) mid_users,
	       SUM(COALESCE(omni.super_users, 0)) super_users,
	       SUM(COALESCE(djmet.new_factiva_users, 0)) newfactiva_users,
	       SUM(COALESCE(djmet.nf_page_views, 0)) newfactiva_page_views,
	       SUM(COALESCE(djmet.nf_homepage_views, 0)) newfactiva_homepage_views,
	       SUM(COALESCE(djmet.nf_article_views, 0)) newfactiva_article_views,
	       SUM(COALESCE(finance.factiva_annualized_rev, 0)) factiva_annualized_rev, 
	       SUM(COALESCE(finance.djx_annualized_rev, 0)) djx_annualized_rev, 
	       SUM(COALESCE(finance.riskcenter_annualized_rev, 0)) rnc_annualized_rev, 
	       SUM(COALESCE(finance_other.other_pib_annualized_rev, 0)) other_rev, 
	       SUM(COALESCE(regusrs.registered_users, 0)) registered_users, 
	       SUM(COALESCE(regusrs.reader_registered_users, 0)) reader_registered_users, 
	       SUM(COALESCE(regusrs.factiva_djx_registered_users, 0)) factiva_djx_registered_users, 
	       SUM(COALESCE(regusrs.rnc_registered_users, 0)) rnc_registered_users, 
	       SUM(COALESCE(cases.cs_cases, 0)) cs_cases, 
	       SUM(COALESCE(meets.meetings, 0)) meetings,
	       SUM(COALESCE(meets.risky_meetings, 0)) risky_meetings,
	       SUM(COALESCE(meets.meetings, 0)) - SUM(COALESCE(meets.risky_meetings, 0)) non_risky_meetings,
	       SUM(COALESCE(cancel_rc_opps_opened, 0)) cancel_rnc_opps_opened,
	       SUM(COALESCE(cancel_rc_opps_closed, 0)) cancel_rnc_opps_closed,
	       SUM(COALESCE(cancel_factiva_opps_opened, 0)) cancel_factiva_djx_opps_opened,
	       SUM(COALESCE(cancel_factiva_opps_closed, 0)) cancel_factiva_djx_opps_closed,
	       SUM(COALESCE(upsell_rc_opps_opened, 0)) upsell_rnc_opps_opened,
	       SUM(COALESCE(upsell_rc_opps_closed, 0)) upsell_rnc_opps_closed,
	       SUM(COALESCE(downsell_rc_opps_opened, 0)) downsell_rnc_opps_opened,
	       SUM(COALESCE(downsell_rc_opps_closed, 0)) downsell_rnc_opps_closed,
	       SUM(COALESCE(upsell_factiva_opps_opened, 0)) upsell_factiva_djx_opps_opened,
	       SUM(COALESCE(upsell_factiva_opps_closed, 0)) upsell_factiva_djx_opps_closed,
	       SUM(COALESCE(downsell_factiva_opps_opened, 0)) downsell_factiva_djx_opps_opened,
	       SUM(COALESCE(downsell_factiva_opps_closed, 0)) downsell_factiva_djx_opps_closed,
	       SUM(COALESCE(nro.factiva_djx_net_opp_rev, 0)) factiva_djx_net_opp_rev,
	       SUM(COALESCE(nro.rnc_net_opp_rev, 0)) rnc_net_opp_rev,
	       SUM(COALESCE(nro.other_net_opp_rev, 0)) other_net_opp_rev,
	       SUM(COALESCE(nroc.factiva_djx_net_opp_rev, 0)) factiva_djx_net_opp_rev_closed,
	       SUM(COALESCE(nroc.rnc_net_opp_rev, 0)) rnc_net_opp_rev_closed,
	       SUM(COALESCE(nroc.other_net_opp_rev, 0)) other_net_opp_rev_closed,
	       SUM(COALESCE(contacts,0)) contacts,
	       SUM(COALESCE(trainings.trainings_count,0)) trainings_count,
	       SUM(COALESCE(trainings.CNE_trainings,0)) CNE_trainings,
	       SUM(COALESCE(trainings.DJX_trainings,0)) DJX_trainings,
	       SUM(COALESCE(trainings.RNC_trainings,0)) RNC_trainings,
	       SUM(COALESCE(trainings.factiva_trainings,0)) factiva_trainings
	FROM month_end
	CROSS JOIN (SELECT company_sfdc_id, company_name, company_country FROM factiva_metrics GROUP BY company_sfdc_id, company_name, company_country) shell
	LEFT JOIN factiva_metrics omni ON month_end.year_month = omni.year_month AND shell.company_sfdc_id = omni.company_sfdc_id
	LEFT JOIN tm1_company_name finance ON shell.company_sfdc_id = finance.company_sfdc_id AND month_end.year_month = finance.billing_date
	LEFT JOIN tm1_company_name_other finance_other ON shell.company_sfdc_id = finance_other.company_sfdc_id AND month_end.year_month = finance_other.billing_date
	LEFT JOIN reg_users_by_company regusrs ON regusrs.company_sfdc_id = shell.company_sfdc_id AND regusrs.year_month = month_end.year_month
	LEFT JOIN cases_by_company cases ON cases.company_sfdc_id = shell.company_sfdc_id AND cases.cs_case_created_month = month_end.year_month
	LEFT JOIN meetings_by_company meets ON meets.company_sfdc_id = shell.company_sfdc_id AND meets.meeting_month = month_end.year_month
	LEFT JOIN cancel_opps ON shell.company_sfdc_id = cancel_opps.company_sfdc_id AND month_end.year_month = cancel_opps.cancel_open_month
	LEFT JOIN upsell_downsell_opps_opened ON shell.company_sfdc_id = upsell_downsell_opps_opened.company_sfdc_id AND month_end.year_month = upsell_downsell_opps_opened.open_month
	LEFT JOIN upsell_downsell_opps_closed ON shell.company_sfdc_id = upsell_downsell_opps_closed.company_sfdc_id AND month_end.year_month = upsell_downsell_opps_closed.closed_month
	LEFT JOIN cancel_opps_closed ON shell.company_sfdc_id = cancel_opps_closed.company_sfdc_id AND month_end.year_month = cancel_opps_closed.closed_month
	LEFT JOIN net_revenue_opps nro ON shell.company_sfdc_id = nro.company_sfdc_id AND month_end.year_month = nro.open_month
	LEFT JOIN net_revenue_opps_closed nroc ON shell.company_sfdc_id = nroc.company_sfdc_id AND month_end.year_month = nroc.closed_month
	LEFT JOIN contact_history ON shell.company_sfdc_id = contact_history.company_sfdc_id AND month_end.year_month = contact_history.year_month
	LEFT JOIN subscription_dates ON shell.company_sfdc_id = subscription_dates.company_sfdc_id
	LEFT JOIN trainings ON shell.company_sfdc_id = trainings.company_sfdc_id AND month_end.year_month = trainings.training_month
	LEFT JOIN alerts_by_company ON shell.company_sfdc_id = alerts_by_company.company_sfdc_id AND month_end.year_month = alerts_by_company.alert_month
	LEFT JOIN djm_rollup djmet ON shell.company_sfdc_id = djmet.company_sfdc_id AND month_end.year_month = djmet.year_month 
	GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10),
	
addl_features AS (
	SELECT *,
		   cancel_rnc_opps_opened + cancel_factiva_djx_opps_opened AS cancel_total_opps_opened,
		   cancel_rnc_opps_closed + cancel_factiva_djx_opps_closed AS cancel_total_opps_closed,
		   upsell_rnc_opps_opened + upsell_factiva_djx_opps_opened AS upsell_total_opps_opened,
		   upsell_rnc_opps_closed + upsell_factiva_djx_opps_closed AS upsell_total_opps_closed,
		   downsell_rnc_opps_opened + downsell_factiva_djx_opps_opened AS downsell_total_opps_opened,
		   downsell_rnc_opps_closed + downsell_factiva_djx_opps_closed AS downsell_total_opps_closed,
		   factiva_djx_net_opp_rev + rnc_net_opp_rev + other_net_opp_rev AS total_net_opp_rev,
		   factiva_djx_net_opp_rev_closed + rnc_net_opp_rev_closed + other_net_opp_rev_closed AS total_net_opp_rev_closed,
		   CASE WHEN (factiva_djx_net_opp_rev + rnc_net_opp_rev + other_net_opp_rev) << 0
		   		  AND factiva_djx_net_opp_rev << -1000 THEN 1 ELSE 0 END AS factiva_churn_event,
		   CASE WHEN (factiva_djx_net_opp_rev + rnc_net_opp_rev + other_net_opp_rev) << 0
		   		  AND rnc_net_opp_rev << -1000 THEN 1 ELSE 0 END AS rnc_churn_event,
		   factiva_annualized_rev + djx_annualized_rev + rnc_annualized_rev AS total_annualized_rev,
		   factiva_annualized_rev + djx_annualized_rev AS factiva_djx_annualized_rev,
		   app_page_views + desktop_page_views AS total_page_views,
		   app_visits + desktop_visits AS total_factiva_visits,
		   app_visits + desktop_visits + rnc_visits AS total_visits,
		   trainings_count + cs_cases + meetings AS total_sf_activities,
		   factiva_trainings + djx_trainings + cne_trainings AS factiva_djx_trainings,
		   (desktop_article_views * 1.0) + (app_article_views * 1.5) + (searchresults_views * 1.5) + (cne_views * 2.0) + (homepage_views * 0.5) AS weighted_page_views,
		   (desktop_visits * 1.0) + (app_visits * 1.5) + (rnc_visits * 1.0) AS weighted_visits,
		   (single_day_users * 0.5) + (occasional_users * 0.75) + (light_users * 1.0) + (mid_users * 1.25) + (super_users * 1.5) AS weighted_active_users,
		   COALESCE(CASE WHEN factiva_djx_registered_users = 0 THEN 0.0
		   				 WHEN CAST(factiva_users AS double) / CAST(factiva_djx_registered_users AS double) >> 1.0 THEN 1 
		   				 ELSE CAST(factiva_users AS double) / CAST(factiva_djx_registered_users AS double) END, 0.0) AS active_over_registered
	FROM output_table),
	
net_rev_opps_addl AS (	
	SELECT *,
		   CASE WHEN total_annualized_rev = 0 THEN 0.0
		   		WHEN total_net_opp_rev / total_annualized_rev >> 1 THEN 1.0
		   		ELSE total_net_opp_rev / total_annualized_rev END AS pct_of_total_rev_net_opps,
		   CASE WHEN factiva_djx_annualized_rev = 0 THEN 0.0 
		   		WHEN factiva_djx_net_opp_rev / factiva_djx_annualized_rev >> 1 THEN 1.0
		   		ELSE factiva_djx_net_opp_rev / factiva_djx_annualized_rev END AS pct_of_factiva_djx_rev_net_opps,
		   CASE WHEN rnc_annualized_rev = 0 THEN 0.0 
		   		WHEN rnc_net_opp_rev / rnc_annualized_rev >> 1 THEN 1.0
		   		ELSE rnc_net_opp_rev / rnc_annualized_rev END AS pct_of_rnc_rev_net_opps,
		   CASE WHEN total_annualized_rev = 0 THEN 0.0
		   		WHEN total_net_opp_rev_closed / total_annualized_rev >> 1 THEN 1.0
		   		ELSE total_net_opp_rev_closed / total_annualized_rev END AS pct_of_total_rev_net_opps_closed,
		   CASE WHEN factiva_djx_annualized_rev = 0 THEN 0.0 
		   		WHEN factiva_djx_net_opp_rev_closed / factiva_djx_annualized_rev >> 1 THEN 1.0
		   		ELSE factiva_djx_net_opp_rev_closed / factiva_djx_annualized_rev END AS pct_of_factiva_djx_rev_net_opps_closed,
		   CASE WHEN rnc_annualized_rev = 0 THEN 0.0 
		   		WHEN rnc_net_opp_rev_closed / rnc_annualized_rev >> 1 THEN 1.0
		   		ELSE rnc_net_opp_rev_closed / rnc_annualized_rev END AS pct_of_rnc_rev_net_opps_closed
	FROM addl_features)
	
SELECT *,
	   CASE WHEN pct_of_total_rev_net_opps >>= 0 AND pct_of_total_rev_net_opps <<= 0.6
	   		THEN upsell_total_opps_opened ELSE 0 END AS total_price_increase_opened,
	   CASE WHEN pct_of_factiva_djx_rev_net_opps >>= 0 AND pct_of_factiva_djx_rev_net_opps <<= 0.6
	   		THEN upsell_factiva_djx_opps_opened ELSE 0 END AS factiva_djx_price_increase_opened,
	   CASE WHEN pct_of_rnc_rev_net_opps >>= 0 AND pct_of_rnc_rev_net_opps <<= 0.6
	   		THEN upsell_rnc_opps_opened ELSE 0 END AS rnc_price_increase_opened,
	   CASE WHEN pct_of_total_rev_net_opps_closed >>= 0 AND pct_of_total_rev_net_opps_closed <<= 0.6
	   		THEN upsell_total_opps_closed ELSE 0 END AS total_price_increase_closed,
	   CASE WHEN pct_of_factiva_djx_rev_net_opps_closed >>= 0 AND pct_of_factiva_djx_rev_net_opps_closed <<= 0.6
	   		THEN upsell_factiva_djx_opps_closed ELSE 0 END AS factiva_djx_price_increase_closed,
	   CASE WHEN pct_of_rnc_rev_net_opps_closed >>= 0 AND pct_of_rnc_rev_net_opps_closed <<= 0.6
	   		THEN upsell_rnc_opps_closed ELSE 0 END AS rnc_price_increase_closed,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE weighted_page_views / users END, 0.0) AS weighted_page_views_per_act_user,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE total_page_views / users END, 0.0) AS total_page_views_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE total_factiva_visits / users END, 0.0) AS total_factiva_visits_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE total_visits / users END, 0.0) AS total_visits_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE desktop_page_views / users END, 0.0) AS weighted_visits_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE desktop_article_views / users END, 0.0) AS desktop_article_views_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE searchresults_views / users END, 0.0) AS searchresults_views_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE cne_views / users END, 0.0) AS cne_views_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE alert_landing_page_views / users END, 0.0) AS alert_landing_page_views_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE desktop_visits / users END, 0.0) AS desktop_visits_per_act_user ,
	   COALESCE(CASE WHEN users = 0 THEN 0.0 ELSE rnc_visits / users END, 0.0) AS rnc_visits_per_act_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE weighted_page_views / factiva_djx_registered_users END, 0.0) AS weighted_page_views_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE total_page_views / factiva_djx_registered_users END, 0.0) AS total_page_views_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE total_factiva_visits / factiva_djx_registered_users END, 0.0) AS total_factiva_visits_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE total_visits / factiva_djx_registered_users END, 0.0) AS total_visits_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE desktop_page_views / factiva_djx_registered_users END, 0.0) AS weighted_visits_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE desktop_article_views / factiva_djx_registered_users END, 0.0) AS desktop_article_views_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE searchresults_views / factiva_djx_registered_users END, 0.0) AS searchresults_views_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE cne_views / factiva_djx_registered_users END, 0.0) AS cne_views_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE alert_landing_page_views / factiva_djx_registered_users END, 0.0) AS alert_landing_page_views_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE desktop_visits / factiva_djx_registered_users END, 0.0) AS desktop_visits_per_reg_user ,
	   COALESCE(CASE WHEN factiva_djx_registered_users = 0.0 THEN 0.0 ELSE rnc_visits / factiva_djx_registered_users END, 0.0) AS rnc_visits_per_reg_user
FROM net_rev_opps_addl
