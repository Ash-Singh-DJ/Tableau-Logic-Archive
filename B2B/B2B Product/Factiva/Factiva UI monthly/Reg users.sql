-- Dashboard   : "Factiva UI monthly"  [B2B / B2B Product / Factiva]
-- Data source : "Reg users" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select cibs_billing_account_id, company_name, company_sfdc_id, plan_id, product_line, salesforce_access_description,

count(*) as reg_users from (

select pib_member_id, bad.cibs_billing_account_id, bad.salesforce_access_description, 
comp.company_name, comp.company_sfdc_id, mem.plan_id, pr.product_line from 
dimension_external_db.pib_membership_dimension mem 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
left join reference_external_db.pib_product_dimension pr on mem.plan_id = pr.access_code 
where user_status = 'A'
and bad.cibs_billing_account_id like '9%'
and lower(salesforce_access_description) not like '%oxford%'
and lower(salesforce_access_description) not like '%dragonfly%'
and mem.plan_id <<>> '0086'
and mem.plan_id <<>> '0087'
and mem.billing_account_id not like '9ZZZ%'
and mem.billing_account_id not like '9ZFB%'
and mem.billing_account_id <<>> '9DOW003600'
and mem.billing_account_id <<>> '9DOW007100'
and mem.billing_account_id <<>> '9FAC067700')
group by 1,2,3,4,5,6
