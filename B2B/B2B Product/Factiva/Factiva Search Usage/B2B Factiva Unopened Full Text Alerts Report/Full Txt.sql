-- Dashboard   : "B2B Factiva Unopened Full Text Alerts Report"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Full Txt" = published source "B2B Unopened Full Text Alerts Report - Data Source"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select year_month_day, alertid, senderuserid, folder_name, producttype, jobtypedescription, display_format, emaildisplayformat, event, 
count(distinct case when event = 'Open' then jobid end) unique_job_id_open,
count(distinct case when event = 'Delivery' then jobid end) unique_job_id_delivery

from (

select 
substring(eventdatetime,1,10) year_month_day,
op.alerttype,
op.producttype,
op.jobtype,
op.deliveryaddress,
op.jobtypedescription,
op.senderuserid,
op.jobid,
op.event,
op.ipaddress,
op.emaildisplayformat, 
op.alertid,
substring(nlcontent, strpos(nlcontent,'&nlid')+6, (strpos(nlcontent,'&inle') - strpos(nlcontent,'&nlid') - 6 )) as nlid,
al.email_address,
al.delivery_type,
al.display_format,
al.folder_name,
bill.cibs_billing_account_id,
comp.company_name,
comp.company_sfdc_id


from pib.email_open_rates op
left join dimension_external_db.pib_alerts al on (op.senderuserid = al.user_id and op.alertid = al.folder_id and op.cycle_date = al.cycle_date)
left join dimension_external_db.pib_membership_dimension mem on op.senderuserid = mem.user_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id  
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 

where cast(substring(op.eventdatetime,1,10) as date) >> cast('2024-02-01' as date)
and display_format like 'FullText%'
and mem.billing_account_id not like '9ZZZ%'
and mem.billing_account_id not like '9ZFB%'
and mem.billing_account_id <<>> '9DOW003600'
and mem.billing_account_id <<>> '9DOW007100'
and mem.billing_account_id  <<>> '9FAC067700'
and jobtype in ('FSP','RAD','SBD','SDD', 'SID', 'SRE', 'TMH')
and event in ('Open', 'Delivery')
and op.emaildisplayformat = 'HTML'
--and op.senderuserid = 'E000440076'



)
group by 1,2,3,4,5,6,7,8,9
