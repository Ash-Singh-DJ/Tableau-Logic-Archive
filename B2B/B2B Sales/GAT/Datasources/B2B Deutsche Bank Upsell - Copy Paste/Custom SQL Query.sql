-- Published data source : "B2B Deutsche Bank Upsell - Copy Paste"  [B2B / B2B Sales / GAT / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH omnit AS (
	SELECT 
		substring(CAST(date_time AS varchar), 1, 10) year_month_date,
		post_evar3,
		sum(CAST(substring(post_event_list, strpos(post_event_list, '240=')+4, strpos(post_event_list, '.00')-9) as integer)) total_copy_chars,
		count(CAST(substring(post_event_list, strpos(post_event_list, '240=')+4, strpos(post_event_list, '.00')-9) as integer)) total_copy_instances,
		sum(CAST(substring(post_event_list, strpos(post_event_list, '240=')+4, strpos(post_event_list, '.00')-9) as integer)) / count(cast(substring(post_event_list, strpos(post_event_list, '240=')+4, strpos(post_event_list, '.00')-9) as integer)) avg_chars_copy,
		(sum(CAST(substring(post_event_list, strpos(post_event_list, '240=')+4, strpos(post_event_list, '.00')-9) as integer)) / count(cast(substring(post_event_list, strpos(post_event_list, '240=')+4, strpos(post_event_list, '.00')-9) as integer)) / 5) avg_words_copy 
	FROM fact_external_db.omniture_event_fact  
	WHERE reporting_suite = 'djfactiva' 
		AND cycle_date >>= DATE_ADD('day', -400, current_date) 
		AND post_event_list LIKE '%240=%' 
		AND CAST(exclude_hit AS integer) <<= 0 
		AND CAST(hit_source AS varchar) NOT IN ('5', '8', '9') 
	GROUP BY 1,2 
), 

mem_dim AS (
	SELECT pib_member_id, user_id, eid, first_name, last_name, plan_id, billing_account_id 
	FROM dimension_external_db.pib_membership_dimension 
    WHERE billing_account_id in ('9DEU001700','9DEU005300','9DEU004800','9DEU001500','9DEU008900',
'9DEU004000','9DEU006000','9DEU011300','9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
and user_status = 'A'
GROUP BY 1, 2, 3, 4, 5, 6, 7
),  

product_master AS (
	SELECT access_code, master_product 
	FROM reference_external_db.pib_product_dimension
	GROUP BY 1, 2
),  

Territory_Dim AS (
	SELECT territory_sfdc_id, territory_name, territory_roll_up, territory_owner, regional_sales_director 
	FROM dimension_external_db.pib_territory_dimension 
	WHERE territory_status = 'Active' AND status_flag <<>> 'DELETE' 
	GROUP BY 1, 2, 3, 4, 5
), 

Territory_Dim2 AS (
	SELECT territory_sfdc_id, territory_name, territory_roll_up, territory_owner 
	FROM dimension_external_db.pib_territory_dimension 
	WHERE territory_status = 'Active' AND status_flag <<>> 'DELETE' 
	GROUP BY 1, 2, 3, 4
),  

Salesperson_Dim AS (
	SELECT user_sfdc_id, user_full_name 
	FROM dimension_external_db.pib_user_dimension 
	WHERE status_flag <<>> 'DELETE' 
	GROUP BY 1, 2
), 

Comp AS (
	SELECT company_name, company_sfdc_id, company_territory 
	FROM dimension_external_db.pib_company_dimension 
	WHERE status_flag <<>> 'DELETE' 
), 

Bill_Acct_Dim AS (
	SELECT cibs_billing_account_id, salesforce_max_sessions, account_sales_territory, salesforce_territory_owner, salesforce_company_two 
	FROM dimension_external_db.pib_billing_account_dimension 
	  where cibs_billing_account_id in ('9DEU001700','9DEU005300','9DEU004800','9DEU001500','9DEU008900',
'9DEU004000','9DEU006000','9DEU011300','9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
  GROUP BY 1, 2, 3, 4, 5
)    

SELECT 
	mem_dim.pib_member_id, 
	mem_dim.user_id, 
	mem_dim.eid, 
    mem_dim.first_name,
    mem_dim.last_name,
	mem_dim.plan_id, 
	mem_dim.billing_account_id, 
	Territory_Dim.territory_name, 
	Territory_Dim.territory_roll_up, 
	Salesperson_Dim.user_full_name, 
	Bill_Acct_Dim.account_sales_territory, 
	replace(Bill_Acct_Dim.salesforce_territory_owner, '  ', ' ') AS account_owner, 
	Territory_Dim2.territory_name AS account_territory_name, 
	Territory_Dim2.territory_roll_up AS account_territory_roll_up, 
	Comp.company_name, 
	product_master.master_product, 
	date(omnit.year_month_date) AS year_month_date, 
	sum(omnit.total_copy_chars) AS total_copy_chars, 
	sum(omnit.total_copy_instances) AS total_copy_instances, 
	avg(omnit.avg_chars_copy) AS avg_chars_copy, 
	avg(omnit.avg_words_copy) AS avg_words_copy 
FROM omnit 
LEFT JOIN mem_dim ON omnit.post_evar3 = mem_dim.eid 
LEFT JOIN Bill_Acct_Dim ON Bill_Acct_Dim.cibs_billing_account_id = mem_dim.billing_account_id 
LEFT JOIN product_master ON mem_dim.plan_id = product_master.access_code 
LEFT JOIN Comp ON Bill_Acct_Dim.salesforce_company_two = Comp.company_sfdc_id 
LEFT JOIN Territory_Dim ON Comp.company_territory = Territory_Dim.territory_sfdc_id 
LEFT JOIN Salesperson_Dim ON Territory_Dim.territory_owner = Salesperson_Dim.user_sfdc_id 
LEFT JOIN Territory_Dim2 ON Bill_Acct_Dim.account_sales_territory = Territory_Dim2.territory_name   
WHERE total_copy_instances >> 49 AND avg_chars_copy >>= 150 
and LOWER(billing_account_id) LIKE '9deu%' 
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17 
--ORDER BY total_copy_instances DESC, year_month_date
