-- Dashboard   : "R&C ONLY Customers"  [B2B / B2B Product / R&C]
-- Data source : "DJM" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with Mem as (
	SELECT first_name, last_name, pib_member_id, city User_city, user_id, email,
		   billing_account_id, plan_id, user_status, company_name, web_registration_date
	FROM dimension_external_db.pib_membership_dimension
	where plan_id in (
	'0611','0614','0598','0599','0644','0610','0613','0616','0641','0642','0643','0609','0607','0608','0455',
	'0456','0601','0603','0604','0517','0518','0555','0556','0569','0570','0602','0605','0606','0491','0492',
	'0497','0498','0493','0494','0618','0647','0650','0658','0651','0659','0652','0660','0653','0661','0654',
	'0662','0499','0500','0537','0538','0495','0496','0648','0649','0655','0663','0656','0664','0657','0665',
	'0600','0617','0701','0704','0705','0711','0712','0713','0714','0715','0716','0717','0718','0719','0725',
	'0726','0727','0728','0620','0634','0635','0636','0637','0638','0639','0640','0645','0671','0672','0685',
	'0686','0687','0688','0677','0678','0679','0684','0557','0558','0559','0560','0561','0562','0568','0597',
	'4212','0621','0631','0632','0624','0625','0626','0627','0628','0629','0591','0592','0571','0573','0574',
	'0575','0572','0576','0577','0578','0579','0580','0581','0582','0583','0584','0585','0586','0587','0588',
	'2040','2041','2042','2043','2845','2820','0487','0488','0489','0490','0482','0483','0475','0593','0594',
	'0595','0208','0209','2000','2001','2002','2003','2004','2005','2006','2007','2008','2009','2010','2011',
	'2012','2013','2014','2015','2016','2017','2018','2019','2020','2021','2022','2023','2024','2025','2026',
	'2027','2028','2029','2030','2031','2500','2501','0453','0542','0543','0544','0589','0590'
	
	/*
	'0008','0207','0418','0460','0463','0475','0482','0483','0487','0522','0544','0612','0615','0619','0623',
	'0674','0680','0681','2000','2001','2002','2003','2004','2005','2007','2008','2013','2015','2025','2026',
	'2027','2032','2033','2034','2035','2044','2502','2600','3000','3015','4500','5029','7950','8230','8231',
	'8239','8407','8409'
    */
	 )),

bad AS (
	SELECT product_access_code, cibs_billing_account_id, company_name AS bad_company_name, country, 
		   city, state, salesforce_business_unit, salesforce_status, account_type, subscription_date,
		   service_provided, salesforce_type, industry,salesforce_salesperson, max_contracted_users_allowed, 
		   salesforce_max_sessions, salesforce_contracted_users, salesforce_billing_start_date, 
		   salesforce_billing_type, account_sales_territory, salesforce_current_month_exit_rate,
		   salesforce_company_two
	FROM dimension_external_db.pib_billing_account_dimension 
),

cd AS (SELECT company_sfdc_id, company_name Company FROM dimension_external_db.pib_company_dimension),

pcode as (
select access_code, master_product 
from reference_external_db.pib_product_dimension
where access_code is not null
group by 1,2
),


LastLogin AS (
select pib_member_id, max(last_login_RC) last_login_RC from 	
(SELECT 
		user_info_user_ref as pib_member_id, 
		max(cycle_date) AS last_login_RC 
	FROM pib_event_data.pib_product_metrics 
	WHERE cycle_date >>= DATE('2021-11-01')
		AND product IN ('Financial Crime', 'RiskCenter','Trade Compliance')
		AND (event_name IS NOT NULL OR "action" IS NOT NULL OR ti_td_event_name IS NOT NULL OR ti_td_action IS NOT NULL)
	GROUP BY 1 
	union all
	SELECT 
		post_evar3 as pib_member_id, 
		max(cycle_date) AS last_login_RC 
	FROM fact_external_db.omniture_event_fact
	WHERE reporting_suite = 'djriskcomplianceprod'
    and lower(post_pagename) NOT LIKE '%login%'
--     and cycle_date >>= date('2021-11-01')
--	  and cycle_date <<= DATE_ADD('day', -1, date_trunc('month', CURRENT_DATE))
	GROUP BY 1 
	)
group by 1
	)

select mem.*, cd.company, bad.country,LastLogin.last_login_RC, pcode.master_product
FROM mem
LEFT JOIN pcode on pcode.access_code = mem.plan_id
LEFT JOIN bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN cd  on bad.salesforce_company_two = cd.company_sfdc_id
LEFT JOIN LastLogin ON mem.pib_member_id = LastLogin.pib_member_id
