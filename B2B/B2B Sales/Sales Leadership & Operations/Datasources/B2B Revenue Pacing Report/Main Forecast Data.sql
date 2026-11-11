-- Published data source : "B2B Revenue Pacing Report"  [B2B / B2B Sales / Sales Leadership & Operations / Datasources]
-- Relation    : Custom SQL "Main Forecast Data"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
                    
                      
                    
                    
with p as ( 
WITH mql as (
  SELECT lead_sfdc_id, MIN(last_modified_date) as mq_date, min(cycle_date) as mql_cycle_date
  FROM (
    SELECT DISTINCT web_form_name, region, product_of_interest, marketing_tactic_original, marketing_tactic_most_recent, marketing_qualified_flag, lead_status, lead_source, lead_sfdc_id, lead_score, lead_name, lead_owner,
           lead_created_date, lead_country, lead_converted_flag, lead_company, last_modified_date, content_type, buying_center, cycle_date
    FROM dimension_external_db.pib_leads_dimension_history
    WHERE (lead_status IN ('Untouched','Working','Qualified','Future Follow-up','Converted to Opportunity','Converted to Contact Only',
                           'Disqualified','Return to Marketing','Unqualified')
       OR converted_contact_id IS NOT NULL OR converted_contact_id != ''
       OR converted_opportunity_id IS NOT NULL OR converted_opportunity_id != ''))
  GROUP BY lead_sfdc_id),


maxe as (
with main as (
with a as (
WITH  OPP_DIM_LATEST_CHANGES AS (SELECT cast(opportunity_number as integer) as opportunity_number, MAX(cycle_date) cycle_date
FROM dimension_external_db.pib_opportunity_dimension_history
where cycle_date << date_add('year',-2, date_add('day',-day(current_date), DATE(current_date))) 
group by 1),
PS_DIM_LATEST_CHANGES AS (SELECT sfdc_product_services_id, MAX(cycle_date) cycle_date
FROM dimension_external_db.pib_product_services_dimension_history
where cycle_date << date_add('year',-2, date_add('day',-day(current_date), DATE(current_date))) 
group by 1),
Opp_Dim as (
select cast(opportunity_number as integer) as opportunity_number, opportunity_closed_date, sale_type, source_type, pib_opportunity_sfdc_id, cycle_date, account_id, opportunity_territory, opportunity_owner, pipeline_category,
total_one_time_revenue, probability_percentage, in_forecast, r_c_proposition, annualized_opportunity_revenue, created_date
from dimension_external_db.pib_opportunity_dimension_history
where cycle_date >> date_add('month', -24, date_add('day',-day(current_date), DATE(current_date)))
UNION
SELECT OPPORTUNITY.opportunity_number, OPPORTUNITY.opportunity_closed_date, sale_type, source_type, pib_opportunity_sfdc_id, OPPORTUNITY.cycle_date, account_id, opportunity_territory, opportunity_owner, pipeline_category,
total_one_time_revenue, probability_percentage, in_forecast, r_c_proposition, annualized_opportunity_revenue, created_date
FROM dimension_external_db.pib_opportunity_dimension_history opportunity LEFT OUTER JOIN OPP_DIM_LATEST_CHANGES ON OPPORTUNITY.opportunity_number=OPP_DIM_LATEST_CHANGES.opportunity_number
and opportunity.cycle_date=OPP_DIM_LATEST_CHANGES.cycle_date
where opportunity.status_flag<<>>'DELETE'
and opportunity.Cycle_date >> date_add('month',-24, date_add('day',-day(current_date), DATE(current_date)))
),
PS_Dim as (
select sfdc_product_services_id, forecast_month, net_change, one_time_charge, stage, product_service, opportunity, cycle_date, currency_iso_code, specialist, specialist_2, adjusted_effective_date, override_forecast_date,
net_recurring_amount, net_one_time_amount, product_line, status_flag
from dimension_external_db.pib_product_services_dimension_history
UNION
SELECT ps.sfdc_product_services_id, forecast_month, net_change, one_time_charge, stage, product_service, opportunity, ps.cycle_date, currency_iso_code, specialist, specialist_2, adjusted_effective_date, override_forecast_date,
net_recurring_amount, net_one_time_amount, product_line, status_flag
FROM dimension_external_db.pib_product_services_dimension_history ps LEFT OUTER JOIN PS_DIM_LATEST_CHANGES ON ps.sfdc_product_services_id=PS_DIM_LATEST_CHANGES.sfdc_product_services_id
and ps.cycle_date=PS_DIM_LATEST_CHANGES.cycle_date
where ps.status_flag<<>>'DELETE'
),
Comp_Dim as (select company_sfdc_id, company_country, company_industry, sales_campaign_s, company_name, ntc_owner, pib_focus_owner,
r_c_rating, mm_quadrant
 from dimension_external_db.pib_company_dimension),
Terr_Owner as (select user_sfdc_id, user_full_name from dimension_external_db.pib_user_dimension),
Terr_RSD as (select user_sfdc_id, user_full_name from dimension_external_db.pib_user_dimension),
Specialist as (select user_sfdc_id, user_full_name from dimension_external_db.pib_user_dimension),
Specialist2 as (select user_sfdc_id, user_full_name from dimension_external_db.pib_user_dimension),
Terr_Dim as (select territory_sfdc_id, territory_name, territory_owner, territory_roll_up, regional_sales_director, region_code from dimension_external_db.pib_territory_dimension
--where territory_status = 'Active'
),
Opp_Owner as(select user_full_name, user_sfdc_id, user_title from dimension_external_db.pib_user_dimension),
Curr_Rates as (SELECT * FROM reference_external_db.fx_rates_current),

user_dim as (select user_sfdc_id, user_full_name from dimension_external_db.pib_user_dimension),

user2_dim as (select user_sfdc_id, user_full_name from dimension_external_db.pib_user_dimension),

Prod as (select bu, product_line, master_product, sfdc_product from reference_external_db.pib_product_dimension),

dt as (select cast(full_date as date) as date, week_number_in_fiscal_month,  concat(fiscal_month_name, ' ', substring(cast(full_date as varchar),1,4)) as fiscal_month,
month_number_in_calendar_year as month_num, day_of_week as dow   from 
reference_external_db.date_dimension
where full_date >> cast('2010-01-01' as date)) , 
 

camp_russian_sanctions AS (
SELECT distinct opportunity_id, camp.name 
FROM dimension_external_db.pib_campaign_influence ci
INNER JOIN dimension_external_db.pib_campaign_dimension camp ON ci.campaign_id = camp.sfdc_campaign_id 
WHERE camp.name = 'Russian Sanctions')




select PS_Dim.forecast_month effective_date, dt.week_number_in_fiscal_month, dt.fiscal_month, dt.dow, dt.month_num, PS_Dim.net_change net_change_revenue, PS_Dim.currency_iso_code, PS_Dim.one_time_charge, Comp_Dim.company_name, PS_Dim.stage,
Opp_Dim.opportunity_number, Opp_Dim.pib_opportunity_sfdc_id, Opp_Owner.user_full_name opp_owner, Terr_Dim.territory_name, Opp_Dim.sale_type, Opp_Dim.source_type, Opp_Dim.r_c_proposition, PS_Dim.product_service, Terr_Owner.user_full_name territory_owner,
Terr_Dim.territory_roll_up VP, Terr_RSD.user_full_name RSD, Specialist.user_full_name as specialist, Terr_Dim.region_code, PS_Dim.adjusted_effective_date, PS_Dim.override_forecast_date,
cast(Opp_Dim.cycle_date as date) opp_cycle_date, cast(PS_Dim.cycle_date as date) ps_cycle_date, PS_Dim.net_recurring_amount, PS_Dim.net_one_time_amount, Opp_Dim.pipeline_category,
(case when (Opp_Dim.pipeline_category = 'Pipeline' and in_forecast = 'True') then 'Pipeline (in forecast)'  
when (Opp_Dim.pipeline_category = 'Pipeline' and (in_forecast = 'False' or in_forecast is null)) then 'Pipeline (not in forecast)'
else Opp_Dim.pipeline_category end) pipeline_category2, 


Opp_Dim.created_date,
Opp_Dim.opportunity_closed_date,
Opp_Dim.total_one_time_revenue, Opp_Dim.probability_percentage, Opp_Dim.in_forecast, PS_Dim.product_line, PS_Dim.sfdc_product_services_id, PS_Dim.status_flag, Prod.bu, 
Prod.product_line as prod_line, Opp_Dim.annualized_opportunity_revenue, Curr_Rates.rate,
user_dim.user_full_name pib_ntc_owner,
user2_dim.user_full_name focus_owner,
Comp_Dim.company_country,
Comp_Dim.company_industry,
Comp_dim.mm_quadrant,
Comp_dim.r_c_rating,
Comp_dim.sales_campaign_s,
ld.lead_source,
mql.mq_date,

CASE WHEN camp_russian_sanctions.name = 'Russian Sanctions' THEN TRUE ELSE FALSE END AS Russian_Sanctions_Assn 


from Opp_Dim

left join PS_Dim on Opp_dim.pib_opportunity_sfdc_id = PS_Dim.opportunity
inner join Comp_Dim on Opp_Dim.account_id = Comp_dim.company_sfdc_id  
inner join Terr_Dim on Opp_Dim.opportunity_territory = Terr_Dim.territory_sfdc_id
left join Opp_Owner on Opp_Dim.opportunity_owner = Opp_Owner.user_sfdc_id
left join Terr_Owner on Terr_Dim.territory_owner = Terr_Owner.user_sfdc_id
left join Terr_RSD on Terr_Dim.regional_sales_director = Terr_RSD.user_sfdc_id 
left join Curr_Rates on PS_Dim.currency_iso_code = Curr_Rates.currency
left join user2_dim on Comp_Dim.pib_focus_owner = user2_dim.user_sfdc_id
left join user_dim on Comp_Dim.ntc_owner = user_dim.user_sfdc_id
left join Specialist on PS_Dim.specialist = Specialist.user_sfdc_id 
left join Prod on PS_Dim.product_service = Prod.sfdc_product
left join dimension_external_db.pib_leads_dimension ld on Opp_Dim.pib_opportunity_sfdc_id = ld.converted_opportunity_id
left join mql on ld.lead_sfdc_id = mql.lead_sfdc_id
left join camp_russian_sanctions on Opp_Dim.pib_opportunity_sfdc_id = camp_russian_sanctions.opportunity_id
left join dt on PS_Dim.forecast_month = dt.date 

where territory_name not like '%Consumer%'
and territory_name not like '%Pro Hunter%'
and territory_name not like '%Choice%'
and territory_name not like '%Proquest%'
and territory_name not like '%Partners%'
and territory_name not like '%Pro SI Territory%'
and territory_name not like '%FNPEN%'
--and opportunity_number = 1840011
and PS_Dim.forecast_month >> date_add('month',-14, date_add('day',-day(current_date), DATE(current_date)))
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53
order by opportunity_number, (net_recurring_amount + net_one_time_amount) desc )


select a.*, max(case when specialist is not null then (net_recurring_amount + net_one_time_amount) end) over (partition by opportunity_number, opp_cycle_date, ps_cycle_date) as TEST
from a)
--where opp_cycle_date >>= cast('2023-08-01' as date))

select main.*, (case when (net_recurring_amount + net_one_time_amount) = TEST then specialist end) as spec
from main
order by ps_cycle_date, (net_recurring_amount + net_one_time_amount) desc)

