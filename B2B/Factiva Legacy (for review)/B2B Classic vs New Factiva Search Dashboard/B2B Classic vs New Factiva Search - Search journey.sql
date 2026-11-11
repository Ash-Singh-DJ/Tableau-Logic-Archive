-- Dashboard   : "B2B Classic vs New Factiva Search Dashboard"  [B2B / Factiva Legacy (for review)]
-- Data source : "B2B Classic vs New Factiva Search - Search journey" = published source "B2B Classic vs New Factiva Search Dashboard - Search journey"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select substring(cast(date_time as varchar),1,7) year_month, EID, bill_account, comp_name,  

(case when (art_page in ('1','0') or art_page like '1.%') and art_index in ('1','2','3','4','5') then 'pg1_index_1to5'
when (art_page in ('1','0') or art_page like '1.%') and art_index not in ('1','2','3','4','5') then 'pg1_index_5plus'
when (art_page = '2' or art_page like '2.%') then 'articles_pg2'
when (art_page = '3' or art_page like '3.%') then 'articles_pg3'
when art_page not in ('0','1','2','3') and art_page not like '1.%' and art_page not like '2.%' and art_page not like '3.%' then 'articles_pg4_plus' end) as art_index,  

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' ) then 1 else 0 end ) art_index_total,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' ) then 1 else 0 end ) total_articles,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' )
and (art_page in ('1','0') or art_page like '1.%') and art_index in ('1','2','3','4','5')   
then 1 else 0 end ) articles_pg1_index_1to5,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' )
and (art_page in ('1','0') or art_page like '1.%') and art_index not in ('1','2','3','4','5')   
then 1 else 0 end ) articles_pg1_index_5plus,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' )
and (art_page = '2' or art_page like '2.%')   
then 1 else 0 end ) articles_pg2,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' )
and (art_page = '3' or art_page like '3.%')   
then 1 else 0 end ) articles_pg3,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' )
and art_page not in ('0','1','2','3') and art_page not like '1.%' and art_page not like '2.%' and art_page not like '3.%'    
then 1 else 0 end ) articles_pg4_plus,


SUM(case when event_name = 'page_view' and ti_td_page_content_type = 'ResearchTools' and
ti_td_page_content_type_detail = 'search results' and ti_td_search_record_type is not null and ti_td_module_tracker like '%previous_page_location%' then 1 else 0 end) search_count2, 

count(distinct case when post_search = 'post_search' and ti_td_page_section = 'Home Page' and visit_ends is null then lag_ss end) search_ends_home,

count(distinct case when post_search = 'post_search' and  ti_td_page_content_type = 'Article' and 
(art_page in ('1','0') or art_page like '1.%') and art_index in ('1','2','3','4','5') then lag_ss end) search_ends_article_1_5,

count(distinct case when post_search = 'post_search' and  ti_td_page_content_type = 'Article' and 
(art_page in ('1','0') or art_page like '1.%') and art_index not in ('1','2','3','4','5') then lag_ss end) search_ends_article_1_6plus,

count(distinct case when post_search = 'post_search' and  ti_td_page_content_type = 'Article' and 
(art_page not in ('1','0') and art_page not like '1.%') then lag_ss end) search_ends_article_2plus,

count(distinct case when ns_check = 'new_search' and post_search = 'post_search'  then lag_ss end) search_ends_new_search,

count(distinct case when post_search is null and visit_ends = 'visit_ends_on_search' then search_sequence end) search_ends_visit_ends,

count(distinct case when post_search is null and visit_ends = 'toggle_to_cf' then search_sequence end) search_ends_toggle_cf,

count(distinct case when ti_td_page_sub_subsection in ('Corporate Signals','Reports', 'Financials') then search_sequence end) searches_tabs,

count(distinct case when ti_td_page_sub_subsection in ('Corporate Signals','Reports') and lower(ti_td_page_section) = 'industry' then search_sequence end) ind_searches_tabs,

count(distinct case when lower(ti_td_page_section) = 'industry' then search_sequence end) ind_searches,

count(distinct case when ti_td_action = 'filters_open' then search_sequence end) searches_filter_open,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' ) 
and post_search = 'post_search'
then 1 else 0 end) post_search_articles,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' ) 
and post_search = 'post_search'
then ordinal else 0 end) ordinal_sum,

sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' ) 
then ordinal else 0 end) ordinal_sum_all_articles


from 

