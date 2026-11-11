-- Published data source : "B2B Lattice Lead Data"  [B2B / B2B Marketing / Datasources]
-- Relation    : Custom SQL "Custom SQL Query1"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT opp.pib_opportunity_sfdc_id, opp.opportunity_name, opp.opportunity_number,
       DATE_TRUNC('day',opp.created_date) opportunity_created_date,
       DATE_TRUNC('day',opp.open_date) opportunity_open_date,
       opp.sales_stage,
       opp.sale_type,
       opp.closed_won_date,
       DATE(opp.opportunity_closed_date) AS opp_closed_date,
       opp.win_status_flag,
       opp.annualized_opportunity_revenue,
       ps_dim.product_line AS sf_product_line,
       ps_dim.product_service AS sf_product_service,
       ps_dim.product_category AS sf_product_category,
       ps_dim.currency_iso_code,
       ps_dim.net_amount,
       ps_dim.net_one_time_amount,
       ps_dim.net_recurring_amount,
       fx.rate,
       ps_dim.forecast_month,
       ps_dim.sfdc_product_services_id,
       pd.master_product AS pd_master_product,
       pd.product_line AS pd_product_line,
       pd.bu AS pd_bu
FROM (SELECT * FROM dimension_external_db.pib_opportunity_dimension WHERE status_flag <<>> 'DELETE') opp
LEFT JOIN (SELECT * FROM dimension_external_db.pib_product_services_dimension WHERE status_flag <<>> 'DELETE') ps_dim ON opp.pib_opportunity_sfdc_id = ps_dim.opportunity
LEFT JOIN reference_external_db.pib_product_dimension pd ON ps_dim.product_service = pd.sfdc_product 
LEFT JOIN reference_external_db.fx_rates_current fx ON ps_dim.currency_iso_code = fx.currency
