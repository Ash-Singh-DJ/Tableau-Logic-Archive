-- Dashboard   : "C-Suite CCO Council Project"  [B2B / WSJ Professional Membership / C-Suite Membership]
-- Data source : "Campaign Influence" = published source "CCO Membership Campaign Influence"  [B2B / WSJ Professional Membership / C-Suite Membership / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query1"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
select pib_opportunity_sfdc_id, 
opportunity_name, 
sales_stage,  
open_date, 
marketing_tactic, 
contact_email, 
contact_name, 
contact_phone, 
owner_full_name, 
win_status_flag, 
closed_flag, 
closed_won_date, 
opp.created_date as opportunity_created_date,
case when psd.currency_iso_code='USD' then net_recurring_amount else (psd.net_recurring_amount/ fx.rate)*12 end as annualized_recurring_amount, 
case when psd.currency_iso_code='USD' then psd.net_one_time_amount else (psd.net_one_time_amount/fx.rate) end as net_one_time_amount, 
case when  psd.currency_iso_code='USD' then  psd.net_recurring_amount*12 + psd.net_one_time_amount else (psd.net_recurring_amount/ fx.rate)*12 +(psd.net_one_time_amount/fx.rate) end as annual_amount, 
psd.product_service, 
psd.net_amount/fx.rate net_amount
from dimension_external_db.pib_opportunity_dimension opp
left join dimension_external_db.pib_product_services_dimension psd on opp.pib_opportunity_sfdc_id = psd.opportunity
left join reference_external_db.fx_rates_current fx on psd.currency_iso_code=fx.currency
where opp.status_flag <<>> 'DELETE' and psd.status_flag <<>> 'DELETE'
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18
