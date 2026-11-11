-- Published data source : "B2B  Factiva Usage by Content Source and Account - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "omnit_user_source_usage"
-- Connection  : Athena (AwsDataCatalog / sandbox_mk), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with jf as
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT'),


omnit AS (
	SELECT SUBSTRING(CAST(date_time AS varchar),1,10) year_month_day, post_evar3, Source_Code,
         SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
                       CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
                  THEN 1 ELSE 0 END) article_views
  	FROM (
	    SELECT date_time, hit_source, post_page_event, exclude_hit, post_evar3, post_evar4, post_prop3, post_pagename, post_prop4, post_prop20,
	           CASE WHEN STRPOS(post_prop8,'_') = 0 THEN UPPER(post_prop8)
	                ELSE UPPER(SUBSTRING(post_prop8,1,STRPOS(post_prop8,'_')-1)) END Source_Code
	    FROM fact_external_db.omniture_event_fact
	    WHERE reporting_suite = 'djfactiva'
	      AND cycle_date >>= DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -36, CURRENT_DATE)))
	      AND cycle_date <<= DATE_ADD('day', -1, DATE_TRUNC('month', CURRENT_DATE))
	      )
	 WHERE DATE_TRUNC('day',date_time) >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('month', -36, CURRENT_DATE)))
    	AND DATE_TRUNC('day',date_time) << DATE_TRUNC('month', CURRENT_DATE)
	 GROUP BY 1, 2, 3
	 HAVING SUM(CASE WHEN (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%') AND
	                      CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9'))
	                 THEN 1 ELSE 0 END) >> 0
),

company_mapping AS (
	SELECT mem.pib_member_id, mem.user_id, mem.first_name, mem.last_name, mem.email, 
	       mem.billing_account_id, mem.plan_id, mem.country_code, pm.product_line,
	       pm.master_product, comp.company_name, comp.company_country, comp.company_industry,
	       td.territory_name, bad.account_sales_territory, mem.department_code 
	FROM dimension_external_db.pib_membership_dimension mem
	LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
	LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
	LEFT JOIN reference_external_db.pib_product_dimension pm ON mem.plan_id = pm.access_code
	LEFT JOIN dimension_external_db.pib_territory_dimension td ON comp.company_territory = td.territory_sfdc_id
	left join jf on mem.pib_member_id = jf.pib_member_id
	
)

SELECT omnit.post_evar3, omnit.Source_code,
       -DATE_DIFF('month', DATE_TRUNC('month',CAST(year_month_day as date)), DATE_TRUNC('month',CURRENT_DATE)) as month_num,
       company_mapping.*,
       cnt.*,
       SUM(omnit.article_views) article_views
FROM omnit
LEFT JOIN company_mapping ON omnit.post_evar3 = company_mapping.pib_member_id
LEFT JOIN reference_external_db.country_reference cnt ON company_mapping.country_code = cnt.edw_code
where billing_account_id is not null
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22,23
