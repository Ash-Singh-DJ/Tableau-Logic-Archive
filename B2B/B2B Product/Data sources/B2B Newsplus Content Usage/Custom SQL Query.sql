-- Published data source : "B2B Newsplus Content Usage"  [B2B / B2B Product / Data sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT 
	   ti_td_page_content_source,
	 --  ti_td_page_content_type_detail,
	  ti_td_article_headline,
	  cycle_date,
	  pmd.billing_account_id,
	  comp.company_name,
          pmd.user_id,
          date_time,
	   sum(CASE WHEN event_name = 'page_view' AND ti_td_page_content_type = 'Article' THEN 1 ELSE 0 END) ARTICLE_VIEWS

	   
FROM pib_event_data.pib_product_metrics ppm
LEFT JOIN dimension_external_db.pib_membership_dimension pmd ON pmd.pib_member_id = ppm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON pmd.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
WHERE ppm.product = 'NewsPlus'
AND cycle_date >>= date('2022-02-01')
--and ti_td_article_headline like '%Barron%'
GROUP BY 1,2,3,4,5,6,7
ORDER BY article_views desc