select maxe.*,  coalesce (spec, lag(spec,1) ignore nulls over (partition by opportunity_number, opp_cycle_date order by ps_cycle_date, (net_recurring_amount + net_one_time_amount) desc)) as Specialist1
from maxe),

x as (
with 
opps as
(select cycle_date, opportunity_number, in_forecast from dimension_external_db.pib_opportunity_dimension_history
union ALL
select cast(etl_processed_date as date) cycle_date, opportunity_number, in_forecast  from dimension_external_db.pib_opportunity_dimension
order by opportunity_number, cycle_date),

base as 
(select cycle_date, opportunity_number, in_forecast, lag(in_forecast,1) over(PARTITION BY opportunity_number order by cycle_date) as prob_lag, 
case when (in_forecast <<>> lag(in_forecast,1) over(PARTITION BY opportunity_number order by cycle_date)) or lag(in_forecast,1) over(PARTITION BY opportunity_number order by cycle_date) is null then cycle_date else
null end as test  from opps
),

new_cycle as
(select cycle_date, opportunity_number, in_forecast, coalesce (test, lag(test,1) IGNORE NULLS OVER (PARTITION BY opportunity_number ORDER BY cycle_date)) res
from base)

select new_cycle.cycle_date, new_cycle.opportunity_number, new_cycle.in_forecast as in_forecast1, cast(substring(cast((cycle_date - res) as varchar), 1, strpos(cast((cycle_date - res) as varchar),':')-4) as INTEGER) as in_forecast_days
from new_cycle
where cycle_date >> date_add('month', -24, date_add('day',-day(current_date), DATE(current_date)))),

