-- Dashboard   : "B2B  Factiva Compliance Model Dashboard"  [B2B / B2B Product / Factiva / Factiva 1P & User Segmentation]
-- Data source : "Custom SQL Query+ (dimension_external_db)" = published source "B2B Factiva Compliance Model Dashboard - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Company Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH recurring_tm AS (
  SELECT comp.company_sfdc_id,
         SUM(CASE WHEN (lower(pm.product_line) LIKE '%factiva%'
				OR lower(pm.product_line) LIKE '%djx%'
				OR lower(pm.product_line) LIKE '%my company today%'
				OR lower(pm.product_line) LIKE '%dna%') THEN exit_rate*12 ELSE 0 END) factiva_djx_annualized_rev,
		 SUM(CASE WHEN pm.bu = 'R&C' THEN exit_rate*12 ELSE 0 END) rnc_annualized_rev,
		 SUM(CASE WHEN pm.bu = 'NAD' THEN exit_rate*12 ELSE 0 END) nad_annualized_rev
  FROM fact_external_db.tm1_fact tm1
  LEFT JOIN reference_external_db.pib_product_dimension pm ON tm1.product = pm.tm1_product
  LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON tm1.billing_account_number = bad.cibs_billing_account_id 
  LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id 
  WHERE billing_date = (SELECT MAX(billing_date) FROM fact_external_db.tm1_fact)
  GROUP BY comp.company_sfdc_id
),
  
one_time_tm AS (
	SELECT comp.company_sfdc_id,
		   SUM(CASE WHEN (lower(pm.product_line) LIKE '%factiva%'
				OR lower(pm.product_line) LIKE '%djx%'
				OR lower(pm.product_line) LIKE '%my company today%'
				OR lower(pm.product_line) LIKE '%dna%') THEN total_non_recurring_revenue ELSE 0 END) factiva_djx_non_recurring_rev_last12months,
		   SUM(CASE WHEN pm.bu = 'R&C' THEN total_non_recurring_revenue ELSE 0 END) rnc_non_recurring_rev_last12months,
		   SUM(CASE WHEN pm.bu = 'NAD' THEN total_non_recurring_revenue ELSE 0 END) nad_non_recurring_rev_last12months
	FROM fact_external_db.tm1_fact tm1
	LEFT JOIN reference_external_db.pib_product_dimension pm ON tm1.product = pm.tm1_product
	LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON tm1.billing_account_number = bad.cibs_billing_account_id 
	LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id 
	WHERE (lower(pm.product_line) LIKE '%factiva%'
		OR lower(pm.product_line) LIKE '%djx%'
		OR lower(pm.product_line) LIKE '%my company today%')
	  AND billing_date >>= DATE_TRUNC('month', DATE_ADD('month', -12, (SELECT MAX(billing_date) FROM fact_external_db.tm1_fact)))
	  AND billing_date <<= (SELECT MAX(billing_date) FROM fact_external_db.tm1_fact)
	GROUP BY comp.company_sfdc_id
),

company_info AS (
	SELECT comp.company_sfdc_id, comp.company_name, corp.corporate_sfdc_id, corp.corporate_name, comp.company_city, comp.company_country, 
		   comp.company_industry, comp.company_state, comp.company_street, comp.company_postal_code, comp.company_website, 
		   COALESCE(COALESCE(comp.factiva__fcode, comp.fcode_propagated), comp.factiva_f_code) factiva_code, comp.duns,
		   corp.corporate_city, corp.corporate_country, 
		   comp.company_status, comp.company_annual_revenue, comp.company_number_of_employees,
		   comp.global_top_company, comp.lattice_revenue_range, comp.lattice_line_of_business, comp.lattice_secondary_industry, 
		   comp.lattice_employee_range, comp.lattice_us_1987_sic_1, 
		   td.territory_roll_up, td.territory_name, td.region_code,
		   ud.user_full_name AS sales_person, rsdud.user_full_name AS RSD, 
		   COALESCE(recurring_tm.factiva_djx_annualized_rev, 0) AS factiva_djx_recurring_annualized_rev, 
		   COALESCE(one_time_tm.factiva_djx_non_recurring_rev_last12months, 0) AS factiva_djx_non_recurring_rev_last12months,
		   COALESCE(recurring_tm.rnc_annualized_rev, 0) AS rnc_recurring_annualized_rev, 
		   COALESCE(one_time_tm.rnc_non_recurring_rev_last12months, 0) AS rnc_non_recurring_rev_last12months,
		   COALESCE(recurring_tm.nad_annualized_rev, 0) AS nad_recurring_annualized_rev,
		   COALESCE(one_time_tm.nad_non_recurring_rev_last12months, 0) AS nad_non_recurring_rev_last12months
	FROM dimension_external_db.pib_company_dimension comp
	LEFT JOIN (SELECT * FROM dimension_external_db.pib_corporate_dimension WHERE status_flag <<>> 'DELETE') corp ON comp.parent_sfdc_id = corp.corporate_sfdc_id 
	LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') td ON comp.company_territory = td.territory_sfdc_id 
	LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') ud ON td.territory_owner = ud.user_sfdc_id
	LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') rsdud ON td.regional_sales_director = rsdud.user_sfdc_id
	LEFT JOIN recurring_tm ON comp.company_sfdc_id = recurring_tm.company_sfdc_id
	LEFT JOIN one_time_tm ON comp.company_sfdc_id = one_time_tm.company_sfdc_id
	WHERE comp.status_flag <<>> 'DELETE'),

company_info_appended AS (
	SELECT *,
		   CASE WHEN factiva_djx_recurring_annualized_rev >> 100 OR factiva_djx_non_recurring_rev_last12months >> 100
		   		THEN TRUE ELSE FALSE END current_factiva_customer_flag,
		   CASE WHEN rnc_recurring_annualized_rev >> 100 OR rnc_non_recurring_rev_last12months >> 100
		   		THEN TRUE ELSE FALSE END current_rnc_customer_flag,
		   CASE WHEN nad_recurring_annualized_rev >> 100 OR nad_non_recurring_rev_last12months >> 100
		   		THEN TRUE ELSE FALSE END current_nad_customer_flag
	FROM company_info)
	
SELECT *
FROM company_info_appended
WHERE current_factiva_customer_flag
