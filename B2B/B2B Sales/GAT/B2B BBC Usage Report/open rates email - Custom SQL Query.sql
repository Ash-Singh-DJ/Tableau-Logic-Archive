-- Dashboard   : "B2B BBC Usage Report"  [B2B / B2B Sales / GAT]
-- Data source : "open rates email" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 

cf as 

(select substring(cast(cycle_date as varchar),1,7) year_month, company_sfdc_id,
SUM(CASE WHEN reporting_suite = 'djfactiva' AND cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND 
	cast(hit_source as varchar) NOT IN ('5',  '8',  '9')) AND ((post_prop6 LIKE '%email%' or post_prop6 LIKE '%Email%')
	AND (post_campaign in ('Alert', 'alert_sidelink'))) AND lower(post_pagename) LIKE '%article%' 
	THEN 1 ELSE 0 END) alert_landing_pvs,

SUM(CASE WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' THEN 1 ELSE 0 END) newsletter_avs
	
FROM fact_external_db.omniture_event_fact omnit
inner join dimension_external_db.pib_membership_dimension mem on omnit.post_evar3 = mem.pib_member_id 
 left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
 left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
WHERE reporting_suite = 'djfactiva'
AND cycle_date >>= cast('2023-12-01' as date)
group by 1,2),

nf as 

(select substring(cast(cycle_date as varchar),1,7) year_month, company_sfdc_id,
sum(case when ti_td_module_tracker like '%email_digest%' or ti_td_module_tracker like '%email_interest%' then 1 else 0 end) dig_int_article_views

from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
 left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
 left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
WHERE Product = 'New Factiva'
and event_name = 'page_view' 
and ti_td_article_id is not null

AND cycle_date >>= cast('2023-12-01' as date)
group by 1,2)
	

select draf.year_month, alerttype, producttype, jobtype, jobtypedescription, senderuserid, email_address, delivery_type, emaildisplayformat, nlid,
display_format, folder_name, alertid, cibs_billing_account_id, company_name, territory_name, territory_owner, cf.alert_landing_pvs, cf.newsletter_avs, nf.dig_int_article_views,  

count(distinct case when event = 'Open' then jobid end) unique_job_id_open,
count(distinct case when event = 'Delivery' then jobid end) unique_job_id_delivery,
count(case when event = 'Delivery' then deliveryaddress end) total_email_delivery,
count(distinct case when event = 'Delivery' then deliveryaddress end) unique_email_delivery,
count(case when event = 'Open' then ipaddress end) unique_ip_opens,
count(distinct case when event = 'Open' then senderuserid end) unique_senderid_opens


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
where cast(substring(op.eventdatetime,1,10) as date) >> cast('2023-12-01' as date)
and bill.cibs_billing_account_id in('9BBC002100')
and mem.billing_account_id in('9BBC002100')
and al.account_id in('9BBC002100')
--and jobid = 'ODENL7b30507c-bb5a-43e6-89c2-3166d12998b0'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22) draf

left join cf on (draf.company_sfdc_id = cf.company_sfdc_id and draf.year_month = cf.year_month)
left join nf on (draf.company_sfdc_id = nf.company_sfdc_id and draf.year_month = nf.year_month)


group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
