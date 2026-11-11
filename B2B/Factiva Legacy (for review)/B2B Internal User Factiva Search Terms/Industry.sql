-- Dashboard   : "B2B Internal User Factiva Search Terms"  [B2B / Factiva Legacy (for review)]
-- Data source : "Industry" = published source "B2B Internal Usage Factiva Search Terms - Industry"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with dataset as (
select * from (
 
select split(cast(isc as varchar), ' '),  keyword_search_term, Platform, event_datetime from (

with raw as (

select event_datetime, client_session_id as EsessionID, 
concat(cast(substr(reverse(client_user_id),1,2) as varchar), substr(reverse(client_user_id),3,3), cast(length(client_user_id) as varchar), cast('9' as varchar), substr(reverse(client_user_id),4,3), cast(length(client_user_id) as varchar), cast('2' as varchar), substr(reverse(client_user_id),7,3), substr((client_user_id),1,2), cast('6' as varchar), substr(reverse(client_user_id),9,10)) as EUserID,

transaction_resource_target,  keyword_search_term, (case when request_headers_x_dj_access_point_code = 'FH' then 'New Factiva' else 'Classic Factiva' end) as Platform, request_headers_x_dj_access_point_code, (((LENGTH(keyword_search_term) - LENGTH(REPLACE(keyword_search_term, ' ', ''))) / 1) +1) AS search_word_count,
--substring(request_message_body, strpos(request_message_body,'scope'),2000) as tester, request_message_body,
news_subject_codes as nsc, industry_codes as isc, region_codes, company_codes, author_codes, sources_codes, content_languages, date_range
from pib_event_data.pib_platform_trace
--where client_user_id = 'E000588565'
where (transaction_resource_target = '/content/semantic-search' or transaction_resource_target = '/content/search')
--and request_headers_x_dj_access_point_code = 'FH'
and request_message_body like '%scope%'
and cycle_date >>= cast('2024-10-01' as date)
and keyword_search_term is not null
and (client_account_id = '9ZFB000200'
or client_account_id = '9ZFB000300'
or client_account_id = '9ZZZ046200'
or client_account_id = '9ZZZ155500')

and  client_user_id <<>> 'X000978692'
and  client_user_id <<>> 'X000644081'
and  client_user_id <<>> 'X001010132'
and  client_user_id <<>> 'X000647329'
and  client_user_id <<>> 'X000750569'
and  client_user_id <<>> 'E000960228'
and  client_user_id <<>> 'E000511466'
and  client_user_id <<>> 'E000807040'
and  client_user_id <<>> 'E000814905'


and  client_user_id not like 'omniture%'
--and client_user_id = 'E000588565'
and  strpos(request_message_body, keyword_search_term) >> 0 
and industry_codes is not null
--and lower(request_message_body) not like '%"value":"rst=%'
--and request_message_body not like '%"value":"wc>>0%'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
order by event_datetime)

select raw.*,  lag(keyword_search_term,1) over(PARTITION by EsessionID order by event_datetime) as kst_lag
from raw)
where kst_lag is null or keyword_search_term <<>> kst_lag)
AS t (metrics_array, kst, platform, event_datetime))

select metric, kst, platform, event_datetime
FROM dataset 

cross join unnest(metrics_array) as t(metric)
