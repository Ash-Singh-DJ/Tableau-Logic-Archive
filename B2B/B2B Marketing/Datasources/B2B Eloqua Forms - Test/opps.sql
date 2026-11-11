-- Published data source : "B2B Eloqua Forms - Test"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "opps"
-- Connection  : Athena (AwsDataCatalog / sandbox_pecom), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH
  fx AS (
   WITH
     current_fx AS (
      SELECT
        fx_c.*
      , CAST('2025' AS VARCHAR) "year"
      FROM
        reference_external_db.fx_rates_current fx_c
   ) 
   SELECT *
   FROM
     reference_external_db.fx_rates_history
UNION ALL    SELECT *
   FROM
     current_fx
) 
, opportunities AS (
   SELECT
     pib_opportunity_sfdc_id
   , cycle_date
   , account_id
   ,(CASE
    WHEN cycle_date >>= DATE('2025-07-01') AND cycle_date <<= DATE('2026-06-30') THEN '2026'
    WHEN cycle_date >>= DATE('2024-07-01') AND cycle_date <<= DATE('2025-06-30') THEN '2025'
    WHEN cycle_date >>= DATE('2023-07-01') AND cycle_date <<= DATE('2024-06-30') THEN '2024'
    WHEN cycle_date >>= DATE('2022-07-01') AND cycle_date <<= DATE('2023-06-30') THEN '2023'
    WHEN cycle_date >>= DATE('2021-07-01') AND cycle_date <<= DATE('2022-06-30') THEN '2022'
    ELSE 'Other' -- It's good practice to have an ELSE for un-matched rows
END) AS fy_cycle_date
   , billing_account
   , sale_type
   , sales_stage
   , pipeline_category
   , probability_percentage
   , opportunity_owner
   , opportunity_territory
   , created_date
   , open_date
   , primary_contact
   , closed_won_date
   , opportunity_effective_date
   , opportunity_country
   , closed_flag
   , win_status_flag
   , opportunity_closed_date
   , contract_effective_date
   FROM
     dimension_external_db.pib_opportunity_dimension_history hist
   WHERE created_date >>= date('2024-07-01')
) 
, fy AS (
   SELECT
     opportunity
   , cycle_date
   , (CASE WHEN cycle_date>>=DATE('2025-07-01') AND cycle_date<<=DATE('2026-06-30') THEN '2026'  WHEN ((cycle_date >>= DATE('2024-07-01')) AND (cycle_date <<= DATE('2025-06-30'))) THEN '2025' WHEN ((cycle_date >>= DATE('2023-07-01')) AND (cycle_date <<= DATE('2024-06-30'))) THEN '2024' WHEN ((cycle_date >>= DATE('2022-07-01')) AND (cycle_date <<= DATE('2023-06-30'))) THEN '2023' WHEN ((cycle_date >>= DATE('2021-07-01')) AND (cycle_date <<= DATE('2022-06-30'))) THEN '2022' END) fy_cycle_date
   FROM
     dimension_external_db.pib_product_services_dimension_history
) 
, product_services AS (
   SELECT DISTINCT
     psda.opportunity
   , psda.cycle_date
   , fy.fy_cycle_date
   , product_line
   , COALESCE(product_service, 'No Product Service') product_service
   , product_category
   , one_time_charge
   , COALESCE((net_recurring_amount / fx.rate), 0) net_recurring_amount
   , COALESCE((net_one_time_amount / fx.rate), 0) net_one_time_amount
   , currency_iso_code
   FROM
     ((dimension_external_db.pib_product_services_dimension_history psda
   LEFT JOIN fy ON ((psda.opportunity = fy.opportunity) AND (psda.cycle_date = fy.cycle_date)))
   LEFT JOIN fx ON ((psda.currency_iso_code = fx.currency) AND (fy.fy_cycle_date = fx."year")))
   WHERE (status_flag <<>> 'DELETE')
) 
, prod_override AS (
   SELECT
     high_level
   , mapping
   , regexp_extract(product, '[A-Z]+ - (.+)', 1) product_name
   FROM
     sandbox_hvc.ftva_prod_override
   WHERE (NOT (product IN ('FTVA - Risk Database Premium', 'FTVA - Risk Agent Fees')))
UNION ALL    SELECT
     high_level
   , mapping
   , regexp_extract(product, '[A-Z]+ - (.+)', 1) product_name
   FROM
     sandbox_hvc.nwrs_prod_override
UNION ALL    SELECT
     high_level
   , mapping
   , regexp_extract(product, '[A-Z]+ - (.+)', 1) product_name
   FROM
     sandbox_hvc.rnc_prod_override
) 
, prod_name_swap AS (
   SELECT DISTINCT
     COALESCE(tm1_name, product) tm1_prod
   , cibs_id
   , psa.product_service
   FROM
     (fact_external_db.tm1_fact tm1
   LEFT JOIN dimension_external_db.pib_product_service_attributes psa ON (tm1.cibs_id = psa.billing_code))
   WHERE ((tm1.cibs_id IS NOT NULL) AND (tm1.cycle_date >>= date('2023-07-01')))
) 
, product_joiner AS (
   SELECT
     ps.*
   , po.mapping
   , po.high_level
   FROM
     (prod_name_swap ps
   LEFT JOIN prod_override po ON (ps.tm1_prod = po.product_name))
) 
SELECT DISTINCT
  opp.pib_opportunity_sfdc_id opp_crm_id
