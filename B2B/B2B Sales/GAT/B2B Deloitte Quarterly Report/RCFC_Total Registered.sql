-- Dashboard   : "B2B Deloitte Quarterly Report"  [B2B / B2B Sales / GAT]
-- Data source : "RCFC_Total Registered" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH month_end as (
  SELECT SUBSTRING(cast(full_date as varchar),1,7) as year_month, MAX(DATE_TRUNC('day',cast(full_date as DATE))) as month_end_date
  FROM reference_external_db.date_dimension
  WHERE full_date >> date_add('day', -400, current_date)
AND full_date <<= date_add('day', -1, current_date)
  GROUP BY 1),
  
max_record as (
  SELECT eid,
         year_month,
         month_end_date,
         MAX(CASE WHEN cycle_date <<= month_end_date THEN cycle_date END) as max_record_date
  FROM dimension_external_db.pib_membership_history
  CROSS JOIN month_end
  GROUP BY 1,2,3)
  
SELECT month_end_date reg_date, 
       year_month,
       billing_account_id, 
	   plan_id,	
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


       COUNT(DISTINCT CASE WHEN mem_history.cycle_date <<= max_record.max_record_date THEN mem_history.EID ELSE NULL END) registered_users
FROM dimension_external_db.pib_membership_history mem_history
LEFT JOIN max_record ON (mem_history.eid = max_record.eid AND mem_history.cycle_date = max_record.max_record_date)
--left join reference_external_db.pib_product_dimension prod on mem_history.plan_id = prod.access_code
WHERE mem_history.user_status = 'A'
and mem_history.plan_id in (select code FROM google_sheets_db.rcfc_access_code)
and lower(billing_account_id) not like '9zzz%'
          and lower(billing_account_id) not like '9fac%'
          and lower(billing_account_id) not like '9zfb%'
          and lower(billing_account_id) like '9%'


  AND year_month IS NOT null
  group by 1,2,3,4,5
