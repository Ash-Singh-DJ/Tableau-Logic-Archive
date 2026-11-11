-- Dashboard   : "Factiva Search Samples"  [B2B / B2B Product / Factiva / Factiva Search Usage]
-- Data source : "Simple + Saved Search" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with a as (

select * from (

with raw as (

select event_datetime, client_session_id as sessionID, client_user_id, mem.plan_id,

transaction_resource_target,  coalesce(keyword_search_term, search_term_with_codes) as keyword_search_term,  
request_headers_x_dj_access_point_code, (((LENGTH(keyword_search_term) - LENGTH(REPLACE(keyword_search_term, ' ', ''))) / 1) +1) AS search_word_count,
news_subject_codes, industry_codes, region_codes, company_codes, author_codes, sources_codes, content_languages, date_range, length(keyword_search_term) as search_characters
from pib_event_data.pib_platform_trace pt
left join dimension_external_db.pib_membership_dimension mem on pt.client_user_id = mem.user_id

where 
--(transaction_resource_target = '/content/semantic-search' or transaction_resource_target = '/content/search')
--and request_headers_x_dj_access_point_code = 'FH'
--and request_message_body like '%scope%'
cycle_date >>= cast('2026-05-01' as date)
--and cycle_date << cast('2025-11-03' as date)
and (keyword_search_term is not null or search_term_with_codes is not null)
--and mem.billing_account_id not like '9ZZZ%'
--and mem.billing_account_id not like '9ZFB%'
--and mem.billing_account_id <<>> '9DOW003600'
--and mem.billing_account_id <<>> '9DOW007100'
--and mem.billing_account_id <<>> '9FAC067700'
--and  client_user_id = 'mhm001'
--and  strpos(request_message_body, keyword_search_term) >> 0 
--and lower(request_message_body) not like '%"value":"rst=%'
--and request_message_body not like '%"value":"wc>>0%'
and request_headers_x_dj_access_point_code IN ('NS', 'S')
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
order by event_datetime)

select raw.*,  lag(keyword_search_term,1) over(PARTITION by sessionID, news_subject_codes, industry_codes, region_codes, company_codes, author_codes, content_languages, date_range 

order by event_datetime) as kst_lag
from raw)
where kst_lag is null or keyword_search_term <<>> kst_lag),

b as (
select a.*, RANK() over (partition by sessionID, client_user_id order by event_datetime) as rnk
from a)

select b.*, concat(upper(substr(to_base(crc32(to_utf8(client_user_id)), 36), 1, 8)),substring(client_user_id,7,3)) 
user_id_hash from b 
where rnk = 1
order by event_datetime desc
limit 50000
