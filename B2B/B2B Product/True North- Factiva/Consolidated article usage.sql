-- Dashboard   : "True North: Factiva"  [B2B / B2B Product]
-- Data source : "Consolidated article usage" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with 

wk as
(select substring(cast(full_date as varchar),1,10) year_month_day, substring(cast(week_start_date as varchar),1,10) week_start
from reference_external_db.date_dimension
where substring(cast(full_date as varchar),1,10) >>= cast('2021-01-01' as varchar)
order by full_date),

a as

(with raw as

(select cast(cycle_date as varchar) as cycle_date, wk.week_start, mem.pib_member_id, mem.plan_id, mem.billing_account_id, comp.company_name, product, ti_td_action, ti_td_module_tracker, ti_td_page_driver, 
ti_td_page_section,
ti_td_page_subsection, ti_td_page_referring_url, 
count(ti_td_article_id) as article_count

from pib_event_data.pib_product_metrics djm
join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
left join wk on cast(djm.cycle_date as varchar) = wk.year_month_day

where ti_td_article_id is not null 
and event_name in ('page_view', 'user_action')
and cycle_date >> date_add('day', -450, current_date)
and product in ('New Factiva', 'Factiva')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13)

select cycle_date, week_start, pib_member_id, billing_account_id, company_name, plan_id,
(case when ti_td_module_tracker like '%email_digest%' then 'Digest_email'
 when ti_td_module_tracker like '%email_interest%' then 'Interest_email'
 when ti_td_module_tracker like '%saturdayReview%' then 'Sat_review_email' 
 when (ti_td_page_driver = 'searchBuilder_Search' or ti_td_page_referring_url like '%searchBuilder_Search%') and product = 'Factiva' then 'Search Builder'
 when ti_td_page_driver = 'SavedSearch_SelectSearch' and product = 'Factiva' then 'Saved Search'
 when ti_td_page_subsection = 'Simple Search Results' and product = 'Factiva' then 'Simple Search'
  when ti_td_page_section = 'Home' and product = 'Factiva' then 'Home'
 when ((ti_td_page_section = 'Alerts' and ti_td_page_subsection = 'Viewer') or ti_td_page_driver = 'alerts_viewAlerts') then 'Alerts'
 when ti_td_page_section = 'Newsletter' and ti_td_page_subsection = 'Newsletter Viewer' then 'Newsletter'
 when ti_td_page_section = 'Home Page' and ti_td_page_subsection = 'Personalized News' then 'NF Personalized'
 when ti_td_page_section = 'Home Page' and ti_td_page_subsection = 'Trending News' then 'NF Trending'
  when ti_td_page_section = 'Companies and Markets' then 'Companies & Markets'
  when Product = 'New Factiva' then concat('NF', ti_td_page_section)
  when Product = 'Factiva' then 'Classic Factive Other' 
 end) as art_type,
 sum(article_count) as total_articles
 from raw
group by 1,2,3,4,5,6,7),

b as 

(select substring(cast(datetime as varchar),1,10) as cycle_date, wk.week_start, 
user_id as pib_member_id, bam.billing_account_id, null as company_name, null as plan_id, 'Gen_AI_Article_feed' as art_type,
count(an) as total_articles
from pib_event_data.gen_ai_article_usage k
left join pib_event_data.user_key_billing_account_mappings bam on k.user_key = bam.user_key
left join wk on substring(cast(k.datetime as varchar),1,10) = wk.year_month_day

where datetime >> date_add('day', -450, current_date)
group by 1,2,3,4,5,6,7),

c as 

(select  substring(cast(begin_letter_request_date_time as varchar),1,10) as cycle_date, wk.week_start, begin_letter_eid as pib_member_id,
begin_letter_account_code as billing_acocunt_id, comp.company_name, mem.plan_id,   'Gen_AI_NF_backend' as art_type,

count(letters_accession_number) as article_count 
from publisher_reporting_db.commerce_envelope ce 
inner join dimension_external_db.pib_membership_dimension mem on ce.begin_letter_eid = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join wk on substring(cast(ce.begin_letter_request_date_time as varchar),1,10) = wk.year_month_day
where letters_function_code = 'VAI01'
and begin_letter_access_point_code = 'AIM'
and letters_request_date_time >> date_add('day', -450, current_date)
and ce.letters_accession_number not like 'WC%'
and begin_letter_client_type_code = 'D' 
group by 1,2,3,4,5,6,7),

