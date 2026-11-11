-- Published data source : "B2B Factiva Compliance Model Dashboard - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "User + Model Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT mem.pib_member_id, mem.email, mem.job_title, mem.plan_id, mem.billing_account_id, comp.company_sfdc_id, 
	   mem.user_id, mem.country_code, mem.user_status,
	   pd.master_product, pd.product_line, pd.bu,
	   model.compliance_expert_searches, model.financial_crime_sources_article_views,
	   model.avg_compliance_expert_searches_per_visit, model.avg_financial_crime_sources_article_views_per_visit,
	   model.searchresults_views, model.desktop_article_views, model.search_article_ratio,
	   model.rnc_visits, model.desktop_page_views, model.distinct_alert_folders, model.compliance_flag,
	   model.predicted_class, model.predicted_0_probability, model.predicted_1_probability,
	   model.predicted_class_40_pct_threshold, model.predicted_class_50_pct_threshold,
	   model.predicted_class_60_pct_threshold
FROM dimension_external_db.pib_membership_dimension mem 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id 
LEFT JOIN reference_external_db.pib_product_dimension pd ON mem.plan_id = pd.access_code 
LEFT JOIN sandbox_mk.compliance_model_results model ON mem.pib_member_id = model.pib_member_id
