-- Dashboard   : "Pricing Bundle Workbook"  [B2B / B2B Pricing]
-- Data source : "TM1 Raw Data for Pricing" (embedded in the workbook)
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / dimension_external_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT tm.billing_date, 
        tm.customer_name, 
        comp.company_name, 
        ctr.salesforce_contract_number as contract,
        tm.billing_account_number, 
        tm.country, 
        tm.industry, 
        tm.sales_territory, 
        tm.sales_region, 
        tm.tm1_name,
        tm.cibs_id, 
        tm.cibs_product, 
        tm.product, 
        tm.product_category, 
        tm.tm1_rollup_bu,
        tm.tm1_rollup_segment,
        tm.tm1_rollup_category,
        pd.bu as business_unit,
        pd.product_line,
        psa.product_service, 
        sum(tm.exit_rate) exit_rate
FROM fact_external_db.tm1_fact tm
LEFT JOIN dimension_external_db.pib_product_service_attributes psa ON psa.billing_code = tm.cibs_id 
LEFT JOIN dimension_external_db.pib_billing_account_dimension bad on bad.cibs_billing_account_id = tm.billing_account_number
LEFT JOIN dimension_external_db.pib_company_dimension comp on comp.company_sfdc_id = bad.salesforce_company_two
LEFT JOIN dimension_external_db.pib_contract_dimension ctr ON bad.contract_id = ctr.contract_id
left join reference_external_db.pib_product_dimension pd on psa.product_service = pd.sfdc_product
WHERE billing_date >>= date('2022-09-01')
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20