d as 
(select cast(cycle_date as varchar) as cycle_date, wk.week_start, 
post_evar3 as pib_member_id, mem.billing_account_id, null as company_name, mem.plan_id, 'mct_article_views' as art_type,


SUM(CASE WHEN reporting_suite = 'djfactiva' and cast(post_page_event as varchar) = '0' AND (CAST(exclude_hit AS integer) <<= 0 AND cast(hit_source as varchar) NOT IN ('5', '8', '9'))
                    AND (post_evar4 = 'Fact_ART_ArticleView' or post_prop3 = 'ARTICLE' or lower(post_pagename) like '%article%')
                    AND lower(post_pagename) NOT LIKE '%login%' AND post_prop40 <<>> '' AND post_evar11 = 'MyCompanyToday' THEN 1 ELSE 0 END) article_count


 FROM fact_external_db.omniture_event_fact omnit
 left join dimension_external_db.pib_membership_dimension mem on omnit.post_evar3 = mem.pib_member_id 
 left join wk on cast(omnit.cycle_date as varchar) = wk.year_month_day
 
WHERE reporting_suite  = 'djfactiva'
AND lower(post_pagename) NOT LIKE '%login%' 
AND post_prop40 <<>> '' 
AND post_evar11 = 'MyCompanyToday'
AND cycle_date >> date_add('day', -450, current_date)
GROUP BY 1,2,3,4,5,6,7),

e as 

(select year_month_day as cycle_date, week_start, pib_member_id, billing_account_id, company_name, plan_id, 'ft_email_opens' as art_type,  
sum(unique_job_id_open) as article_count from (

select year_month_day, week_start, alerttype, producttype, jobtype, jobtypedescription, senderuserid, email_address, delivery_type, emaildisplayformat, 
display_format, folder_name, alertid, cibs_billing_account_id as billing_account_id, company_name, plan_id, pib_member_id,   

count(distinct case when event = 'Open' then jobid end) unique_job_id_open

from (

select 
substring(eventdatetime,1,10) year_month_day,
wk.week_start,
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
mem.plan_id,
mem.pib_member_id


from pib.email_open_rates op
left join dimension_external_db.pib_alerts al on (op.senderuserid = al.user_id and op.alertid = al.folder_id and op.cycle_date = al.cycle_date)
left join dimension_external_db.pib_membership_dimension mem on op.senderuserid = mem.user_id 
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id  
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
left join dimension_external_db.pib_territory_dimension ter on bill.salesforce_territory = ter.territory_sfdc_id 
left join dimension_external_db.pib_user_dimension us1 on ter.territory_owner = us1.user_sfdc_id
left join wk on substring(op.eventdatetime,1,10) = wk.year_month_day
where cast(substring(op.eventdatetime,1,10) as date) >> date_add('day', -450, current_date)
and lower(display_format) like 'fulltext%'
and event = 'Open'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22   )
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17)
group by 1,2,3,4,5,6,7),

f as 

(SELECT cast(cycle_date as varchar) as cycle_date, wk.week_start,  client_user_id as pib_member_id,  client_account_id as billing_account_id, comp.company_name, null as plan_id,
'GenAI_Retrieve_API' as art_type,
cast(json_extract_scalar(response_message_body,'$.meta.total_count') as int) AS total_count
FROM pib_event_data.pib_platform_trace pt
left join dimension_external_db.pib_billing_account_dimension bill on pt.client_account_id = bill.cibs_billing_account_id 
LEFT JOIN dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id
 left join wk on cast(pt.cycle_date as varchar) = wk.year_month_day
where transaction_resource_urn like '%genairetrieve%'
and transaction_status_code = 200
and request_message_body like '%metrics_data%'
and request_message_body like '%user_id%'
and cycle_date >>  date_add('day', -450, current_date))



select * from a 
union all 
select * from b
union all 
select * from c
union all
select * from d
union all 
select * from e
union all 
select * from f
