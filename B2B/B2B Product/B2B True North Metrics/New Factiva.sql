-- Dashboard   : "B2B True North Metrics"  [B2B / B2B Product]
-- Data source : "New Factiva" = published source "B2B True North - New Factiva"  [B2B / B2B Product / Data sources / True North Metrics Data Sources]
-- Relation    : Custom SQL "Main Metrics"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
with dat as 

(select substring(cast(full_date as varchar),1,10) as full_date, substring(cast(week_start_date as varchar),1,10) as wsd,  week_number_in_fiscal_year as fw
from  reference_external_db.date_dimension 
where full_date >> date_add('day', -3000, current_date)
),

raw as 

(select user_info_user_ref as EID, 
min(cycle_date) min_date
from pib_event_data.pib_product_metrics djm

where product = 'New Factiva'
and event_name = 'page_view'
and ti_td_page_section = 'Home Page'
and user_info_account_id not like  '9ZZZ%'
and user_info_account_id not like   '9ZFB%' 
and user_info_account_id <<>> '9DOW003600'
and user_info_account_id <<>>'9DOW007100'
and user_info_account_id <<>>'9FAC067700' 
group by 1),

ftas as 

(select dat.wsd, count(distinct EID) first_time_actives
from raw
left join dat on cast(raw.min_date as varchar) = dat.full_date
group by 1),


act as 
(select dat.wsd, count(distinct user_info_user_ref) total_actives
from pib_event_data.pib_product_metrics djm
left join dat on cast(djm.cycle_date as varchar) = dat.full_date
where product = 'New Factiva'
and event_name in ('page_view', 'user_action')
and ti_td_page_section not like '%Onboarding%'
and user_info_account_id not like  '9ZZZ%'
and user_info_account_id not like   '9ZFB%' 
and user_info_account_id <<>> '9DOW003600'
and user_info_account_id <<>>'9DOW007100'
and user_info_account_id <<>>'9FAC067700' 
group by 1)


select ftas.wsd, ftas.first_time_actives, act.total_actives
from ftas
join act on ftas.wsd = act.wsd
