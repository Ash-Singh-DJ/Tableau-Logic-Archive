-- Dashboard   : "True North: Factiva"  [B2B / B2B Product]
-- Data source : "Job Function Pie" (embedded in the workbook)
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


o as 
(select user_info_user_ref EID, 
           count(distinct case WHEN djm.event_name = 'page_view' or djm.event_name = 'user_action' THEN cycle_date end) as total_active_days
                from pib_event_data.pib_product_metrics djm
                JOIN dimension_external_db.pib_membership_dimension mem ON djm.user_info_user_ref = mem.eid
                where product in ('New Factiva','Factiva')
                AND cycle_date >>= cast('2022-01-01' as date)
                and user_info_account_id not like '9ZZZ%' 
                and user_info_account_id not like '9ZFB%'
                and user_info_account_id not like '9FAC%'
                and (djm.event_name = 'page_view' or djm.event_name = 'user_action') 
                group by 1),
                
jf as (
select pib_member_id, department_code, 
case when (department_code = 'OT' and job_function_code_last_updated_at is not null)
then 'Don''t show Me Again'
when (department_code <<>> 'OT' and job_function_code_last_updated_at is not null)
then 'Yes, job function verified' 
else 'Dismissed' end as jf
from dimension_external_db.pib_membership_dimension 
group by 1,2,3)



select  substring(cast(cycle_date as varchar),1,10) as year_month_day, substring(cast(cycle_date as varchar),1,7) as year_month, wk.week_start, 
user_info_user_ref EID, mem.web_registration_date, o.total_active_days, jf.department_code, jf.jf,
           count(distinct case WHEN djm.event_name = 'page_view' or djm.event_name = 'user_action' THEN cycle_date end) as active_days
                from pib_event_data.pib_product_metrics djm
                JOIN dimension_external_db.pib_membership_dimension mem ON djm.user_info_user_ref = mem.eid
                left join o on mem.pib_member_id = o.EID
                left join jf on mem.pib_member_id = jf.pib_member_id
                left join wk on substring(cast(djm.cycle_date as varchar),1,10) = wk.year_month_day
                where product in ('New Factiva','Factiva')
                AND cycle_date >>= date_add('day', -182, current_date)
                and user_info_account_id not like '9ZZZ%' 
                and user_info_account_id not like '9ZFB%'
                and user_info_account_id not like '9FAC%'
       
                and (djm.event_name = 'page_view' or djm.event_name = 'user_action') 
                group by 1,2,3,4,5,6,7,8
