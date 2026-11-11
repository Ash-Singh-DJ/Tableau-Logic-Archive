-- Published data source : "B2B R&C API - Migration Report Legacy API"  [B2B / B2B Product / R&C / Datasources]
-- Relation    : Custom SQL "Custom SQL Query"
-- Connection  : Athena (AwsDataCatalog / athena_db), server athena.us-east-1.amazonaws.com
-- Archived    : 2026-11-11 from Tableau Cloud site dj-cdl-prod. Verbatim Athena (Presto) SQL as stored in Tableau;
--               not translated or reformatted. Tableau <[Parameters].[...]> tokens kept as-is.
-- ----------------------------------------------------------------------------
SELECT billing_account_number, salesforce_name, sales_order, status, territory, record_type_id, risk_compliance_api, risk_api_via_dna, feed_type, company_name, opportunity, risk_compliance_feeds, api_migration
FROM dimension_external_db.pib_product_configuration_request_dimension
WHERE created_date >>= date('2018-07-01')
AND lower(opportunity) like '%migration%'
AND risk_compliance_feeds = 'NONE'
AND api_migration = 'Yes'
AND record_type_id = '01270000000MQQyAAO'
GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13
ORDER BY 2
