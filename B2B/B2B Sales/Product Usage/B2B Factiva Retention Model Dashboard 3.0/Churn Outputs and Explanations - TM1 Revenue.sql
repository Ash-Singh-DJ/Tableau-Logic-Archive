-- Dashboard   : "B2B Factiva Retention Model Dashboard 3.0"  [B2B / B2B Sales / Product Usage]
-- Data source : "Churn Outputs and Explanations" (embedded in the workbook)
-- Relation    : Custom SQL "TM1 Revenue"
-- Connection  : Athena (AwsDataCatalog / zoolander_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
WITH Bill_Acct_Dim AS (
  SELECT cibs_billing_account_id, contract_id, subscription_date
  FROM dimension_external_db.pib_billing_account_dimension
  GROUP BY cibs_billing_account_id, contract_id, subscription_date),

Contract_Dim AS (
  SELECT contract_id
  FROM dimension_external_db.pib_contract_dimension
  GROUP BY contract_id),

Acct_Fact AS ( 
  SELECT contract_id, company_sfdc_id
  FROM fact_external_db.pib_account_hierarchy_fact
  GROUP BY contract_id, company_sfdc_id),

Comp AS ( 
  SELECT company_name, company_sfdc_id, company_industry, company_territory, factiva_f_code
  FROM dimension_external_db.pib_company_dimension),

product_filter AS (
  SELECT master_product, tm1_product
  FROM reference_external_db.pib_product_master 
  WHERE lower(product_line) LIKE '%factiva%' 
    OR lower(product_line) LIKE '%djx%' 
    OR lower(product_line) LIKE '%risk center%'),

tm AS (
  SELECT billing_account_number,
         TRIM(product) AS product,
         pm.product_line,
         SUBSTRING(CAST(billing_date AS varchar), 1, 7) billing_date,
         SUM(exit_rate*12) annualized_rev
  FROM fact_external_db.tm1_fact tm1
  LEFT JOIN reference_external_db.pib_product_master pm ON tm1.product = pm.tm1_product
  WHERE TRIM(product) IN (SELECT tm1_product FROM product_filter)
    AND billing_date = (SELECT MAX(billing_date) FROM fact_external_db.tm1_fact)
  GROUP BY billing_account_number, product, product_line, billing_date)
  
SELECT company_sfdc_id, company_name, 
         SUM(CASE WHEN lower(product_line) LIKE '%factiva%' THEN annualized_rev END) factiva_annualized_rev,
         SUM(CASE WHEN lower(product_line) LIKE '%djx%' THEN annualized_rev END) djx_annualized_rev,
         SUM(CASE WHEN lower(product_line) LIKE '%factiva%' OR lower(product_line) LIKE '%djx%' THEN annualized_rev END) factiva_djx_annualized_rev,
         SUM(CASE WHEN lower(product_line) LIKE '%risk center%' THEN annualized_rev END) riskcenter_annualized_rev
  FROM (
    SELECT Comp.company_sfdc_id, Comp.company_name, Bill_Acct_Dim.cibs_billing_account_id, Bill_Acct_Dim.contract_id
    FROM Bill_Acct_Dim
    left join Contract_Dim on Bill_Acct_Dim.contract_id = Contract_Dim.contract_id
    left join Acct_Fact on Contract_Dim.contract_id = Acct_Fact.contract_id
    left join Comp on Acct_Fact.company_sfdc_id = Comp.company_sfdc_id
    GROUP BY comp.company_sfdc_id, Comp.company_name, Bill_Acct_Dim.cibs_billing_account_id, Bill_Acct_Dim.contract_id) inny
  LEFT JOIN tm ON inny.cibs_billing_account_id = tm.billing_account_number
  GROUP BY company_sfdc_id, company_name, billing_date
  HAVING SUM(CASE WHEN lower(product_line) LIKE '%factiva%' OR lower(product_line) LIKE '%djx%' THEN annualized_rev END) >> 0
