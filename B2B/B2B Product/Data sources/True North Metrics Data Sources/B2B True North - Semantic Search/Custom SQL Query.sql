-- Published data source : "B2B True North - Semantic Search"  [B2B / B2B Product / Data sources / True North Metrics Data Sources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with

dat as 

(select substring(cast(full_date as varchar),1,10) as full_date, substring(cast(week_start_date as varchar),1,10) as wsd,  week_number_in_fiscal_year as fw,
day_of_week as dow
from  reference_external_db.date_dimension 
where full_date >> date_add('day', -800, current_date)
),


query as

(with 
pos as (select event_id, (case when ti_td_page_url like '%\%%'ESCAPE '\' then '%'
								when ti_td_page_url like '%&%' then '&' else null end) as ap
from pib_event_data.pib_product_metrics
where product = 'New Factiva'
--and visit_id = 'NEWFACTIVA_20230904_E6OO2HVCQHVPECS67G5JUH4MIU_000002'
group by 1,2
),

base as (

select date_time, djm.event_id, visit_id, event_name, (case when ti_td_page_content_type_detail = 'WebNews' then ti_td_page_content_type_detail else ti_td_page_url end) as ti_td_page_url,
 
    (((LENGTH(ti_td_page_url) - LENGTH(REPLACE(ti_td_page_url, '%20', ''))) / 3) +1) AS search_word_count,

ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection, ti_td_search_record_type, ti_td_page_content_type_detail, 
ti_td_page_content_type, ti_td_article_id, ti_td_article_word_count as word_count, ti_td_action, ti_td_ad_order_by,
ti_td_module_tracker, ti_td_ad_search_filters_time_period as time_period, user_info_user_ref as EID, mem.plan_id,
bill.cibs_billing_account_id as bill_account, comp.company_name as comp_name, ti_td_search_results_count, ti_td_search_type as search_type, ti_td_semantic_search_result_type as search_result,
case when ti_td_article_id is not null then substring(ti_td_module_tracker, strpos(ti_td_module_tracker,'{"page"')+8, strpos(ti_td_module_tracker,'index')-strpos(ti_td_module_tracker,'{"page"')-10) end art_page,
       
case when ti_td_article_id is not null then substring(ti_td_module_tracker, strpos(ti_td_module_tracker,'index')+7, (strpos(ti_td_module_tracker,'}')- strpos(ti_td_module_tracker,'index')-7)) end art_index,
concat((case when ti_td_page_content_type_detail = 'WebNews' then ti_td_page_content_type_detail  
when (ti_td_page_url like '%factiva.com/company?code=%' or ti_td_page_url like '%factiva.com/keyword?code=%' or ti_td_page_url like '%factiva.com/keyword?search=%'
or ti_td_page_url like '%factiva.com/industry?code=%') then substring(ti_td_page_url, 1, strpos(ti_td_page_url, pos.ap)-1) end), coalesce(ti_td_article_id,'0'))  search_state2,

(case when substring(ti_td_page_url, 1, strpos(ti_td_page_url,pos.ap)-1) = substring(lag(ti_td_page_url,1) over (order by date_time), 1, strpos(lag(ti_td_page_url,1) over (order by date_time), lag(pos.ap,1) over (order by date_time))-1) then null 
      when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' and (ti_td_action not like 'article_save%' or ti_td_action is null) and ti_td_search_record_type is not null and  ti_td_page_url not like '%dj.factiva.com/home%'  and ti_td_module_tracker like '%previous_page_location%' 
      and ti_td_module_tracker not like '%InterestClick%' then (concat('SS-', djm.event_id))
      else null end) search_state,
     cycle_date 
from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
join pos on djm.event_id = pos.event_id
where product = 'New Factiva'
and user_info_user_ref <<>> 'E6OO2HVCQHVPEJOZUXTWU7CIUI' 
and ti_td_page_url not like '%beta%'
and user_info_account_id not like '9ZZZ%'
--and user_info_account_id not like '9ZFB%'
and user_info_account_id <<>> '9DOW003600'
and user_info_account_id <<>> '9DOW007100'
and user_info_account_id <<>> '9FAC067700'
and plan_id <<>> '0086'
and plan_id <<>> '0087'
--and visit_id = 'NEWFACTIVA_20241021_E6OO2HVCQHVPEKOJVPIZBZ36TU_000002'
and visit_id <<>> 'NEWFACTIVA_20240712_D3WZYJ7S5KA2FIHLUET4HT2ATU_000002'
--and user_info_user_ref = 'D3WZYJYBD4BQACS65JT57JABAA'
and event_name is not null
and (ti_td_action <<>> 'smart_summary_available' or  ti_td_action is null)
and ((cycle_date >>= cast('2024-06-01' as date) and cycle_date <<= cast('2024-06-30' as date)) 
or (cycle_date >>= cast('2025-03-01' as date) and cycle_date <<= cast('2026-12-31' as date)))


and ((ti_td_action <<>> 'search' and ti_td_action <<>> 'view_topCompanies' and ti_td_action not like 'article_save%') or ti_td_action is null)
order by date_time),

base2 as
(select date_time, search_type, event_id, event_name, EID, plan_id, bill_account, comp_name, visit_id,  ti_td_page_url, search_word_count, ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection, ti_td_page_content_type_detail, ti_td_search_record_type, ti_td_action, ti_td_module_tracker, 
ti_td_page_content_type, ti_td_article_id, word_count, ti_td_search_results_count, art_page, art_index, time_period, coalesce (search_state, lag(search_state,1) IGNORE NULLS OVER (PARTITION by search_state2, visit_id, ti_td_article_id ORDER BY date_time)) search_sequence, ti_td_ad_order_by, 
coalesce (search_type, lag(search_type,1) IGNORE NULLS OVER (PARTITION by search_state2, visit_id, ti_td_article_id ORDER BY date_time)) search_type2, coalesce (search_result, lag(search_type,1) IGNORE NULLS OVER (PARTITION by search_state2, visit_id, ti_td_article_id ORDER BY date_time)) search_result2

from base
order by date_time),

base3 as
(select date_time, search_type, (lag(search_type2, 1) over (partition by visit_id order by date_time)) search_type_lag, (lag(search_result2, 1) over (partition by visit_id order by date_time)) search_result_lag, (lag(ti_td_action, 1) over (partition by visit_id order by date_time)) action_lag, event_id, EID, plan_id, bill_account, comp_name,  event_name, visit_id,  ti_td_page_url, ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection, ti_td_page_content_type_detail, search_word_count, ti_td_search_record_type, ti_td_action, ti_td_module_tracker, 
ti_td_page_content_type, ti_td_article_id, word_count, ti_td_search_results_count, (case when art_page = '0' then '1' when art_page like '%depth%' then NULL else art_page end) art_page, 
(case when (art_index like '%page%' or art_index = 'null') then null else art_index end) art_index, time_period, (case when ti_td_ad_order_by = 'Most Recent First' then 'Most Recent' end) as mr, (case when ti_td_action = 'entity_link_click' then 'ent_link' end) as el,
(case when time_period = 'Last Day' then 'Last Day' end) as fil_last_day, (case when time_period = 'Last Week' then 'Last Week' end) as fil_last_week, (case when time_period <<>> 'Last 3 Months' then 'dat_filter' end) as dat_filter,
search_sequence, (lag(search_sequence,1) over (partition by visit_id order by date_time)) lag_ss,

date_diff('second', LAG(date_time, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc), date_time) as seconds_between_events,
ROW_NUMBER() OVER(PARTITION BY visit_id) as event_num
from base2
order by date_time),

base4 as
(select date_time, search_type, search_type_lag, search_result_lag, action_lag, base3.event_id, event_name, EID, plan_id, bill_account, comp_name,  visit_id,  ti_td_page_url, search_word_count, ti_td_page_section, ti_td_page_subsection, ti_td_search_results_count, ti_td_page_sub_subsection, ti_td_module_tracker, search_sequence, lag_ss, (case when search_sequence <<>> lag_ss then 'new_search' end ) as ns_check, ti_td_page_content_type_detail, ti_td_search_record_type, ti_td_action, 
ti_td_page_content_type, ti_td_article_id, word_count, art_page, art_index, 
(case when search_sequence is not null and ti_td_action like 'pagination%' then 'pag' end) as pagination,   
(case when search_sequence is not null and (ti_td_action = 'filter_search') then 'fil' end) as filters,
event_num, mr, fil_last_day, fil_last_week, dat_filter, el,
(case when (20*(coalesce(cast(art_page as DECIMAL),0)-1) + coalesce(cast(art_index as DECIMAL),0)) << 0 then 0 else
(20*(coalesce(cast(art_page as DECIMAL),0)-1) + coalesce(cast(art_index as DECIMAL),0)) end) as ordinal, time_period,  
(case when date_time = min(date_time) over (partition by visit_id) then null
 when search_sequence <<>> lag_ss
or (search_sequence is null and lag_ss is not null) then 'post_search' end) post_search,
(case when date_time = max(date_time) over (partition by visit_id) and search_sequence is not null and ti_td_action = 'toggle_classic_factiva' then 'toggle_to_cf'
	when date_time = max(date_time) over (partition by visit_id) and search_sequence is not null 
	and substring(ti_td_page_url, 1, strpos(ti_td_page_url,pos.ap)) <<>> substring(ti_td_page_url, 1, strpos(lead(ti_td_page_url,1) over (order by date_time),pos.ap)) then 'visit_ends_on_search' end
) as visit_ends, seconds_between_events, LEAD(seconds_between_events, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lead_seconds,
(case when lag_ss is not null then seconds_between_events end) as secs
from base3
join pos on base3.event_id = pos.event_id),

ba5 as
(select base4.*,
coalesce (pagination, lag(ti_td_search_record_type,1) IGNORE NULLS OVER (PARTITION by visit_id ORDER BY date_time)) as search_record,
 coalesce (pagination, lag(pagination,1) IGNORE NULLS OVER (PARTITION by lag_ss ORDER BY date_time)) pagination2,
  coalesce (filters, lag(filters,1) IGNORE NULLS OVER (PARTITION by lag_ss ORDER BY date_time)) filters2,
  coalesce (mr, lag(mr,1) IGNORE NULLS OVER (PARTITION by lag_ss ORDER BY date_time)) mr2,
    coalesce (el, lag(el,1) IGNORE NULLS OVER (PARTITION by lag_ss, visit_id ORDER BY date_time)) el2,

  
  
  LEAD(ti_td_page_section, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lead_section,
  LEAD(ti_td_page_subsection, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lead_subsection,
  LEAD(ti_td_page_content_type, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lead_content_type,
  LEAD(ti_td_page_content_type_detail, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lead_content_type_detail,
  LEAD(ti_td_action, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lead_action,
  LAG(ti_td_page_url, 1) OVER (PARTITION BY visit_id ORDER BY date_time asc) as lag_url,
(MIN(case when post_search is not null then event_num end) over (partition by lag_ss)) as min_event_num  from
base4)

select ba5.*, SUM(case when event_num <<= min_event_num then secs end) over (partition by lag_ss) as sum_secs,
count(case when event_num <<= min_event_num then filters end) over (partition by lag_ss) as num_filter_sort
from ba5
order by visit_id, date_time)


select substring(cast(date_time as varchar),1,10) as year_month_day,
dat.wsd,
EID, plan_id, bill_account, comp_name,  lag_ss as search_seq, search_type_lag, search_result_lag, ti_td_action, action_lag, 
concat(post_search,'_',ti_td_page_content_type,'_',ti_td_page_content_type_detail,'_', coalesce(art_page,'*'),'_',coalesce(art_index,'*'), coalesce(ns_check,'*')) as post_search2, 
concat(coalesce(lead_section,'*'),'_',coalesce(lead_subsection,'*'),'_',coalesce(lead_content_type,'*'),'_',coalesce(lead_content_type_detail,'*'),'_', coalesce(lead_action,'*')) post_article_event,
search_record,
ordinal,
lag_url,
art_page,
art_index,
mr2,
el2
from query
left join dat on substring(cast(query.date_time as varchar),1,10) = dat.full_date

where concat(post_search,'_',ti_td_page_content_type,'_',coalesce(art_page,'*'),'_',coalesce(art_index,'*'), coalesce(ns_check,'*')) is not null
and (event_num <<= min_event_num or min_event_num is null)


union all 

select substring(cast(date_time as varchar),1,10) as year_month_day, dat.wsd, EID, plan_id, bill_account, comp_name, search_sequence as search_seq, search_type_lag, search_result_lag, ti_td_action, action_lag, visit_ends as post_search2, null as post_article_event,
coalesce(ti_td_search_record_type, search_record) as search_record,
ordinal, lag_url,
 art_page, art_index, mr2, el2
from query
left join dat on substring(cast(query.date_time as varchar),1,10) = dat.full_date
where visit_ends is not null