y as (
with 
opps as
(select cycle_date, opportunity_number, pipeline_category, opportunity_effective_date from dimension_external_db.pib_opportunity_dimension_history),

base as 
(select cycle_date, opportunity_number, pipeline_category , lag(pipeline_category ,1) over(PARTITION BY opportunity_number order by cycle_date) as prob_lag, 
case when (pipeline_category  <<>> lag(pipeline_category ,1) over(PARTITION BY opportunity_number order by cycle_date)) or lag(pipeline_category ,1) over(PARTITION BY opportunity_number order by cycle_date) is null then cycle_date else
null end as test, opportunity_effective_date,
lag(opportunity_effective_date,1) over(PARTITION BY opportunity_number order by cycle_date) as ed_lag

from opps),

new_cycle as
(select cycle_date, opportunity_number, pipeline_category, coalesce (test, lag(test,1) IGNORE NULLS OVER (PARTITION BY opportunity_number ORDER BY cycle_date)) res,
opportunity_effective_date, ed_lag
from base),

base2  as 
(select new_cycle.cycle_date, new_cycle.opportunity_number, new_cycle.pipeline_category , cast(substring(cast((cycle_date - res) as varchar), 1, strpos(cast((cycle_date - res) as varchar),':')-4) as INTEGER) as pipe_days, opportunity_effective_date, ed_lag,
cast(CONCAT(substring(cast(opportunity_effective_date as varchar),1,4),substring(cast(opportunity_effective_date as varchar),6,2)) as integer) MonthInt,
cast(CONCAT(substring(cast(ed_lag as varchar),1,4),substring(cast(ed_lag as varchar),6,2)) as integer) MonthIntLag
from new_cycle)

select cycle_date, opportunity_number, pipeline_category as pipe_category, pipe_days, opportunity_effective_date, ed_lag, MonthInt, MonthIntLag,      
(case when MonthInt >> MonthIntLag then 1 else 0 end) as push,
(case when MonthInt << MonthIntLag then 1 else 0 end) as pull,
SUM(case when MonthInt >> MonthIntLag then 1 else 0 end) over  (partition by opportunity_number order by cycle_date rows unbounded preceding ) as push_running_tot,
SUM(case when MonthInt << MonthIntLag then 1 else 0 end) over  (partition by opportunity_number order by cycle_date rows unbounded preceding  ) as pull_running_tot
from base2
where cycle_date >> date_add('month', -24, date_add('day',-day(current_date), DATE(current_date)))),

