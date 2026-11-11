-- Dashboard   : "B2B Deloitte Quarterly Report"  [B2B / B2B Sales / GAT]
-- Data source : "Registered Users Athena " (embedded in the workbook)
-- Relation    : Custom SQL "custom_sql_query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select
comp.company_name, comp.company_industry, mem.plan_id, comp.company_country, pm.master_product, pm.product_line, pm.bu, 
count(distinct mem.pib_member_id) reg_users
from dimension_external_db.pib_membership_dimension mem
LEFT JOIN reference_external_db.pib_product_dimension prod ON mem.plan_id = prod.access_code  
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad ON mem.billing_account_id = bad.cibs_billing_account_id  
LEFT JOIN dimension_external_db.pib_company_dimension comp ON bad.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN reference_external_db.pib_product_dimension pm ON mem.plan_id = pm.access_code
where user_status = 'A'
group by 1,2,3,4,5,6,7
