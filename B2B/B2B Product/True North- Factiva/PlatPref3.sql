-- Dashboard   : "True North: Factiva"  [B2B / B2B Product]
-- Data source : "PlatPref3" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 

wk as
(select substring(cast(full_date as varchar),1,10) year_month_day, substring(cast(week_start_date as varchar),1,10) week_start
from reference_external_db.date_dimension
where substring(cast(full_date as varchar),1,10) >>= cast('2021-01-01' as varchar)
order by full_date),

jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT')



select substring(cast(cycle_date as varchar),1,10) as year_month_day, substring(cast(cycle_date as varchar),1,7) as year_month, wk.week_start, 
user_info_user_ref as EID, bad.cibs_billing_account_id as bill_account, comp.company_name, jf.department_code,
count(distinct case when product = 'Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) as  f_visits,
count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) as nf_visits


from pib_event_data.pib_product_metrics djm
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on djm.user_info_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_membership_dimension mem ON mem.pib_member_id = djm.user_info_user_ref
left join wk on cast(djm.cycle_date as varchar) = wk.year_month_day
left join jf on mem.pib_member_id = jf.pib_member_id 
where product in ('Factiva', 'New Factiva')
and cycle_date >>= cast('2024-01-01' as date)
group by 1,2,3,4,5,6,7
having 
count(distinct case when product = 'Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) >> 0 
or count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) >> 0
