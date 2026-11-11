-- Dashboard   : "Factiva Homepage Modules"  [B2B / B2B Sales / Product Usage]
-- Data source : "Admin" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with

dat as 

(select substring(cast(full_date as varchar),1,10) as full_date, substring(cast(week_start_date as varchar),1,10) as wsd,  week_number_in_fiscal_year as fw,
day_of_week as dow
from  reference_external_db.date_dimension 
where full_date >> date_add('day', -1200, current_date)
),

jf as 

(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')


SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) as year_month_day, dat.wsd, 
SUBSTRING(CAST(cycle_date AS varchar), 1, 7) as year_month,
ti_td_page_subsection, ti_td_page_section,
 mem.pib_member_id, mem.user_id, comp.company_name, comp.company_industry, jf.department_code,

SUM(CASE when event_name in ('page_view', 'user_action') THEN 1 ELSE 0 END) admin_views

     from pib_event_data.pib_product_metrics djm    
JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join dat on SUBSTRING(CAST(djm.cycle_date AS varchar), 1, 10) = dat.full_date
left join jf on mem.pib_member_id = jf.pib_member_id
WHERE product = 'Factiva'
and ti_td_page_section = 'Administrator'
and mem.billing_account_id not like '9ZZZ%'
and mem.billing_account_id not like '9ZFB%'
and mem.billing_account_id <<>> '9DOW003600'
and mem.billing_account_id <<>> '9DOW007100'
and mem.billing_account_id <<>> '9FAC067700'
and event_name in ('page_view', 'user_action')

AND cycle_date >>= cast('2025-09-01' as date)

GROUP BY 1,2,3,4,5,6,7,8,9,10
