-- Dashboard   : "True North: Factiva"  [B2B / B2B Product]
-- Data source : "DAU WAU Trend" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with wk as
(select substring(cast(full_date as varchar),1,10) year_month_day, substring(cast(week_start_date as varchar),1,10) week_start,
fiscal_quarter_name as fq, day_of_week as dow

from reference_external_db.date_dimension
where substring(cast(full_date as varchar),1,10) >>= cast('2021-01-01' as varchar)
order by full_date),

jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')


SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, wk.dow,  wk.week_start, wk.fq, 
mem.pib_member_id, jf.department_code,   mem.billing_account_id, mem.plan_id, comp.company_industry,
comp.company_name, product as platform, ti_td_page_content_platform_presentation as device, 
sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) desktop_page_views
   
      from pib_event_data.pib_product_metrics omni


join dimension_external_db.pib_membership_dimension mem on omni.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
LEFT JOIN wk on substring(cast(omni.cycle_date as varchar),1,10) = wk.year_month_day
left join jf on mem.pib_member_id = jf.pib_member_id
where product in ('New Factiva', 'Factiva')
AND cycle_date >>= cast('2024-01-01' as date)
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12
having sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) >> 0
