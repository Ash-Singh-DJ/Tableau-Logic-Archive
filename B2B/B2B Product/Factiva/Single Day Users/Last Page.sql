-- Dashboard   : "Single Day Users"  [B2B / B2B Product / Factiva]
-- Data source : "Last Page" = published source "B2B Single Day Users on Factiva - Last Page"  [B2B / B2B Product / Factiva / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with luc as 
(with dig as
(select date_time, user_info_user_ref as EID, product, event_name, ti_td_action, ti_td_page_url, ti_td_page_name, ti_td_page_section, ti_td_page_subsection, ti_td_page_sub_subsection
from pib_event_data.pib_product_metrics
where  product in ('New Factiva','Factiva')
and event_name is not null)
--and user_info_user_ref = 'E6OO2HVCQHVPFXW6TM2TILNTME')
select * from dig
where date_time = (select max(date_time) from dig dig2 where dig.EID = dig2.EID))



select user_info_user_ref, luc.date_time, luc.event_name, luc.product, luc.ti_td_page_name, luc.ti_td_page_section, luc.ti_td_page_subsection, luc.ti_td_page_sub_subsection, luc.ti_td_action,
count(distinct case when djm.event_name = 'page_view' or djm.event_name = 'user_action' then cycle_date end) active_days,
max(case when djm.event_name = 'page_view' or djm.event_name = 'user_action' then cycle_date end) max_cycle_date 
from pib_event_data.pib_product_metrics djm
left join luc on djm.user_info_user_ref = luc.EID 
where djm.product in  ('New Factiva', 'Factiva')
and cycle_date >>= cast('2020-01-01' as date)
group by 1,2,3,4,5,6,7,8,9
having count(distinct case when djm.event_name = 'page_view' or djm.event_name = 'user_action' then cycle_date end) = 1
and max(case when djm.event_name = 'page_view' or djm.event_name = 'user_action' then cycle_date end) << cast('2023-08-01' as date)