(with 
pos as (select event_id, (case when ti_td_page_url like '%\%%'ESCAPE '\' then '%'
								when ti_td_page_url like '%&%' then '&' else null end) as ap
from pib_event_data.pib_product_metrics
where product = 'New Factiva'
--and visit_id = 'NEWFACTIVA_20230629_E6OO2HVCQHVPFICLUBMGV2NQG4_000003'
),

base as (

select date_time, djm.event_id, visit_id, event_name, (case when ti_td_page_content_type_detail = 'WebNews' then ti_td_page_content_type_detail else ti_td_page_url end) as ti_td_page_url, ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection, ti_td_search_record_type, ti_td_page_content_type_detail, 
ti_td_page_content_type, ti_td_article_id, ti_td_action, ti_td_module_tracker, ti_td_ad_search_filters_time_period as time_period, user_info_user_ref as EID,
bill.cibs_billing_account_id as bill_account, comp.company_name as comp_name,
case when ti_td_article_id is not null then substring(ti_td_module_tracker, strpos(ti_td_module_tracker,'{"page"')+8, strpos(ti_td_module_tracker,'index')-strpos(ti_td_module_tracker,'{"page"')-10) end art_page,
       
case when ti_td_article_id is not null then substring(ti_td_module_tracker, strpos(ti_td_module_tracker,'index')+7, (strpos(ti_td_module_tracker,'}')- strpos(ti_td_module_tracker,'index')-7)) end art_index,
(case when ti_td_page_content_type_detail = 'WebNews' then ti_td_page_content_type_detail  
when (ti_td_page_url like '%factiva.com/company?code=%' or ti_td_page_url like '%factiva.com/keyword?code=%' or ti_td_page_url like '%factiva.com/keyword?search=%'
or ti_td_page_url like '%factiva.com/industry?code=%') then substring(ti_td_page_url, 1, strpos(ti_td_page_url, pos.ap)-1) end) search_state2,

(case when substring(ti_td_page_url, 1, strpos(ti_td_page_url,pos.ap)-1) = substring(lag(ti_td_page_url,1) over (order by date_time), 1, strpos(lag(ti_td_page_url,1) over (order by date_time), lag(pos.ap,1) over (order by date_time))-1) then null 
      when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results' and ti_td_search_record_type is not null and ti_td_module_tracker like '%previous_page_location%' then (concat('SS-', djm.event_id))
      else null end) search_state
from pib_event_data.pib_product_metrics djm
inner join dimension_external_db.pib_membership_dimension mem on djm.user_info_user_ref = mem.pib_member_id
left join dimension_external_db.pib_billing_account_dimension bill on mem.billing_account_id = bill.cibs_billing_account_id
left join dimension_external_db.pib_company_dimension comp on bill.salesforce_company_two = comp.company_sfdc_id 
join pos on djm.event_id = pos.event_id
where product = 'New Factiva'
--and visit_id = 'NEWFACTIVA_20230616_D3WZYJ7S5KA2F2RLYFCSI66F7A_000003'

and event_name is not null
and cycle_date >>= cast('2023-09-01' as date)
--and cycle_date <<= cast('2023-08-31' as date)

and (ti_td_action <<>> 'search' and ti_td_action <<>> 'view_topCompanies' or ti_td_action is null)
order by date_time),

base2 as
(select date_time, event_id, event_name, EID, bill_account, comp_name, visit_id,  ti_td_page_url, ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection, ti_td_page_content_type_detail, ti_td_search_record_type, ti_td_action, ti_td_module_tracker, 
ti_td_page_content_type, ti_td_article_id, art_page, art_index, time_period, coalesce (search_state, lag(search_state,1) IGNORE NULLS OVER (PARTITION by search_state2 ORDER BY date_time)) search_sequence 
from base
order by date_time),

base3 as
(select date_time, event_id, EID, bill_account, comp_name,  event_name, visit_id,  ti_td_page_url, ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection, ti_td_page_content_type_detail, ti_td_search_record_type, ti_td_action, ti_td_module_tracker, 
ti_td_page_content_type, ti_td_article_id, (case when art_page = '0' then '1' else art_page end) art_page, art_index, time_period, search_sequence, (lag(search_sequence,1) over (partition by visit_id order by date_time)) lag_ss
from base2
order by date_time)

select date_time, base3.event_id, event_name, EID, bill_account, comp_name,  visit_id,  ti_td_page_url, ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection, ti_td_module_tracker, search_sequence, lag_ss, (case when search_sequence <<>> lag_ss then 'new_search' end ) as ns_check, ti_td_page_content_type_detail, ti_td_search_record_type, ti_td_action, 
ti_td_page_content_type, ti_td_article_id, art_page, art_index, 
(case when (20*(coalesce(cast(art_page as DECIMAL),0)-1) + coalesce(cast(art_index as DECIMAL),0)) << 0 then 0 else
(20*(coalesce(cast(art_page as DECIMAL),0)-1) + coalesce(cast(art_index as DECIMAL),0)) end) as ordinal, time_period,  
(case when date_time = min(date_time) over (partition by visit_id) then null
 when search_sequence <<>> lag_ss
or (search_sequence is null and lag_ss is not null) then 'post_search' end) post_search,
(case when date_time = max(date_time) over (partition by visit_id) and search_sequence is not null and ti_td_action = 'toggle_classic_factiva' then 'toggle_to_cf'
	when date_time = max(date_time) over (partition by visit_id) and search_sequence is not null 
	and substring(ti_td_page_url, 1, strpos(ti_td_page_url,pos.ap)) <<>> substring(ti_td_page_url, 1, strpos(lead(ti_td_page_url,1) over (order by date_time),pos.ap)) then 'visit_ends_on_search' end
) as visit_ends


from base3
join pos on base3.event_id = pos.event_id
order by visit_id, date_time)

--where ordinal >> 2000

group by 1,2,3,4,5
having (SUM(case when event_name = 'page_view' and ti_td_page_content_type_detail = 'search results'
and ti_td_page_content_type = 'ResearchTools' 
and ti_td_search_record_type is not null and ti_td_module_tracker like '%previous_page_location%' then 1 else 0 end) >> 0
or 
sum(case when event_name = 'page_view' and ti_td_page_content_type = 'Article' and ti_td_article_id is not null 
and (ti_td_page_sub_subsection <<>> 'Reports' or ti_td_page_sub_subsection is null)  
and lower(ti_td_page_section) in ('company','industry', 'keyword' ) then 1 else 0 end ) >> 0)