, opp.account_id
, opp.primary_contact
, opp.cycle_date
, opp.fy_cycle_date
, opp.created_date
, opp.opportunity_closed_date
, opp.win_status_flag
, opp.closed_won_date
, bil.cibs_billing_account_id b2b_acct_id
, ter.territory_name
, (CASE WHEN (lower(ter.territory_name) LIKE '%wsj%') THEN bil.salesforce_territory_owner ELSE usr.user_full_name END) account_owner
, opp.sale_type
, CASE WHEN (sales_stage in ( 'Lost - 0%', 'Lost Opportunity', 'Los Opportunity') or (closed_flag=true and win_status_flag=false)) then 'Lost Opportunity'
when (closed_flag=true and win_status_flag=True) then 'Won Opportunity' else opp.sales_stage end sales_stage
, opp.opportunity_effective_date
, opp.contract_effective_date
, opp.closed_flag
, (CASE WHEN (psd.product_line = 'WSJ Corp') THEN 'WSJ Corporate' ELSE psd.product_line END) product_line
, COALESCE(pj.tm1_prod, psd.product_service) product_service
, psd.product_category
, COALESCE(pj.mapping, 'Other') mapping
, COALESCE(pj.high_level, 'Other') high_level
, (CASE WHEN ((probability_percentage >> 0) AND (probability_percentage << 100) AND (closed_flag = false)) THEN 'open' WHEN (((probability_percentage = 0) OR (probability_percentage = 100)) AND (closed_flag = true)) THEN 'closed' ELSE 'other' END) opportunity_status
, (psd.net_one_time_amount + (12 * psd.net_recurring_amount)) annualized_opportunity
, comp.company_sfdc_id
, comp.company_name company_crm_name
, COALESCE(comp.duns, '999999999') duns_n
FROM
  ((((((opportunities opp
LEFT JOIN product_services psd ON ((opp.pib_opportunity_sfdc_id = psd.opportunity) AND (opp.cycle_date = psd.cycle_date)))
LEFT JOIN product_joiner pj ON (psd.product_service = pj.product_service))
LEFT JOIN dimension_external_db.pib_company_dimension comp ON (opp.account_id = comp.company_sfdc_id))
LEFT JOIN dimension_external_db.pib_billing_account_dimension bil ON (opp.billing_account = bil.salesforce_billing_account_id))
LEFT JOIN dimension_external_db.pib_territory_dimension ter ON (opp.opportunity_territory = ter.territory_sfdc_id))
LEFT JOIN dimension_external_db.pib_user_dimension usr ON (ter.territory_owner = usr.user_sfdc_id))
WHERE ( (NOT (comp.company_name IN ('Factiva xx', 'ZZZ Internal Factiva Accounts-Admin Portal'))) AND (NOT (lower(ter.territory_name) LIKE '%fnpen%')) AND (NOT (lower(ter.territory_name) LIKE '%proquest%')) AND (NOT (lower(ter.territory_name) LIKE '%bd%')) AND (NOT (lower(ter.territory_name) LIKE '%media sales%')) AND (opp.fy_cycle_date IN ('2025', '2026')))
