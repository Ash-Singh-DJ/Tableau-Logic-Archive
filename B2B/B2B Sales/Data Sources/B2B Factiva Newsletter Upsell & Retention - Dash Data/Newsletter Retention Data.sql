-- Published data source : "B2B Factiva Newsletter Upsell & Retention -  Dash Data"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Newsletter Retention Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH omnit as (
  SELECT *
  FROM
	(SELECT post_evar3, SUBSTRING(CAST(date_time AS varchar),1,7) year_month, post_prop40,
	         SUM(CASE WHEN CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                    AND lower(post_pagename) LIKE '%newslettersent%' THEN 1 ELSE 0 END) Newsletter_Publishes,
	         SUM(CASE WHEN CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
	                    AND post_campaign like 'newsletter%' AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' THEN 1 ELSE 0 END) Newsletter_Article_Views
	  FROM (
	    SELECT date_time, hit_source, post_page_event, exclude_hit, post_evar3, post_evar4, post_prop3, post_pagename, post_prop4, post_prop20, post_campaign, post_prop40
	    FROM fact_external_db.omniture_event_fact
	    WHERE reporting_suite = 'djfactiva'
	      AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	      AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	     ) omnit
	  WHERE date_time >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE)))
	    AND date_time <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	  GROUP BY 1, 2, 3)
  WHERE Newsletter_Publishes + Newsletter_Article_Views >> 0),

user_level_omnit as (
  SELECT mem.eid, SUM(omnit.newsletter_publishes) as sum_newsletter_publishes, SUM(omnit.newsletter_article_views) as sum_newsletter_article_views
  FROM omnit
  LEFT JOIN dimension_external_db.pib_membership_dimension mem on omnit.post_evar3 = mem.eid
  GROUP BY mem.eid
  HAVING SUM(omnit.newsletter_publishes) + SUM(omnit.newsletter_article_views) >> 0),
  
month_end as (
  SELECT SUBSTRING(CAST(full_date AS varchar),1,7) as year_month, MAX(DATE_TRUNC('month',full_date)) as month_end_date
  FROM reference_external_db.date_dimension
  WHERE full_date >>= DATE_TRUNC('month', DATE_ADD('month', -12, CURRENT_DATE))
    AND full_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
  GROUP BY 1),
  
membership_cross_month as (
  SELECT mem.eid, month_end.year_month
  FROM dimension_external_db.pib_membership_dimension mem
  CROSS JOIN month_end
  JOIN fact_external_db.pib_membership_fact mem_fact ON mem.pib_member_id = mem_fact.pib_member_id
  WHERE lower(mem.user_id) NOT LIKE 'nle%'
    AND lower(mem.user_id) NOT LIKE 'nlp%'
    AND mem.billing_account_id NOT LIKE '9ZZZ%'
    AND mem.billing_account_id NOT LIKE '9ZFB%'
    AND mem.eid IN (SELECT eid FROM user_level_omnit GROUP BY eid)
  GROUP BY mem.eid, month_end.year_month)

SELECT mem.eid, membership_cross_month.year_month, mem.user_id, mem.email,
       CASE WHEN mem.user_status = 'A' THEN 'Active'
            WHEN mem.user_status = 'I' THEN 'Inactive'
            WHEN mem.user_status = 'D' THEN 'Terminated' END as user_status,
       mem.billing_account_id, comp.company_name, salesforce_status as ba_status,
       ud.user_full_name as sales_person, territory_name as account_sales_territory,
       account_sales_region, regional_sales_director as rsd_id,
       rsdud.user_full_name as rsd,
       post_prop40 as newsletter_name,
       SUM(COALESCE(Newsletter_Publishes,0)) newsletter_publishes,
       SUM(COALESCE(Newsletter_Article_Views,0)) newsletter_article_views
FROM membership_cross_month
LEFT JOIN omnit ON (membership_cross_month.eid = omnit.post_evar3 AND membership_cross_month.year_month = omnit.year_month)
LEFT JOIN dimension_external_db.pib_membership_dimension mem on membership_cross_month.eid = mem.eid
JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
JOIN fact_external_db.pib_membership_fact mem_fact ON mem.pib_member_id = mem_fact.pib_member_id
LEFT OUTER JOIN (SELECT DISTINCT contract_id, company_sfdc_id FROM fact_external_db.pib_account_hierarchy_fact) acct ON mem_fact.contract_id = acct.contract_id
LEFT OUTER JOIN dimension_external_db.pib_company_dimension comp ON acct.company_sfdc_id = comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension ud ON comp.owner_id = ud.user_sfdc_id
LEFT JOIN dimension_external_db.pib_user_dimension rsdud ON td.regional_sales_director = rsdud.user_sfdc_id
GROUP BY mem.eid, membership_cross_month.year_month, mem.user_id, mem.email, mem.user_status, mem.billing_account_id, comp.company_name, salesforce_status, ud.user_full_name, territory_name, account_sales_region, regional_sales_director, rsdud.user_full_name, post_prop40
