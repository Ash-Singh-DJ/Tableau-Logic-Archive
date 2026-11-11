-- Dashboard   : "C-Suite CCO Council Project"  [B2B / WSJ Professional Membership / C-Suite Membership]
-- Data source : "Custom SQL Query+ (sandbox_pecom)" = published source "CCO Datasource"  [B2B / WSJ Professional Membership / C-Suite Membership / Data Sources]
-- Relation    : Custom SQL "opp_rev_data"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH
  opportunities AS (
   SELECT
     pib_opportunity_sfdc_id
   , account_id
   , billing_account
   , sale_type
   , sales_stage
   , pipeline_category
   , probability_percentage
   , opportunity_owner
   , opportunity_territory
   , annualized_opportunity_revenue
   , created_date
   , open_date
   , closed_won_date
   , opportunity_effective_date
   , opportunity_country
   , closed_flag
   , win_status_flag
   , opportunity_closed_date
   FROM
     dimension_external_db.pib_opportunity_dimension
   WHERE opportunity_effective_date >>= date(concat(CAST(YEAR(current_date) AS varchar), '-', CAST(MONTH(current_date) AS varchar), '-01'))
 AND (created_date << current_date) AND ((created_date >>= date('2023-07-01'))  AND (NOT (lower(sale_type) LIKE '%cancel%')) AND (NOT (lower(sale_type) LIKE '%downsell%')) AND (NOT (lower(sale_type) LIKE '%neutral%')) AND (sale_type IN ('Upsell - Existing Contract', 'New Contract/Existing Customer', 'Rev Increase Existing Contract', 'Upsell - New Contract', 'New To Company')))
) 
, product_services AS (
   SELECT
     opportunity
   , product_line
   , COALESCE(product_service, 'No Product Service') product_service
   , product_category
   , one_time_charge
   , COALESCE((net_recurring_amount / fx.rate), 0) net_recurring_amount
   , COALESCE((net_one_time_amount / fx.rate), 0) net_one_time_amount
   , currency_iso_code
   FROM
     (dimension_external_db.pib_product_services_dimension psda
   LEFT JOIN reference_external_db.fx_rates_current fx ON (psda.currency_iso_code = fx.currency))
   WHERE (status_flag <<>> 'DELETE')
) , def_opps as(
SELECT DISTINCT
cast('Opportunities' as varchar) data_type
 , opp.pib_opportunity_sfdc_id opp_crm_id
, 'PIB Salesforce' sourced_from
, bil.cibs_billing_account_id b2b_acct_id
, ter.territory_name
, (CASE WHEN (lower(ter.territory_name) LIKE '%wsj%') THEN bil.salesforce_territory_owner ELSE usr.user_full_name END) account_owner
, sale_type
, opp.opportunity_effective_date
, (CASE WHEN (psd.product_line = 'WSJ Corp') THEN 'WSJ Corporate' ELSE psd.product_line END) product_line
, psd.product_service
, psd.product_category
, net_recurring_amount recurring_revenue
,  net_one_time_amount non_recurring_revenue
, (psd.net_one_time_amount + (12 * psd.net_recurring_amount)) annual_amount
, comp.company_sfdc_id
, comp.company_name company_crm_name
, comp.parent_sfdc_id
, COALESCE(comp.duns, '999999999') duns_n
, opp.probability_percentage
, opp.closed_flag
, date(opp.opportunity_closed_date) opportunity_closed_date
, closed_won_date opportunity_won_date
, opp.created_date opportunity_created_date
, opp.win_status_flag

FROM
  (((((opportunities opp
LEFT JOIN product_services psd ON (opp.pib_opportunity_sfdc_id = psd.opportunity))
LEFT JOIN dimension_external_db.pib_company_dimension comp ON (opp.account_id = comp.company_sfdc_id))
LEFT JOIN dimension_external_db.pib_billing_account_dimension bil ON (opp.billing_account = bil.salesforce_billing_account_id))
LEFT JOIN dimension_external_db.pib_territory_dimension ter ON (opp.opportunity_territory = ter.territory_sfdc_id))
LEFT JOIN dimension_external_db.pib_user_dimension usr ON (ter.territory_owner = usr.user_sfdc_id))
WHERE ((psd.product_line IN ('WSJ C-Suites','Risk & Compliance', 'WSJ Corp')) AND ((psd.net_one_time_amount + (12 * psd.net_recurring_amount)) >> 0) AND (NOT (comp.company_name IN ('Factiva xx', 'ZZZ Internal Factiva Accounts-Admin Portal'))) AND (NOT (lower(ter.territory_name) LIKE '%fnpen%')) AND (NOT (lower(ter.territory_name) LIKE '%proquest%')) AND (NOT (lower(ter.territory_name) LIKE '%bd%')) AND (NOT (lower(ter.territory_name) LIKE '%media sales%')))
), 
  max_date AS (
   SELECT max(date) maxdate
   FROM
     sandbox_hvc.date_alignment
) ,
revenue as (
select 
cast('Revenue' as varchar) data_type
, cast (null as varchar) opp_crm_id
,sourced_from 
, billing_account_number
, ter.territory_name
, (CASE WHEN (lower(ter.territory_name) LIKE '%wsj%') THEN bil.salesforce_territory_owner ELSE usr.user_full_name END) account_owner
, cast(null as varchar) sale_type
, cast(null as date) opportunity_effective_date
, brand
, product_group
, product product_service
, sum((CASE WHEN ((tm1.period = 'CP') AND (tm1.cycle_date = (SELECT maxdate
FROM
  max_date
))) THEN (12 * monthly_recurring_revenue) ELSE 0 END)) recurring_revenue
   , sum((CASE WHEN (tm1.period = 'CP') THEN monthly_non_recurring_revenue ELSE 0 END)) non_recurring_revenue
   , sum((CASE WHEN ((tm1.period = 'CP') AND (tm1.cycle_date = (SELECT maxdate
FROM
  max_date
))) THEN ((12 * monthly_recurring_revenue) + monthly_non_recurring_revenue) WHEN (tm1.period = 'CP') THEN monthly_non_recurring_revenue ELSE 0 END)) annualized_revenue
, comp.company_sfdc_id
, comp.company_name company_crm_name
, comp.parent_sfdc_id
, COALESCE(comp.duns, '999999999') duns_n
, cast( null as int) probability_percentage
, cast(null as boolean) closed_flag
, cast(null as date) opportunity_closed_date
, cast(null as date) opportunity_won_date
, cast(null as date) opportunity_created_date
, cast(null as boolean) won_flag
from
sandbox_hvc.rev_b2b tm1
LEFT JOIN dimension_external_db.pib_billing_account_dimension bil ON (tm1.billing_account_number = bil.cibs_billing_account_id)
LEFT JOIN dimension_external_db.pib_company_dimension comp on bil.salesforce_company_two = comp.company_sfdc_id
LEFT JOIN dimension_external_db.pib_territory_dimension ter ON (comp.company_territory = ter.territory_sfdc_id)
LEFT JOIN dimension_external_db.pib_user_dimension usr ON (ter.territory_owner = usr.user_sfdc_id)
where brand='Risk & Compliance'
group by 1,2,3,4,5,6,7,8,9,10,11,15,16,17,18,19
), 
opp_rev as (
select distinct
cast('C-Suite Revenue' as varchar) data_type
 , opp.pib_opportunity_sfdc_id opp_crm_id
, 'PIB Salesforce' sourced_from
, bil.cibs_billing_account_id b2b_acct_id
, ter.territory_name
, (CASE WHEN (lower(ter.territory_name) LIKE '%wsj%') THEN bil.salesforce_territory_owner ELSE usr.user_full_name END) account_owner
, sale_type
, opp.opportunity_effective_date
, (CASE WHEN (psda.product_line = 'WSJ Corp') THEN 'WSJ Corporate' ELSE psda.product_line END) product_line
, psda.product_service
, psda.product_category
, net_recurring_amount recurring_revenue
,  net_one_time_amount non_recurring_revenue
, (psda.net_one_time_amount + (12 * psda.net_recurring_amount)) annual_amount
, comp.company_sfdc_id
, comp.company_name company_crm_name
, comp.parent_sfdc_id
, COALESCE(comp.duns, '999999999') duns_n
, opp.probability_percentage
, opp.closed_flag
, date(opp.opportunity_closed_date) opportunity_closed_date
, closed_won_date opportunity_won_date
, opp.created_date opportunity_created_date
, opp.win_status_flag
from dimension_external_db.pib_opportunity_dimension opp 
left join dimension_external_db.pib_product_services_dimension psda on opp.pib_opportunity_sfdc_id= psda.opportunity
   LEFT JOIN reference_external_db.fx_rates_current fx ON (psda.currency_iso_code = fx.currency)
LEFT JOIN dimension_external_db.pib_billing_account_dimension bil ON (opp.billing_account = bil.salesforce_billing_account_id)
LEFT JOIN dimension_external_db.pib_territory_dimension ter ON (opp.opportunity_territory = ter.territory_sfdc_id)
LEFT JOIN dimension_external_db.pib_user_dimension usr ON (ter.territory_owner = usr.user_sfdc_id)
LEFT JOIN dimension_external_db.pib_company_dimension comp ON (opp.account_id = comp.company_sfdc_id)
 WHERE (psda.product_line IN ('WSJ C-Suites','Risk & Compliance', 'WSJ Corp')) AND ((psda.net_one_time_amount + (12 * psda.net_recurring_amount)) >> 0) AND (NOT (comp.company_name IN ('Factiva xx', 'ZZZ Internal Factiva Accounts-Admin Portal'))) AND (NOT (lower(ter.territory_name) LIKE '%fnpen%')) AND (NOT (lower(ter.territory_name) LIKE '%proquest%')) AND NOT (lower(ter.territory_name) LIKE '%bd%') AND NOT lower(ter.territory_name) LIKE '%media sales%'

and (win_status_flag=True or closed_won_date is not null)
and  date_diff('day', CAST(contract_effective_Date AS date), current_date) <<= 365
and product_category='Conferences'
), 
def as (
select * from def_opps
union all
select * from revenue
union all 
select * from opp_rev)

select distinct def.*, prod.*,
 comp.primary_name, 
link.global_ultimate_duns, 
link.global_ultimate_primary_name ,
pc.corporate_name , 
pc.corporate_sfdc_id

from def
left join sandbox_hvc.prod_master prod on def.product_service=prod.product_name
left join dnb_firmographic_db.company_information_current comp on def.duns_n=comp.duns_number
left join dnb_firmographic_db.corporate_linkage_current link on def.duns_n=link.duns_number
left join (select 	distinct
corporate_sfdc_id,
corporate_name
from dimension_external_db.pib_corporate_dimension) pc on def.parent_sfdc_id=pc.corporate_sfdc_id
where product_service not like '%WSJ%' and product_service not like '%Barron%'
