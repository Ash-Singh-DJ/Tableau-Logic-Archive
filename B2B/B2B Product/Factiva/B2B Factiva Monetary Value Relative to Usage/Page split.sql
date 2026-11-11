-- Dashboard   : "B2B Factiva  Monetary Value Relative to Usage"  [B2B / B2B Product / Factiva]
-- Data source : "Page split" (embedded in the workbook)
-- Relation    : Custom SQL "Page Views"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with Omnit as

(select substring(cast(cycle_date as varchar),1,7) year_month, post_evar3, 'Factiva' as platform, post_pagename, page_lag, post_campaign, post_prop60, post_prop10, post_prop39, post_prop3, post_prop6, post_evar4,
post_prop40, post_evar38, post_prop53, null as ti_td_page_section,
      
  SUM(CASE WHEN lower(post_pagename) NOT LIKE '%login%' AND CAST(post_page_event AS varchar) = '0' AND (CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS varchar) NOT IN ('5',  '8',  '9')) THEN 1 ELSE 0 END) Page_Views
              

from 
(

select cycle_date, date_time, post_evar3, post_evar4, post_prop3, post_prop6, post_prop39, post_campaign, reporting_suite, post_page_event, exclude_hit, hit_source, post_prop10, post_prop53, post_prop40, post_prop60, post_evar38, post_pagename, 
lag(post_pagename ,1) over(PARTITION BY post_evar3 order by date_time) as page_lag
FROM fact_external_db.omniture_event_fact
WHERE reporting_suite = 'djfactiva'
and cycle_date >>= cast('2025-01-01' as date)
AND cycle_date <<= cast('2026-01-31' as date)
AND (cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9')))
and lower(post_pagename) NOT LIKE '%login%')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16

union all 

select substring(cast(cycle_date as varchar),1,7) year_month, user_info_user_ref as post_evar3, 'New Factiva' as platform, null as post_pagename, null as page_lag, null as post_campaign, null as post_prop60, 
null as post_prop10, null as post_prop39, null as post_prop3, null as post_prop6, null as post_evar4,
null as post_prop40, null as post_evar38, null as post_prop53, ti_td_page_section, 
sum(case when event_name = 'page_view' then 1 else 0 end) as Page_Views
from pib_event_data.pib_product_metrics djm
where product = 'New Factiva'
and cycle_date >>= cast('2025-01-01' as date)
AND cycle_date <<= cast('2026-01-31' as date)
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
having sum(case when event_name = 'page_view' then 1 else 0 end) >> 0 


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
  SELECT pib_member_id, country_code, plan_id, user_id, billing_account_id, first_name, last_name, user_status
  FROM dimension_external_db.pib_membership_dimension
  GROUP BY pib_member_id, country_code, plan_id, user_id, billing_account_id, first_name, last_name, user_status),

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
FROM dimension_external_db.pib_territory_dimension),

jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')



select 
		

mem_dim.pib_member_id, mem_dim.user_id, mem_dim.first_name, mem_dim.last_name, mem_dim.user_status, mem_dim.plan_id,
 jf.department_code, mem_dim.billing_account_id, pd.master_product,	   
Comp.company_name, 
Comp.company_sfdc_id,
	 
	   Comp.company_industry, 

         Terr.territory_name,
	   td.region_code,
	   mk.geo_region,
           omnit.year_month,
	   omnit.post_pagename,
	   omnit.page_lag,
	   omnit.post_campaign, 
	   omnit.post_prop40, 
	   omnit.post_prop60,
             omnit.post_prop10,
omnit.post_prop39,
omnit.post_prop3,
omnit.post_evar38,
omnit.post_prop6,
omnit.post_evar4,
omnit.post_prop53,
omnit.platform,
omnit.ti_td_page_section,
	   SUM(Omnit.Page_Views) total_page_views
	 


FROM Omnit
inner JOIN mem_dim ON mem_dim.pib_member_id = Omnit.post_evar3
LEFT JOIN Bill_Acct_Dim ON mem_dim.billing_account_id = Bill_Acct_Dim.cibs_billing_account_id
LEFT JOIN Comp on Bill_Acct_Dim.salesforce_company_two  = Comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_territory_dimension td ON Comp.company_territory = td.territory_sfdc_id
LEFT JOIN product_master ON mem_dim.plan_id = product_master.access_code
LEFT JOIN Terr ON Comp.company_territory = Terr.territory_sfdc_id
left join sandbox_mk.geo_region_rollup mk on Terr.territory_name = mk.sales_territory
left join jf on mem_dim.pib_member_id = jf.pib_member_id
left join reference_external_db.pib_product_dimension pd on mem_dim.plan_id = pd.access_code

--where company_name = 'Teneo Strategy LLC'
where not (mem_dim.plan_id = '0086' or mem_dim.plan_id = '0087') AND Terr.territory_name <<>> 'Proquest'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30
