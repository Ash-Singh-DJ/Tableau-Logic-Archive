-- Published data source : "B2B New Factiva Onboarding Metrics - SRE open rates"  [B2B / B2B Product / Factiva / Datasources / B2B New Factiva Onboarding Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select cast(draf.year_month_day as date) ymd,

count(distinct case when event = 'Delivery' then deliveryaddress end) unique_email_delivery,
count(case when event = 'Open' then ipaddress end) unique_ip_opens,
count(distinct case when event = 'Open' then senderuserid end) unique_senderid_opens


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
comp.company_sfdc_id,
ter.territory_name,
us1.user_full_name as territory_owner 

from pib.email_open_rates op
left join dimension_external_db.pib_alerts al on (op.senderuserid = al.user_id and op.alertid = al.folder_id and op.cycle_date = al.cycle_date)
left join dimension_external_db.pib_membership_dimension mem on op.senderuserid = mem.user_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id  
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dimension_external_db.pib_territory_dimension ter on bill.salesforce_territory = ter.territory_sfdc_id 
left join dimension_external_db.pib_user_dimension us1 on ter.territory_owner = us1.user_sfdc_id
where cast(substring(op.eventdatetime,1,10) as date) >> cast('2024-01-01' as date)
and op.producttype = 'sre'
and bill.cibs_billing_account_id not like '9ZZZ%'
and bill.cibs_billing_account_id not like '9ZFB%'
and bill.cibs_billing_account_id <<>> '9DOW003600'
and bill.cibs_billing_account_id <<>> '9DOW007100'
and bill.cibs_billing_account_id  <<>> '9FAC067700'

group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22) draf

group by 1
having count(distinct case when event = 'Delivery' then deliveryaddress end) >> 0
