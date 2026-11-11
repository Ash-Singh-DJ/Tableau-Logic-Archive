-- Published data source : "B2B Factiva Emails: Deliveries and Opens - Newsletters"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select year_month_day, year_month, jobtype, jobtypedescription, senderuserid,  nlid, cibs_billing_account_id, company_name, territory_name, territory_owner, 
count(distinct case when deliveryaddress <<>> '' then deliveryaddress end) as unique_email,   sum(total_email_delivery) as total_email_delivery, sum(ip_opens) as ip_opens, sum(unique_ip_opens) as unique_ip_opens
from 


(select draf.year_month_day, draf.year_month, jobtype, jobtypedescription, senderuserid, deliveryaddress, nlid,  cibs_billing_account_id, company_name, territory_name, territory_owner,

count(distinct case when event = 'Delivery' and deliveryaddress <<>> '' then jobid end) total_email_delivery,
count(case when event = 'Open' then ipaddress end) ip_opens,
count(distinct case when event = 'Open' then ipaddress end) unique_ip_opens


from (

select 
substring(eventdatetime,1,10) year_month_day,
substring(eventdatetime,1,7) year_month,
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
bill.cibs_billing_account_id,
comp.company_name,
comp.company_sfdc_id,
ter.territory_name,
us1.user_full_name as territory_owner 

from pib.email_open_rates op
left join dimension_external_db.pib_membership_dimension mem on op.senderuserid = mem.user_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id  
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dimension_external_db.pib_territory_dimension ter on bill.salesforce_territory = ter.territory_sfdc_id 
left join dimension_external_db.pib_user_dimension us1 on ter.territory_owner = us1.user_sfdc_id
where cast(substring(op.eventdatetime,1,10) as date) >> cast('2024-01-01' as date)
--and nlcontent like '%1363850%'
--and (deliveryaddress = 'steve.klink@philips.com' or deliveryaddress = 'gregory.savona@dowjones.com')
--and substring(eventdatetime,1,10) = '2024-03-11'
and jobtype = 'ODENL'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19) draf


group by 1,2,3,4,5,6,7,8,9,10,11)
group by 1,2,3,4,5,6,7,8,9,10
