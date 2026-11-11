-- Published data source : "Eloqua Forms UTM analysis"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "opportunities"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH opps AS (
SELECT
        comp.company_sfdc_id,
        comp.company_name,
        comp.company_industry,
        comp.company_country,
        opp.pib_opportunity_sfdc_id,
        opp.opportunity_number,
        opp.opportunity_name,
        oud.user_full_name AS opp_owner,
        DATE_TRUNC('day', opp.created_date) AS opportunity_created_date,
        DATE_TRUNC('day', opp.open_date) AS opportunity_open_date,
        opp.sales_stage,
        opp.sale_type,
        opp.closed_won_date,
        DATE(opp.opportunity_closed_date) AS opp_closed_date,
        opp.win_status_flag,
        opp_td.territory_name AS opportunity_territory_name,
        comp_td.territory_name AS company_territory_name,
        opp_td.sales_region AS opportunity_sales_region,
        comp_td.sales_region AS company_sales_region,
        opp_td.region_code AS opportunity_region_code,
        comp_td.region_code AS company_region_code,
        opp_contact.contact_sfdc_id AS opp_contact_sfdc_id,
        opp_contact.contact_full_name AS opp_pc_contact_name,
        opp_contact.lead_source AS opp_pc_lead_source,
        opp_contact.content_type AS opp_pc_content_type,
        opp_contact.marketing_tactic_original AS opp_pc_marketing_tactic_original,
        opp_contact.marketing_tactic_most_recent AS opp_pc_marketing_tactic_most_recent,
        opp_contact.buying_center AS opp_pc_buying_center,
        ps_dim.product_line AS sf_product_line,
        ps_dim.product_service AS sf_product_service,
        ps_dim.product_category AS sf_product_category,
        ps_dim.currency_iso_code,
        ps_dim.net_amount / fx.rate AS net_amount,
        ps_dim.net_one_time_amount / fx.rate AS net_one_time_account,
        ps_dim.net_recurring_amount / fx.rate AS net_recurring_amount,
        (ps_dim.net_one_time_amount + ps_dim.net_recurring_amount * 12) / fx.rate AS annualized_opportunity_value,
        ps_dim.sfdc_product_services_id,
        ps_dim.product_service,
        ps_dim.product_line,
        ps_dim.product_category, 
        opp.cycle_date,
opp.web_form_name
    FROM
        (SELECT * FROM dimension_external_db.pib_opportunity_dimension_history WHERE status_flag <<>> 'DELETE') opp
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_company_dimension WHERE status_flag <<>> 'DELETE') comp ON opp.account_id = comp.company_sfdc_id
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') opp_td ON opp.opportunity_territory = opp_td.territory_sfdc_id
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_user_dimension WHERE status_flag <<>> 'DELETE') oud ON opp.opportunity_owner = oud.user_sfdc_id
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_territory_dimension WHERE status_flag <<>> 'DELETE') comp_td ON comp.company_territory = comp_td.territory_sfdc_id
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') ps_dim ON opp.pib_opportunity_sfdc_id = ps_dim.opportunity
    LEFT JOIN reference_external_db.fx_rates_current fx ON ps_dim.currency_iso_code = fx.currency
    LEFT JOIN (SELECT * FROM dimension_external_db.pib_contact_dimension WHERE status_flag <<>> 'DELETE') opp_contact ON opp.primary_contact = opp_contact.contact_sfdc_id
    WHERE
        ps_dim.product_line <<>> 'FN/PEN' and opp.created_date>>=date('2024-07-01'))
        , 
        
      max_opp_previous_fy AS (
    SELECT
        pib_opportunity_sfdc_id,
        MAX(cycle_date) AS max_cycle_date
    FROM
        opps
    WHERE
        cycle_date <<= DATE_ADD('year', -1, CURRENT_DATE)
        AND cycle_date>>= date('2024-07-01')
        AND opportunity_created_date <<= DATE_ADD('year', -1, CURRENT_DATE)
    GROUP BY
        pib_opportunity_sfdc_id
)
, 
previous_fy_snapshot AS (
SELECT opps.*, 
CAST ('YoY' AS varchar) snapshot_category

FROM max_opp_previous_fy mx
LEFT JOIN opps ON (mx.pib_opportunity_sfdc_id= opps.pib_opportunity_sfdc_id AND mx.max_cycle_date=opps.cycle_date)

), 

max_opp_current_fy as( SELECT
        pib_opportunity_sfdc_id,
        MAX(cycle_date) AS max_cycle_date
    FROM
        opps
    WHERE
        cycle_date <<= CURRENT_DATE
        AND cycle_date>>= date('2025-07-01')
        AND opportunity_created_date >>= date('2025-07-01')
    GROUP BY
        pib_opportunity_sfdc_id)
        
        , 
        
   current_fy_snapshot AS (
SELECT opps.*, 
CAST ('YoY' AS varchar) snapshot_category

FROM max_opp_current_fy mx
LEFT JOIN opps ON (mx.pib_opportunity_sfdc_id= opps.pib_opportunity_sfdc_id AND mx.max_cycle_date=opps.cycle_date)
     
), 

all_time_max AS (SELECT
        pib_opportunity_sfdc_id,
        MAX(cycle_date) AS max_cycle_date
    FROM
        opps 
    group by 1),

    all_time AS (
SELECT opps.*, 
CAST ('All time' AS varchar) snapshot_category

FROM all_time_max mx
LEFT JOIN opps ON (mx.pib_opportunity_sfdc_id= opps.pib_opportunity_sfdc_id AND mx.max_cycle_date =opps.cycle_date)
     
)

SELECT * FROM all_time
UNION ALL
SELECT * FROM current_fy_snapshot
UNION ALL 
SELECT * FROM previous_fy_snapshot
