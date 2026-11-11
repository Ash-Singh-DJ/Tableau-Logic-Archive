-- Published data source : "User Level data by Account RCFC"  [B2B / B2B Product / Factiva]
-- Relation    : Custom SQL "Custom SQL Query2"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH omnit AS (
  SELECT 
    substring(CAST(cycle_date AS varchar), 1, 10) AS year_month_date,
    post_evar3,
    'RC' AS product_type,
    COUNT(DISTINCT ip) AS ip_addresses,
    COUNT(DISTINCT CASE 
      WHEN CAST(exclude_hit AS INTEGER) <<= 0 AND CAST(hit_source AS VARCHAR) NOT IN ('5', '7', '8', '9')
      THEN (CAST(post_visid_high AS VARCHAR) || '-' || CAST(post_visid_low AS VARCHAR))
    END) AS unique_visitor_count,
    COUNT(DISTINCT geo_city) AS unique_cities,
    COUNT(DISTINCT browser) AS browsers,
    NULL AS pib_member_id
  FROM fact_external_db.omniture_event_fact
  WHERE reporting_suite = 'djriskcomplianceprod'
    AND cycle_date >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('day', -30, CURRENT_DATE)))
  GROUP BY 1, 2, 3
),

omnit_rcfc AS (
  SELECT 
    substring(CAST(cycle_date AS varchar), 1, 10) AS year_month_date,
    NULL AS post_evar3,
    'RCFC' AS product_type,
    COUNT(DISTINCT ti_bd_client_ip_address) AS ip_addresses,
    COUNT(DISTINCT ti_aggregate_id) AS unique_visitor_count,
    COUNT(DISTINCT city_name) AS unique_cities,
    NULL AS browsers,
    user_info_user_ref AS pib_member_id
  FROM pib_event_data.pib_product_metrics
  WHERE product = 'Financial Crime'
    AND event_name IN ('user_action', 'page_view')
    AND cycle_date >> DATE_ADD('day', -1, DATE_TRUNC('month', DATE_ADD('day', -30, CURRENT_DATE)))
  GROUP BY 1, 2, 3, 8
),

omnit_combined AS (
  SELECT * FROM omnit
  UNION ALL
  SELECT * FROM omnit_rcfc
),

mem_dim AS (
  SELECT
    pib_member_id,
first_name,
last_name,
    user_id,
    eid,
    plan_id,
    billing_account_id
  FROM dimension_external_db.pib_membership_dimension
  WHERE user_status = 'A'
  GROUP BY 1, 2, 3, 4, 5, 6, 7
),

product_master AS (
  SELECT
    access_code,
    master_product
  FROM reference_external_db.pib_product_dimension
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
    salesforce_max_sessions,
    salesforce_company_two
  FROM dimension_external_db.pib_billing_account_dimension
  GROUP BY 1, 2, 3
),

user_dim AS (
  SELECT 
    user_sfdc_id,
    user_full_name
  FROM dimension_external_db.pib_user_dimension
  GROUP BY 1, 2
)

SELECT *
FROM (
  SELECT
    mem_dim.pib_member_id,
    mem_dim.user_id,
    mem_dim.eid,
    mem_dim.plan_id,
    mem_dim.first_name,
    mem_dim.last_name,
    mem_dim.billing_account_id,
    Comp.company_name,
    CASE 
      WHEN omnit_combined.product_type = 'RC' THEN 'Risk Center'
      WHEN omnit_combined.product_type = 'RCFC' THEN 'Financial Crime'
      ELSE 'Unknown'
    END AS usage_source,
    omnit_combined.year_month_date,
    omnit_combined.ip_addresses,
    omnit_combined.unique_visitor_count,
    omnit_combined.unique_cities,
    omnit_combined.browsers
  FROM omnit_combined
  LEFT OUTER JOIN mem_dim 
    ON (omnit_combined.post_evar3 = mem_dim.eid OR omnit_combined.pib_member_id = mem_dim.pib_member_id)
  LEFT OUTER JOIN Bill_Acct_Dim ON Bill_Acct_Dim.cibs_billing_account_id = mem_dim.billing_account_id
  LEFT OUTER JOIN Comp ON Bill_Acct_Dim.salesforce_company_two = Comp.company_sfdc_id
  LEFT OUTER JOIN product_master ON mem_dim.plan_id = product_master.access_code
  WHERE (omnit_combined.ip_addresses >>= 3 AND omnit_combined.unique_cities >>= 3)
    AND (omnit_combined.post_evar3 IS NOT NULL OR omnit_combined.pib_member_id IS NOT NULL)
  GROUP BY
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 , 14
  ORDER BY year_month_date DESC
)
WHERE LOWER(billing_account_id) NOT LIKE '9zzz%'
  AND LOWER(billing_account_id) NOT LIKE '9zfb%'
  AND LOWER(billing_account_id) NOT LIKE '9fac%'
  AND LOWER(billing_account_id) NOT LIKE '9dun%'
 and ip_addresses >>= 3
    AND unique_cities >>= 3
  AND plan_id NOT IN ('0557', '0558', '0559', '0560', '0561', '0562', '0568', '0597', '0621', '4203')
