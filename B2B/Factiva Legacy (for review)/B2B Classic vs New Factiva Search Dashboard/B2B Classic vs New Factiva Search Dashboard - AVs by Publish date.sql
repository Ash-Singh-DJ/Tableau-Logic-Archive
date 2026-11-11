-- Dashboard   : "B2B Classic vs New Factiva Search Dashboard"  [B2B / Factiva Legacy (for review)]
-- Data source : "B2B Classic vs New Factiva Search Dashboard - AVs by Publish date" = published source "B2B Classic vs New Factiva Search Dashboard - AVs by Publish date"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(ymd as varchar),1,7) year_month, 
 Product, billing_account_id, plan_id, company_name, company_industry, 
(case when date_diff('day', coalesce(s_pub_date, art_date), ymd) <<= 1 THEN 'Less than 1 Day'
      when date_diff('day', coalesce(s_pub_date, art_date), ymd) <<= 30 AND date_diff('day', coalesce(s_pub_date, art_date), ymd) >>= 2 THEN '2 to 30 Days'
      WHEN date_diff('day', coalesce(s_pub_date, art_date), ymd) <<= 182 AND date_diff('day', coalesce(s_pub_date, art_date), ymd) >>= 31 THEN '1 Month to 6 Months'
	  WHEN date_diff('day', coalesce(s_pub_date, art_date), ymd) <<= 365 AND date_diff('day', coalesce(s_pub_date, art_date), ymd) >>= 183 THEN '6 Months to 1 Year'
	WHEN date_diff('day', coalesce(s_pub_date, art_date), ymd) <<= 1825 AND date_diff('day', coalesce(s_pub_date, art_date), ymd) >>= 366 THEN '1 Year to 5 Years'
	WHEN date_diff('day', coalesce(s_pub_date, art_date), ymd) <<= 3650 AND date_diff('day', coalesce(s_pub_date, art_date), ymd) >>= 1826 THEN '5 Years to 10 Years'
	WHEN date_diff('day', coalesce(s_pub_date, art_date), ymd) <<= 9125 AND date_diff('day', coalesce(s_pub_date, art_date), ymd) >>= 3651 THEN '10 Years to 25 Years'
	WHEN date_diff('day', coalesce(s_pub_date, art_date), ymd) <<= 18250 AND date_diff('day', coalesce(s_pub_date, art_date), ymd) >>= 9126 THEN '25 Years to 50 Years' 
when date_diff('day', coalesce(s_pub_date, art_date), ymd) >> 18250 THEN 'More than 50 Years'
end) as category,
count(ti_td_article_id) article_count

from ( 


with j as
(select cast(substring(cast(date_time as varchar),1,10) as date) as ymd, 
event_id,
user_info_user_ref,
Product,
ti_td_page_content_type,
ti_td_page_section,
ti_td_article_id,
ti_td_article_headline,
(substring((case when ti_td_article_id like '%newsarticle%' then substring(ti_td_article_id,25)
when ti_td_article_id like '%webpage%' then substring(ti_td_article_id,21) 
when ti_td_article_id like '%htmlarticle%' then substring(ti_td_article_id,25) 
when ti_td_article_id like '%blogs%' then substring(ti_td_article_id,19)
when ti_td_article_id like '%picturearticle%' then substring(ti_td_article_id,28)
else ti_td_article_id 
end),9,8)) as pub_date,
cast(ti_td_article_publish as date) as s_pub_date
From pib_event_data.pib_product_metrics djm
where cycle_date >>= cast('2023-09-01' as date)
--and cycle_date <<= cast('2023-08-31' as date)
and (ti_td_page_content_type = 'Article' or ti_td_page_content_type_detail = 'Article view')
and event_name = 'page_view'
and Product in  ('New Factiva', 'Factiva')
and ti_td_article_id is not null
and ti_td_article_id not like 'TRAM%'
and ti_td_article_id not like '%ive.pdfa%'
and ti_td_article_id not like '%gateway/V=2%'
and ti_td_article_id <<>> 'AFPFR0002023'
and ti_td_article_id <<>> 'MABUL0020190302ef330002m'
and ti_td_article_id <<>> 'COUROmapsN0020230516ej5g00035'
and ti_td_article_id <<>> 'SHND0000201000418e64h0000h')

--jam as
select cast(ymd as date) ymd, 
event_id,
user_info_user_ref,
mem.billing_account_id,
mem.user_id,
mem.plan_id,
comp.company_name,
comp.company_industry,
Product,
ti_td_page_content_type,
ti_td_page_section,
ti_td_article_id,
cast(CONCAT(substring(pub_date,1,4),'-',substring(pub_date,5,2),'-', substring(pub_date,7,2)) as date) art_date,
s_pub_date
from j
left join dimension_external_db.pib_membership_dimension mem on j.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id 
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id )


group by 1,2,3,4,5,6,7
