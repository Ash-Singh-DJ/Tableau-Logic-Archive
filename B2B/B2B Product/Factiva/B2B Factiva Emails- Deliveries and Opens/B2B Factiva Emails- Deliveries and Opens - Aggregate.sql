-- Dashboard   : "B2B Factiva Emails: Deliveries and Opens"  [B2B / B2B Product / Factiva]
-- Data source : "B2B Factiva Emails: Deliveries and Opens - Aggregate" = published source "B2B Factiva Emails: Deliveries and Opens - Aggregate"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with
jf as 
(select pib_member_id, user_id, department_code, job_function_code_last_updated_at 
from dimension_external_db.pib_membership_dimension 
where job_function_code_last_updated_at is not null
and department_code <<>> 'OT'),

nl as 
(select year_month, senderuserid,
  sum(total_email_delivery) as total_email_delivery
from 
(select draf.year_month_day, draf.year_month, jobtype, senderuserid, deliveryaddress,
count(distinct case when event = 'Delivery' and deliveryaddress <<>> '' then jobid end) total_email_delivery
from (select 
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
substring(nlcontent, strpos(nlcontent,'&nlid')+6, (strpos(nlcontent,'&inle') - strpos(nlcontent,'&nlid') - 6 )) as nlid
from pib.email_open_rates op
left join dimension_external_db.pib_membership_dimension mem on op.senderuserid = mem.user_id 
where cast(substring(op.eventdatetime,1,10) as date) >> cast('2024-01-01' as date)
--and senderuserid = 'NLEOTISELE'
and jobtype = 'ODENL'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14) draf
group by 1,2,3,4,5)
group by 1,2)





select a.year_month, alerttype, producttype, jobtype, jobtypedescription, a.senderuserid, email_address, delivery_type, emaildisplayformat,
display_format, folder_name, jf.department_code, region, alertid, cibs_billing_account_id, company_name, company_industry, territory_name, territory_owner, nl.total_email_delivery,

count(distinct case when event = 'Delivery' and (producttype in ('iff','global','fce') or producttype like 'fcp%') then jobid end) total_alerts_delivery,

count(distinct case when event = 'Delivery' and deliveryaddress <<>> '' and jobtype = 'ODENL'then jobid end) total_nl_email_delivery,

count(distinct case when event = 'Delivery' and producttype = 'sre' then jobid end) total_sr_email_delivery,

count(distinct case when event = 'Delivery' and producttype = 'sba' then jobid end) total_dig_email_delivery,

count(distinct case when event = 'Delivery' and producttype = 'iba' then jobid end) total_int_email_delivery



from (

select 
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
al.email_address,
al.delivery_type,
al.display_format,
al.folder_name,
bill.cibs_billing_account_id,
comp.company_name,
comp.company_sfdc_id,
comp.company_industry,
cr.region,
ter.territory_name,

us1.user_full_name as territory_owner 

from pib.email_open_rates op
left join dimension_external_db.pib_alerts al on (op.senderuserid = al.user_id and op.alertid = al.folder_id and op.cycle_date = al.cycle_date)
left join dimension_external_db.pib_membership_dimension mem on op.senderuserid = mem.user_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id  
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dimension_external_db.pib_territory_dimension ter on bill.salesforce_territory = ter.territory_sfdc_id 
left join dimension_external_db.pib_user_dimension us1 on ter.territory_owner = us1.user_sfdc_id
left join reference_external_db.country_reference cr on mem.country_code = cr.edw_code 
where cast(substring(op.eventdatetime,1,10) as date) >> cast('2024-01-01' as date)
--and senderuserid = 'E000588565'
and jobtype not like ''
and event = 'Delivery'
--and senderuserid = 'NLEOTISELE'
--and bill.cibs_billing_account_id = '9EXP002100'
--and jobid = 'ODENL7b30507c-bb5a-43e6-89c2-3166d12998b0'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23) as a

left join jf on a.senderuserid = jf.user_id
left join nl on a.senderuserid = nl.senderuserid  and  a.year_month = nl.year_month


group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
having count(distinct case when event = 'Delivery' and deliveryaddress <<>> '' and jobtype = 'ODENL'then jobid end)  >> 0 
or count(distinct case when event = 'Delivery' then jobid end) >> 0
