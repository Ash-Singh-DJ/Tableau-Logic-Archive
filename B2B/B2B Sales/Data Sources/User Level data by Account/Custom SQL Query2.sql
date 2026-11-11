-- Published data source : "User Level data by Account"  [B2B / B2B Sales / Data Sources]
-- Relation    : Custom SQL "Custom SQL Query2"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH 
classic_factiva AS (
  SELECT 
    SUBSTRING(CAST(cycle_date AS VARCHAR), 1, 10) AS year_month_date,
    post_evar3 AS eid, 
    COUNT(DISTINCT ip) AS ip_addresses,
    COUNT(DISTINCT CASE 
      WHEN CAST(exclude_hit AS INTEGER) <<= 0 
        AND CAST(hit_source AS VARCHAR) NOT IN ('5', '7', '8', '9')
      THEN CAST(post_visid_high AS VARCHAR) || '-' || CAST(post_visid_low AS VARCHAR)
    END) AS unique_visitor_count,
    COUNT(DISTINCT geo_city) AS unique_cities,
    COUNT(DISTINCT browser) AS browsers,
    'Classic Factiva' AS factiva_version
  FROM fact_external_db.omniture_event_fact omnit 
  WHERE reporting_suite = 'djfactiva'
    AND cycle_date >>= DATE_ADD('day', -30, CURRENT_DATE)
  GROUP BY 1, 2
),
new_factiva_raw AS (
  SELECT 
    SUBSTRING(CAST(cycle_date AS VARCHAR), 1, 10) AS year_month_date,
    user_info_user_ref AS pib_member_id,
    COUNT(DISTINCT ti_bd_client_ip_address) AS ip_addresses,
    COUNT(DISTINCT ti_aggregate_id) AS unique_visitor_count,
    COUNT(DISTINCT city_name) AS unique_cities
  FROM pib_event_data.pib_product_metrics
  WHERE product = 'New Factiva'
    AND event_name IN ('user_action', 'page_view')
    AND cycle_date >>= DATE_ADD('day', -30, CURRENT_DATE)
  GROUP BY 1, 2
),

new_factiva AS (
  SELECT 
    r.year_month_date,
    m.eid,
    r.ip_addresses,
    r.unique_visitor_count,
    r.unique_cities,
    NULL AS browsers,
    'New Factiva' AS factiva_version
  FROM new_factiva_raw r
  LEFT JOIN dimension_external_db.pib_membership_dimension m
    ON r.pib_member_id = m.pib_member_id
),
omnit AS (
  SELECT * FROM classic_factiva
  UNION ALL
  SELECT * FROM new_factiva
),

mem_dim AS (
  SELECT
    pib_member_id,
    user_id,
    first_name,
    last_name,
    eid,
    plan_id,
    billing_account_id
  FROM dimension_external_db.pib_membership_dimension
  WHERE user_status = 'A'
  GROUP BY 1, 2, 3, 4, 5, 6, 7
),

Bill_Acct_Dim AS (
  SELECT
    cibs_billing_account_id,
    account_sales_territory,
    salesforce_max_sessions,
    salesforce_territory_owner,
    salesforce_company_two
  FROM dimension_external_db.pib_billing_account_dimension
  GROUP BY 1, 2, 3, 4, 5
)
  SELECT 
    mem_dim.pib_member_id,
    mem_dim.user_id,
    mem_dim.eid,
    mem_dim.first_name,
    mem_dim.last_name,
    mem_dim.plan_id,
    mem_dim.billing_account_id,
    omnit.year_month_date,
    omnit.ip_addresses,
    omnit.unique_visitor_count,
    omnit.unique_cities,
    omnit.browsers,
    omnit.factiva_version
  FROM omnit
  LEFT JOIN mem_dim ON omnit.eid = mem_dim.eid
  LEFT JOIN Bill_Acct_Dim ON Bill_Acct_Dim.cibs_billing_account_id = mem_dim.billing_account_id


  WHERE ip_addresses >>= 3
    AND unique_cities >>= 3
    AND omnit.eid IS NOT null

  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
           11, 12, 13
