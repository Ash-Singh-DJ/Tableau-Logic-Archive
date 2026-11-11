-- Published data source : "B2B Metadata code"  [B2B / B2B Product / Newswires / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT pmd.user_id as USER_ID,
	   pmd.first_name as FIRST_NAME,
	   pmd.last_name as LAST_NAME,
	   pmd.email as EMAIL,
	   pmd.billing_account_id as ACCOUNT_ID,
	   cycle_date as Cycle_Date,
	   date_time as Date_Time,
	   comp.company_sfdc_id as Company_ID,
	   comp.company_name as Company_Name,
	   ti_td_article_ID as Article_ID,
	   REGEXP_EXTRACT(ti_td_page_url, 'https?://[^/]+\.com') AS URL_Base,
	  -- ti_td_article_code_set,
  	   case when value like '[%'  then replace(value,'[','') 
  	   		when value like '%]'  then replace(value,']','') 
  	   		else value end as Code
	                    	             
FROM pib_event_data.pib_product_metrics ppm
CROSS JOIN UNNEST(split(ti_td_article_code_set, ',')) as x(value)
LEFT JOIN dimension_external_db.pib_membership_dimension pmd ON pmd.pib_member_id = ppm.user_info_user_ref
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON pmd.billing_account_id = bad.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
WHERE ppm.product = 'NewsPlus'
AND cycle_date >>= date('2022-02-01')
and ti_td_article_code_set != 'Null'
order by date_time desc
