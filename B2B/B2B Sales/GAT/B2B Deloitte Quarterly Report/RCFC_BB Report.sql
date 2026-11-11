-- Dashboard   : "B2B Deloitte Quarterly Report"  [B2B / B2B Sales / GAT]
-- Data source : "RCFC_BB Report" (embedded in the workbook)
-- Relation    : Custom SQL "Active Days"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 

rcfc_metrics as
(SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, 
mem.pib_member_id, mem.billing_account_id, mem.plan_id, 'rcfc_access' as access,
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

comp.company_name, 'RCFC' as platform, ti_td_page_content_platform_presentation as device, 
sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) desktop_page_views
   
      from pib_event_data.pib_product_metrics omni


join dimension_external_db.pib_membership_dimension mem on omni.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 

where mem.plan_id in (select code FROM google_sheets_db.rcfc_access_code)
AND cycle_date >> date_add('day', -800, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
GROUP BY 1,2,3,4,5,6,7,8,9
having sum(case when event_name = 'page_view' or event_name = 'user_action' THEN 1 ELSE 0 END) >> 0),

rcfc_omni as (
SELECT SUBSTRING(CAST(cycle_date AS varchar), 1, 10) year_month_day, 
mem.pib_member_id, mem.billing_account_id, mem.plan_id, 'rcfc_access' as access,
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
comp.company_name, 'RCFC' as platform, (case when mobile_id = 0 THEN 'Desktop' ELSE 'Mobile' end) as device,


SUM(CASE WHEN reporting_suite ='djriskcomplianceprod' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) desktop_page_views
        

FROM fact_external_db.omniture_event_fact omni
join dimension_external_db.pib_membership_dimension mem on omni.post_evar3 = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 

WHERE reporting_suite ='djriskcomplianceprod'
and mem.plan_id in (select code FROM google_sheets_db.rcfc_access_code)
AND cycle_date >> date_add('day', -800, current_date)
AND cycle_date <<= date_add('day', -1, current_date)
GROUP BY 1,2,3,4,5,6,7,8,9
having SUM(CASE WHEN reporting_suite = 'djriskcomplianceprod' AND cast(post_page_event as varchar) = '0' 
          AND (CAST(exclude_hit AS INTEGER) <<= 0 AND cast(hit_source as varchar) NOT IN ('5',  '8',  '9'))  
          AND lower(post_pagename) not like '%login%' THEN 1
        ELSE 0 END) >> 0)

       
select * from rcfc_metrics
union
select * from rcfc_omni