z as (
with 

opps as
(select cycle_date, opportunity_number,probability_percentage from dimension_external_db.pib_opportunity_dimension_history
union ALL
select cast(etl_processed_date as date) cycle_date, opportunity_number, probability_percentage  from dimension_external_db.pib_opportunity_dimension
order by opportunity_number, cycle_date),

base as 
(select cycle_date, opportunity_number, probability_percentage, lag(probability_percentage,1) over(PARTITION BY opportunity_number order by cycle_date) as prob_lag, 
case when (probability_percentage <<>> lag(probability_percentage,1) over(PARTITION BY opportunity_number order by cycle_date)) or lag(probability_percentage,1) over(PARTITION BY opportunity_number order by cycle_date) is null then cycle_date else
null end as test  from opps
),

new_cycle as
(select cycle_date, opportunity_number, probability_percentage, coalesce (test, lag(test,1) IGNORE NULLS OVER (PARTITION BY opportunity_number ORDER BY cycle_date)) res
from base)

select new_cycle.cycle_date, new_cycle.opportunity_number, new_cycle.probability_percentage as prob_pct, cast(substring(cast((cycle_date - res) as varchar), 1, strpos(cast((cycle_date - res) as varchar),':')-4) as INTEGER)  as pct_days
from new_cycle
where cycle_date >> date_add('month', -24, date_add('day',-day(current_date), DATE(current_date)))),

m as 

(select
pib_opportunity_sfdc_id,
count(distinct sfdc_id) mtg_count_90
from dimension_external_db.pib_meeting_summary meet
where meeting_date >>= date_add('day', -90, current_date)
group by 1),

n as
(select pib_opportunity_sfdc_id, cast(substring(cast((current_date - last_meeting) as varchar), 1, strpos(cast((current_date - last_meeting) as varchar),':')-4) as INTEGER) as days_last_mtg from

(select pib_opportunity_sfdc_id,
max(meeting_date) as last_meeting
from dimension_external_db.pib_meeting_summary meet
where meeting_date >>= date_add('day', -730, current_date)
group by 1))


select p.*, x.in_forecast1, x.in_forecast_days, 
y.pipe_category, y.pipe_days, y.opportunity_effective_date, y.ed_lag, y.push, y.pull, y.push_running_tot, y.pull_running_tot, z.prob_pct, z.pct_days,
n.days_last_mtg, m.mtg_count_90
from p
left join x on p.opportunity_number = x.opportunity_number and p.opp_cycle_date = x.cycle_date
left join y on p.opportunity_number = y.opportunity_number and p.opp_cycle_date = y.cycle_date
left join z on p.opportunity_number = z.opportunity_number and p.opp_cycle_date = z.cycle_date
left join m on p.pib_opportunity_sfdc_id = m.pib_opportunity_sfdc_id
left join n on p.pib_opportunity_sfdc_id = n.pib_opportunity_sfdc_id
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,
29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70                                    
