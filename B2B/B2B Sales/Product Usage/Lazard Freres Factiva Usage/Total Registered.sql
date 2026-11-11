-- Dashboard   : "Lazard Freres Factiva Usage"  [B2B / B2B Sales / Product Usage]
-- Data source : "Total Registered" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH month_end as (
  SELECT SUBSTRING(cast(full_date as varchar),1,7) as year_month, MAX(DATE_TRUNC('day',cast(full_date as DATE))) as month_end_date
  FROM reference_external_db.date_dimension
  WHERE full_date >> date_add('day', -800, current_date)
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

       comp.company_name,

       COUNT(DISTINCT CASE WHEN mem_history.cycle_date <<= max_record.max_record_date THEN mem_history.EID ELSE NULL END) registered_users
FROM dimension_external_db.pib_membership_history mem_history
LEFT JOIN max_record ON (mem_history.eid = max_record.eid AND mem_history.cycle_date = max_record.max_record_date)
left join reference_external_db.pib_product_dimension prod on mem_history.plan_id = prod.access_code
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on mem_history.billing_account_id = bad.cibs_billing_account_id
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
WHERE mem_history.user_status = 'A'
and comp.company_name = 'LAZARD FRERES SAS'


  AND year_month IS NOT null
  group by 1,2,3
