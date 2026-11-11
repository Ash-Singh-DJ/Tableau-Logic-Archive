-- Published data source : "AHA!"  [B2B / B2B Product]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 

jf as 
(select pib_member_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT'),


aha as (
select created_at, description_body,  
TRIM(substring(description_body, strpos(description_body, 'User ID:')+9, (strpos(description_body, 'Billing Account') -
(strpos(description_body, 'User ID:')+9)))) as user_id,
substring(description_body, strpos(description_body, 'Billing Account:'),30) as billing_account,
substring(description_body, strpos(description_body, 'Please let us know your thoughts')) as comment
from dimension_external_db.aha_ideas_current
where product_id = '6990381404187472124' 
and created_at >>= date('2025-11-15')),

fac as 
(select user_info_user_ref as EID, 
count(distinct case when product = 'Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) as  f_visits,
count(distinct case when product = 'New Factiva' and (event_name = 'page_view' or event_name = 'user_action') then visit_id end) as nf_visits
from pib_event_data.pib_product_metrics djm
where cycle_date >>= date_add('day', -90, current_date)
and product in ('Factiva','New Factiva')
and event_name in ('user_action','page_view')
group by 1
)

select aha.*, mem.pib_member_id, mem.first_name, mem.last_name, mem.email, mem.billing_account_id, comp.company_name, comp.company_industry, 
jf.department_code, fac.f_visits, fac.nf_visits 
from aha
left join dimension_external_db.pib_membership_dimension mem on aha.user_id = mem.user_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join jf on mem.pib_member_id = jf.pib_member_id
left join fac on mem.pib_member_id = fac.EID
