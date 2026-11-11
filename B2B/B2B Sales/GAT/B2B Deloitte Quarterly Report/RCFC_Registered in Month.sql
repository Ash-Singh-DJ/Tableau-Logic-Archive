-- Dashboard   : "B2B Deloitte Quarterly Report"  [B2B / B2B Sales / GAT]
-- Data source : "RCFC_Registered in Month" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(web_registration_date as varchar),1,7) year_month, 
mem.billing_account_id, mem.plan_id, 
(CASE when mem.plan_id in (select code FROM google_sheets_db.rcfc_access_code) then 'rcfc_access' end) as access,

(case when billing_account_id in

(WITH dataset AS ( 
    SELECT * FROM   
        (  select client_name, product, migration_date, split(billing_accounts,',')
     FROM google_sheets_db.saml_master_list_b2b_current
     where product in ('R&C','Risk + Factiva','R&C + Factiva','RiskCenter','Financial Crime')

 ) AS t (client_name, product, migration_date, metrics_array))

select metric as saml_billing_account
from dataset
cross join unnest(metrics_array) as t(metric))
then 'saml_billing_account' end) as saml,


count(distinct EID) reg_in_month 

from dimension_external_db.pib_membership_dimension mem
--and user_status = 'A'
where web_registration_date >>= cast('2021-11-01' as date)
and mem.plan_id in (select code FROM google_sheets_db.rcfc_access_code)
and mem.billing_account_id like '9%' 
group by 1,2,3,4,5
order by substring(cast(web_registration_date as varchar),1,7)
