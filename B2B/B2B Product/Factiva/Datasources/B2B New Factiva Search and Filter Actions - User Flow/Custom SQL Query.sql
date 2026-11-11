-- Published data source : "B2B New Factiva Search and Filter Actions - User Flow"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select * from

(select EID, date_time, pg, lead(pg,1) over(PARTITION by visit_id order by date_time) as pg2,
lead(pg,2) over(PARTITION by visit_id order by date_time) as pg3,
lead(pg,3) over(PARTITION by visit_id order by date_time) as pg4,
lead(pg,4) over(PARTITION by visit_id order by date_time) as pg5,
'a' as Vizside, cast('1' as INTEGER) as page
from 

(select date_time, user_info_user_ref EID, visit_id, event_name, concat(coalesce(ti_td_search_record_type,'-'), '-', coalesce(ti_td_page_content_type,'-'), '-', 
coalesce(ti_td_page_content_type_detail,'-'), '-',  coalesce(ti_td_action,'-'), '-', coalesce(ti_td_page_section,'-'), '-', coalesce(ti_td_page_subsection,'-'), '-', ti_td_page_url) as pg
from pib_event_data.pib_product_metrics
where Product = 'New Factiva'
and user_info_user_ref = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
and date_time >>= cast('2023-03-30' as date)
and date_time << cast('2023-03-31' as date)
and (event_name = 'page_view'
or (event_name = 'user_action' and ti_td_action like '%filter%'))
order by user_info_user_ref, date_time)
order by EID, date_time)

where pg like '%ResearchTools-search results%'

union 

select * from

(select EID, date_time, pg, lead(pg,1) over(PARTITION by visit_id order by date_time) as pg2,
lead(pg,2) over(PARTITION by visit_id order by date_time) as pg3,
lead(pg,3) over(PARTITION by visit_id order by date_time) as pg4,
lead(pg,4) over(PARTITION by visit_id order by date_time) as pg5,
'b' as Vizside, cast('1' as INTEGER) as page
from 

(select date_time, user_info_user_ref EID, visit_id, event_name, concat(coalesce(ti_td_search_record_type,'-'), '-', coalesce(ti_td_page_content_type,'-'), '-', 
coalesce(ti_td_page_content_type_detail,'-'), '-',  coalesce(ti_td_action,'-'), '-', coalesce(ti_td_page_section,'-'), '-', coalesce(ti_td_page_subsection,'-'), '-', ti_td_page_url) as pg
from pib_event_data.pib_product_metrics
where Product = 'New Factiva'
and user_info_user_ref = 'E6OO2HVCQHVPFICLUBMGV2NQG4'
and date_time >>= cast('2023-03-30' as date)
and date_time << cast('2023-03-31' as date)
and (event_name = 'page_view'
or (event_name = 'user_action' and ti_td_action like '%filter%'))
order by user_info_user_ref, date_time)
order by EID, date_time)

where pg like '%ResearchTools-search results%'
