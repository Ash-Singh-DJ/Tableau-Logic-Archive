-- Dashboard   : "B2B Screening & Monitoring Customer Report"  [B2B / B2B Product / R&C]
-- Data source : "RC Revenue" = published source "B2B Screening & Monitoring RC Revenue"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / abc_matrix), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH stuff_names as (
SELECT DISTINCT corp_id, 
				customer AS customer_name
FROM reference_external_db.pib_account_mapping),

stuff as (SELECT billing_account_number,
         corporate_id,
         sm.customer_name, 
         TRIM(product) AS tm1_product,
         pm.bu business_unit,
         billing_date,
         product_category,
         account_name,
         country,
         industry,
         sales_territory,
         sales_region,
         cibs_id,
         tm1.cibs_product,
         num_user_seats,
         user_trans_vol,
         SUM(exit_rate) exit_rate,
         SUM(exit_rate*12) annualized_rev,
         sum(total_revenue) total_revenue,
         sum(total_non_recurring_revenue) total_non_recurring_revenue,
         0 as twelve_mo_one_time_rev
FROM fact_external_db.tm1_fact tm1
LEFT JOIN reference_external_db.pib_product_master pm ON tm1.product = pm.tm1_product
LEFT JOIN stuff_names sm ON tm1.corporate_id = sm.corp_id 
WHERE billing_date >>= DATE('2017-07-01')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16),

tm1_latest_month as (select max(billing_date) billing_month FROM fact_external_db.tm1_fact),

month_dates_table as (SELECT SUBSTRING(CAST(full_date AS varchar),1,7) as year_month, MIN(date_trunc('day', full_date)) as month_start_date
  FROM reference_external_db.date_dimension
  CROSS JOIN tm1_latest_month 
  WHERE full_date >>= date_trunc('month', DATE_ADD('month', -23, billing_month))
    AND full_date <<= date_trunc('month', DATE_ADD('month', 1, billing_month))
  GROUP BY 1
  ORDER BY month_start_date),

uni as (SELECT tm1.billing_account_number, 
       corporate_id, 
       stuff_names.customer_name,
       product as tm1_product, 
       pm.bu business_unit,
       month_dates_table.month_start_date billing_date, 
       product_category,
       account_name,
       country, 
       industry,
       substring(sales_territory, 5) sales_territory,
       sales_region,
       cibs_id,
       tm1.cibs_product,
       num_user_seats,
       user_trans_vol,
       0 as exit_rate,
       0 as annualized_rev,
       0 as total_revenue,
       0 as total_non_recurring_revenue,
       SUM(CASE WHEN billing_date <<= month_dates_table.month_start_date 
       				AND billing_date >>= DATE(DATE_ADD('month',-13, month_dates_table.month_start_date)) 
       			THEN total_non_recurring_revenue ELSE 0 END) twelve_mo_one_time_rev 
FROM fact_external_db.tm1_fact tm1
CROSS JOIN month_dates_table
LEFT JOIN reference_external_db.pib_product_master pm ON tm1.product = pm.tm1_product
LEFT JOIN stuff_names on stuff_names.corp_id = tm1.corporate_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16),


tm AS (SELECT * FROM stuff
UNION ALL (SELECT * FROM uni)),
  
  
Bill_Acct_Dim AS (
  SELECT DISTINCT cibs_billing_account_id, contract_id, subscription_date, salesforce_status
  FROM dimension_external_db.pib_billing_account_dimension),

Contract_Dim AS (
  SELECT DISTINCT contract_id
  FROM dimension_external_db.pib_contract_dimension),

Acct_Fact AS ( 
  SELECT DISTINCT contract_id, company_sfdc_id
  FROM fact_external_db.pib_account_hierarchy_fact),

Comp AS ( 
  SELECT DISTINCT company_name, company_sfdc_id, company_state
  FROM dimension_external_db.pib_company_dimension),
  
Corp AS ( 
  SELECT DISTINCT corporate_sfdc_id, corporate_id, corporate_name
  FROM dimension_external_db.pib_corporate_dimension
),

inny AS (
    SELECT DISTINCT Comp.company_sfdc_id, 
           Comp.company_name, 
            Comp.company_state,
           Bill_Acct_Dim.cibs_billing_account_id, 
           Bill_Acct_Dim.contract_id,
           Bill_Acct_Dim.salesforce_status
    FROM Bill_Acct_Dim
    LEFT JOIN Contract_Dim ON Bill_Acct_Dim.contract_id = Contract_Dim.contract_id
    LEFT JOIN Acct_Fact ON Contract_Dim.contract_id = Acct_Fact.contract_id
    LEFT JOIN Comp ON Acct_Fact.company_sfdc_id = Comp.company_sfdc_id)
     

SELECT inny.company_sfdc_id, 
       inny.company_name, 
        inny.company_state,
        inny.salesforce_status,
       Corp.corporate_name,
       tm.customer_name,
       tm.corporate_id,
       tm.billing_account_number, 
       tm.tm1_product, 
       tm.product_category,
       tm.account_name,
       tm.country,
       upper(tm.industry) industry,
       tm.sales_territory,
       geo.geo_region,
       tm.sales_region,
       tm.cibs_id,
       tm.cibs_product,
         j.product_service,
       tm.num_user_seats,
       tm.user_trans_vol,
       tm.business_unit, 
       CAST (tm.billing_date AS date) billing_date, 
       tm.exit_rate,
       tm.annualized_rev,
       tm.total_revenue,
       tm.total_non_recurring_revenue,
       tm.twelve_mo_one_time_rev
FROM tm 
LEFT JOIN inny ON inny.cibs_billing_account_id = tm.billing_account_number
LEFT JOIN Corp on Corp.corporate_id = tm.corporate_id
left join dimension_external_db.pib_product_service_attributes j on tm.cibs_id = j.billing_code
left join sandbox_mk.geo_region_rollup geo on substring(tm.sales_territory, 5) = geo.sales_territory

WHERE billing_date >>= cast('2024-01-01' as date)
and (business_unit = 'R&C' or business_unit is null)
--AND tm.billing_account_number='9HER003700'
--AND cibs_product LIKE 'RC%'
