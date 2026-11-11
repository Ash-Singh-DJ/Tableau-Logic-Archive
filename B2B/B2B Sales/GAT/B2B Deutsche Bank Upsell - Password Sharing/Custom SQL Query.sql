-- Published data source : "B2B Deutsche Bank Upsell - Password Sharing"  [B2B / B2B Sales / GAT]
-- Relation    : Custom SQL "Custom SQL Query"
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
  FROM fact_external_db.omniture_event_fact
  WHERE reporting_suite = 'djfactiva'
    AND cycle_date >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('day', -400, CURRENT_DATE)))
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
    AND cycle_date >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('day', -400, CURRENT_DATE)))
    and user_info_account_id in ('9DEU001700','9DEU005300','9DEU004800','9DEU001500','9DEU008900',
'9DEU004000','9DEU006000','9DEU011300','9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
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
  WHERE billing_account_id in ('9DEU001700','9DEU005300','9DEU004800','9DEU001500','9DEU008900',
'9DEU004000','9DEU006000','9DEU011300','9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
  and user_status = 'A'
  GROUP BY 1, 2, 3, 4, 5, 6, 7
),

product_master AS (
  SELECT
    access_code,
    master_product
  FROM reference_external_db.pib_product_dimension
  GROUP BY 1, 2
),

Territory_Dim AS (
  SELECT
    territory_sfdc_id,
    territory_name,
    territory_roll_up,
    territory_owner,
    regional_sales_director
  FROM dimension_external_db.pib_territory_dimension
  WHERE territory_status = 'Active'
  GROUP BY 1, 2, 3, 4, 5
),

Territory_Dim2 AS (
  SELECT
    territory_sfdc_id,
    territory_name,
    territory_roll_up,
    territory_owner
  FROM dimension_external_db.pib_territory_dimension
  WHERE territory_status = 'Active'
    AND status_flag <<>> 'DELETE'
  GROUP BY 1, 2, 3, 4
),

Salesperson_Dim AS (
  SELECT
    user_sfdc_id,
    user_full_name
  FROM dimension_external_db.pib_user_dimension
  GROUP BY 1, 2
),

Comp AS (
  SELECT
    company_name,
    company_sfdc_id,
    company_territory
  FROM dimension_external_db.pib_company_dimension
),

Bill_Acct_Dim AS (
  SELECT
    cibs_billing_account_id,
    account_sales_territory,
    salesforce_max_sessions,
    salesforce_territory_owner,
    salesforce_company_two
  FROM dimension_external_db.pib_billing_account_dimension
  where cibs_billing_account_id in ('9DEU001700','9DEU005300','9DEU004800','9DEU001500','9DEU008900',
'9DEU004000','9DEU006000','9DEU011300','9DEU005600','9DEU003200','9DEU019300','9DEU017100','9DEU004600')
  GROUP BY 1, 2, 3, 4, 5
),

user_dim AS (
  SELECT
    user_sfdc_id,
    user_full_name
  FROM dimension_external_db.pib_user_dimension
  GROUP BY 1, 2
),
main_subq AS (
  SELECT 
    mem_dim.pib_member_id,
    mem_dim.user_id,
    mem_dim.eid,
    mem_dim.first_name,
    mem_dim.last_name,
    mem_dim.plan_id,
    mem_dim.billing_account_id,
    Territory_Dim.territory_name,
    Territory_Dim.territory_roll_up,
    Salesperson_Dim.user_full_name,
    Bill_Acct_Dim.account_sales_territory,
    REPLACE(Bill_Acct_Dim.salesforce_territory_owner, '  ', ' ') AS account_owner,
    Territory_Dim2.territory_name AS account_territory_name,
    Territory_Dim2.territory_roll_up AS account_territory_roll_up,
    Bill_Acct_Dim.salesforce_max_sessions,
    Comp.company_name,
    product_master.master_product,
    omnit.year_month_date,
    omnit.ip_addresses,
    omnit.unique_visitor_count,
    omnit.unique_cities,
    omnit.browsers,
    omnit.factiva_version
  FROM omnit
  LEFT JOIN mem_dim ON omnit.eid = mem_dim.eid
  LEFT JOIN Bill_Acct_Dim ON Bill_Acct_Dim.cibs_billing_account_id = mem_dim.billing_account_id
  LEFT JOIN product_master ON mem_dim.plan_id = product_master.access_code
  LEFT JOIN Comp ON Bill_Acct_Dim.salesforce_company_two = Comp.company_sfdc_id
  LEFT JOIN Territory_Dim ON Comp.company_territory = Territory_Dim.territory_sfdc_id
  LEFT JOIN Salesperson_Dim ON Territory_Dim.territory_owner = Salesperson_Dim.user_sfdc_id
  LEFT JOIN Territory_Dim2 ON Bill_Acct_Dim.account_sales_territory = Territory_Dim2.territory_name
  WHERE ip_addresses >>= 3
    AND unique_cities >>= 3
    AND omnit.eid IS NOT NULL
  GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
           11, 12, 13, 14, 15, 16, 17, 18, 19, 20,
           21, 22, 23
)
SELECT *
FROM main_subq
WHERE LOWER(billing_account_id) LIKE '9deu%'
  --AND LOWER(billing_account_id) NOT LIKE '9zfb%'
